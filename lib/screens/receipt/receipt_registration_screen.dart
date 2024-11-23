import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'expense_method_selection_screen.dart';
import '../receipt/option_tile.dart';
import '../../services/api_service.dart';
import '../../services/category.dart';
import '../../services/report.dart';
import 'package:http/http.dart' as http; // 추가
import 'package:path/path.dart' as path; // 추가
import 'package:intl/intl.dart'; // 추가
import 'package:flutter_svg/flutter_svg.dart'; // 추가

// 매핑 상수 정의
const Map<String, String> paymentMethodMap = {
  'CASH': '현금',
  'CARD': '카드',
  'TRANSFER': '계좌이체', // 오타 수정: 'TRANFER' -> 'TRANSFER'
  'OTHER': '기타',
};

class ReceiptRegistrationScreen extends StatefulWidget {
  final int? expenseId; // 선택적 expenseId로 변경

  ReceiptRegistrationScreen({this.expenseId});

  @override
  _ReceiptRegistrationScreenState createState() =>
      _ReceiptRegistrationScreenState();
}

class _ReceiptRegistrationScreenState extends State<ReceiptRegistrationScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _employeeId;

  DateTime _selectedDate = DateTime.now();

  String _selectedCategory = '카테고리 선택';
  int? _categoryId;

  String _expenseMethod = '카드';
  String _expenseValue = 'CARD';
  Icon? _expenseIcon = Icon(Icons.money, color: Colors.grey);

  String _url = '';

  String _selectedReport = '보고서 선택';
  int? _reportId;

  bool isLoading = true;
  bool hasError = false;
  bool isUploading = false; // 이미지 업로드 상태 관리

  String? _receiptImage;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // 경고 대화상자 표시 함수
  void _showAlertDialog(String message) {
    if (!mounted) return; // 위젯이 여전히 트리에 있는지 확인
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            '알림',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            message,
            style: TextStyle(color: Color(0xFF7a7a7a)), // 색상 수정
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                '확인',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _initializeNewExpense(String employeeId) {
    setState(() {
      _amountController.text = '';
      _businessNameController.text = '';
      _selectedDate = DateTime.now();
      _dateController.text =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      // 기본값 설정
      _categoryId = null;
      _selectedCategory = '카테고리 선택';

      // paymentMethod 기본값 설정
      _expenseValue = 'CARD'; // 'CARD'를 기본값으로 설정
      _expenseMethod = paymentMethodMap[_expenseValue] ?? '카드';

      _selectedReport = '보고서 선택';
      _reportId = null;

      isLoading = false;
    });
  }

  Future<void> _fetchData() async {
    try {
      final employeeId = await _fetchEmployeeId();
      _employeeId = employeeId;
      if (employeeId != null) {
        if (widget.expenseId != null) {
          print('지출 업데이트');
          await _loadReceiptData(employeeId);
        } else {
          print('신규 지출');
          _initializeNewExpense(employeeId);
        }
      } else {
        _showError('로그인 정보가 없습니다. 다시 로그인 해주세요.');
      }
    } catch (e) {
      _showError('오류가 발생했습니다: $e');
    }
  }

  Future<String?> _fetchEmployeeId() async {
    final userData = await _secureStorage.read(key: 'user_data');
    if (userData != null) {
      final userJson = jsonDecode(userData);
      return userJson['employeeId']?.toString();
    }
    return null;
  }

  Future<void> _loadReceiptData(String employeeId) async {
    try {
      final data = await ApiService.fetchExpenseDetails(
        widget.expenseId!,
        employeeId,
      );

      setState(() {
        _amountController.text = data['amount'].toString();
        _businessNameController.text = data['merchantName'];
        _selectedDate = DateTime.parse(data['expenseDate']);
        _dateController.text =
            '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
        _receiptImage = data['url'];

        // 카테고리 데이터 업데이트
        _categoryId = data['categoryId'];
        _selectedCategory = data['categoryName'] ?? '카테고리 선택';

        // paymentMethod 매핑 적용
        _expenseValue = data['paymentMethod'] ?? 'CASH'; // 'CASH'를 기본값으로 설정
        _expenseMethod =
            paymentMethodMap[_expenseValue] ?? '현금'; // 매핑을 통해 텍스트 설정

        _selectedReport = data['reportTitle'] ?? '보고서 선택';
        _reportId = data['reportId'];

        print(_selectedReport);

        isLoading = false;
      });
    } catch (e) {
      _showError('데이터를 불러오지 못했습니다: $e');
    }
  }

  void _showError(String message) {
    setState(() {
      isLoading = false;
      hasError = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onDateSelected(DateTime selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
      _dateController.text =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _receiptImage = pickedFile.path;
          isUploading = true; // 업로드 시작 시 로딩 상태 활성화
        });

        // Prepare the multipart request
        var uri = Uri.parse('http://shcrm.ddns.net:5000/extract');
        var request = http.MultipartRequest('POST', uri);

        // Attach the file with the key 'file'
        var file = await http.MultipartFile.fromPath(
          'file',
          pickedFile.path,
          filename: path.basename(pickedFile.path),
        );
        request.files.add(file);

        // Send the request
        var response = await request.send();

        // Handle the response
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          print('서버 응답: $responseData');
          _showAlertDialog('이미지가 성공적으로 업로드되었습니다.');

          // JSON 응답 파싱
          final Map<String, dynamic> jsonResponse = jsonDecode(responseData);

          // **이미지_URL 추출 및 설정**
          if (jsonResponse.containsKey('이미지_URL')) {
            setState(() {
              _url = jsonResponse['이미지_URL'];
            });
          }

          // **카테고리 추출 및 설정**
          if (jsonResponse.containsKey('카테고리')) {
            final categoryData = jsonResponse['카테고리'] as Map<String, dynamic>;
            if (categoryData.containsKey('categoryId')) {
              setState(() {
                _categoryId = categoryData['categoryId'];
              });
            }
            if (categoryData.containsKey('categoryName')) {
              setState(() {
                _selectedCategory = categoryData['categoryName'];
              });
            }
          }

          // OCR 결과 추출
          if (jsonResponse.containsKey('OCR_결과')) {
            final ocrResult = jsonResponse['OCR_결과'] as Map<String, dynamic>;

            // 금액 추출 및 설정
            if (ocrResult.containsKey('금액')) {
              setState(() {
                _amountController.text = ocrResult['금액'].toString();
              });
            }

            // 상호명 추출 및 설정
            if (ocrResult.containsKey('가맹점명') &&
                (ocrResult['가맹점명'] as List).isNotEmpty) {
              setState(() {
                _businessNameController.text = ocrResult['가맹점명'][0];
              });
            } else if (jsonResponse.containsKey('카테고리_키워드')) {
              // '카테고리_키워드'에서 '상호명' 추출
              final categoryKeyword =
                  jsonResponse['카테고리_키워드'] as Map<String, dynamic>;
              if (categoryKeyword.isNotEmpty) {
                final firstKey = categoryKeyword.keys.first;
                final subMap =
                    categoryKeyword[firstKey] as Map<String, dynamic>;
                if (subMap.containsKey('상호명')) {
                  setState(() {
                    _businessNameController.text = subMap['상호명'];
                  });
                }
              }
            }

            // 거래일시 추출 및 설정
            if (ocrResult.containsKey('거래일시')) {
              List<dynamic> transactionDates = ocrResult['거래일시'];
              if (transactionDates.isNotEmpty) {
                String firstDate = transactionDates[0];
                // 점(.)을 하이픈(-)으로 교체
                firstDate = firstDate.replaceAll('.', '-');
                DateTime parsedDate;
                try {
                  parsedDate = DateTime.parse(firstDate);
                } catch (e) {
                  // intl 패키지 사용
                  DateFormat format = DateFormat('yyyy-MM-dd');
                  parsedDate = format.parse(firstDate);
                }
                setState(() {
                  _selectedDate = parsedDate;
                  _dateController.text =
                      '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
                });
              }
            }

            // paymentMethod 추출 및 설정 (필요 시)
            if (jsonResponse.containsKey('paymentMethod')) {
              _expenseValue = jsonResponse['paymentMethod'] ?? 'CASH';
              _expenseMethod = paymentMethodMap[_expenseValue] ?? '현금';
              setState(() {});
            }
          }
        } else {
          print('서버 오류: ${response.statusCode}');
          _showAlertDialog('이미지 업로드에 실패했습니다. 상태 코드: ${response.statusCode}');
        }
      } else {
        print('이미지가 선택되지 않았습니다.');
      }
    } catch (e) {
      print('이미지 업로드 중 오류 발생: $e');
      _showAlertDialog('이미지 업로드 중 오류가 발생했습니다.');
    } finally {
      setState(() {
        isUploading = false; // 업로드 완료 시 로딩 상태 비활성화
      });
    }
  }

  Future<void> _saveExpenseData() async {
    try {
      final data = {
        if (widget.expenseId != null) 'expenseId': widget.expenseId,
        'employeeId': _employeeId,
        'amount': _amountController.text,
        'address': '',
        'merchantName': _businessNameController.text,
        'expenseDate': _dateController.text + 'T00:00:00',
        'categoryId': _categoryId,
        'reimbursement': 'N',
        'reportId': _reportId,
        'isDeleted': "N",
        'paymentMethod': _expenseValue,
        'url': _url
      };

      print('api : ${data}');

      if (widget.expenseId != null) {
        await ApiService.updateExpenseData(data);
      } else {
        await ApiService.createExpenseData(data);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('지출 데이터가 저장되었습니다.')),
      );

      // 저장 완료 후 부모 페이지로 true 값을 전달하며 돌아가기
      Navigator.pop(context, true);
    } catch (e) {
      _showError('지출 데이터를 저장하지 못했습니다: $e');
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _businessNameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFefefef),
      appBar: AppBar(
        backgroundColor: Color(0xFF009EB4),
        toolbarHeight: 60,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.chevron_left, size: 24, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          '지출',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () {
                // 입력된 데이터를 확인
                final amount = _amountController.text.trim();
                final merchantName = _businessNameController.text.trim();

                // 필수 필드 검증
                if (amount.isEmpty) {
                  _showAlertDialog('금액을 입력해주세요.');
                  return;
                }

                if (merchantName.isEmpty) {
                  _showAlertDialog('상호를 입력해주세요.');
                  return;
                }

                // 금액이 숫자인지 확인 (선택 사항)
                if (double.tryParse(amount) == null) {
                  _showAlertDialog('유효한 금액을 입력해주세요.');
                  return;
                }

                // 모든 검증을 통과하면 저장 함수 호출
                _saveExpenseData();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                '저장',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '금액 *',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF007792),
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '금액을 입력하세요',
                                      hintStyle: TextStyle(
                                        fontSize: 18, // 원하는 폰트 크기로 설정
                                        color: Colors
                                            .grey, // hintText 색상도 필요에 따라 설정 가능
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'KRW',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.black),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: _receiptImage != null &&
                                                _receiptImage!.isNotEmpty
                                            ? (_receiptImage!.startsWith('http')
                                                ? Image.network(
                                                    _receiptImage!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return SvgPicture.asset(
                                                        'assets/icons/none_picture.svg',
                                                        height: 40,
                                                        width: 40,
                                                      );
                                                    },
                                                  )
                                                : Image.file(
                                                    File(_receiptImage!),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Icon(
                                                          Icons.broken_image,
                                                          size: 40,
                                                          color:
                                                              Colors.grey[400]);
                                                    },
                                                  ))
                                            : Icon(Icons.image,
                                                size: 40,
                                                color: Colors.grey[400]),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              '상호 *',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            TextField(
                              controller: _businessNameController,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF007792),
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '상호를 입력하세요',
                                hintStyle: TextStyle(
                                  fontSize: 14, // 원하는 폰트 크기로 설정
                                  color:
                                      Colors.grey, // hintText 색상도 필요에 따라 설정 가능
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '날짜 *',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[500]),
                            ),
                            GestureDetector(
                              onTap: () async {
                                DateTime? selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                  initialEntryMode:
                                      DatePickerEntryMode.calendarOnly,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        inputDecorationTheme:
                                            InputDecorationTheme(
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              width: 0.5,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                        colorScheme: ColorScheme.light(
                                          onPrimary: Colors.white,
                                          primary: Colors.blue,
                                          background: Colors.white,
                                        ),
                                        datePickerTheme: DatePickerThemeData(
                                          headerBackgroundColor: Colors.blue,
                                          backgroundColor: Colors.white,
                                          headerForegroundColor: Colors.white,
                                          surfaceTintColor: Colors.white,
                                          dividerColor: Colors.blue,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (selectedDate != null &&
                                    selectedDate != _selectedDate) {
                                  _onDateSelected(selectedDate);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[200]!),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _dateController.text.isNotEmpty
                                          ? _dateController.text
                                          : '날짜를 선택하세요',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _dateController.text.isNotEmpty
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                    Icon(Icons.add,
                                        color: Colors.grey[400], size: 20),
                                  ],
                                ),
                              ),
                            ),
                            OptionTile(
                              title: '카테고리',
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedCategory,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final selectedCategory = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryScreen(
                                        selectedCategoryId: _categoryId),
                                  ),
                                );

                                if (selectedCategory != null) {
                                  setState(() {
                                    _selectedCategory =
                                        selectedCategory['categoryName'];
                                    _categoryId =
                                        selectedCategory['categoryId'];
                                  });
                                }
                              },
                            ),
                            OptionTile(
                              title: '지출방법',
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_expenseIcon != null) _expenseIcon!,
                                  SizedBox(width: 8),
                                  Text(
                                    _expenseMethod,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final selectedData = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ExpenseMethodSelectionScreen(
                                      currentMethodValue: _expenseValue,
                                    ),
                                  ),
                                );

                                if (selectedData != null) {
                                  setState(() {
                                    _expenseMethod = selectedData['method'];
                                    _expenseValue = selectedData['value'];
                                    _expenseIcon = selectedData['icon'];
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
                            OptionTile(
                              title: '보고서',
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedReport,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final selectedReport = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ReportScreen(reportId: _reportId),
                                  ),
                                );

                                if (selectedReport != null) {
                                  setState(() {
                                    _reportId = selectedReport['reportId'];
                                    _selectedReport = selectedReport['title'];
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          if (isUploading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '업로드 중...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
