import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'expense_method_selection_screen.dart';
import '../receipt/option_tile.dart';
import '../../services/api_service.dart';
import '../../services/category.dart';

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

  String _selectedCategory = '카테고리 선택';
  int? _categoryId;

  DateTime _selectedDate = DateTime.now();
  String _expenseMethod = '현금';
  Icon? _expenseIcon = Icon(Icons.money, color: Colors.grey);

  bool isLoading = true;
  bool hasError = false;

  String? _receiptImage;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    if (widget.expenseId != null) {
      _fetchData();
    } else {
      _initializeNewExpense();
    }
  }

  void _initializeNewExpense() {
    setState(() {
      _amountController.text = '';
      _businessNameController.text = '';
      _selectedDate = DateTime.now();
      _dateController.text =
          '${_selectedDate.year}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.day.toString().padLeft(2, '0')}';

      // 기본값 설정
      _categoryId = null;
      _selectedCategory = '카테고리 선택';

      isLoading = false;
    });
  }

  Future<void> _fetchData() async {
    try {
      final employeeId = await _fetchEmployeeId();
      if (employeeId != null) {
        await _loadReceiptData(employeeId);
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
            '${_selectedDate.year}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.day.toString().padLeft(2, '0')}';
        _receiptImage = data['image'];

        // 카테고리 데이터 업데이트
        _categoryId = data['categoryId'];
        _selectedCategory = data['categoryName'] ?? '카테고리 선택';

        isLoading = false;
      });
    } catch (e) {
      _showError('데이터를 불러오지 못했습니다: $e');
    }
  }

  Icon _getIconForExpenseMethod(String method) {
    switch (method) {
      case '카드':
        return Icon(Icons.credit_card, color: Colors.grey);
      case '현금':
        return Icon(Icons.money, color: Colors.grey);
      default:
        return Icon(Icons.help_outline, color: Colors.grey);
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
          '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}';
    });
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
            child: // 저장 버튼의 onPressed 콜백 수정
                TextButton(
              onPressed: () {
                // 입력된 데이터를 확인
                final amount = _amountController.text;
                final businessName = _businessNameController.text;
                final date = _dateController.text;
                final category = _selectedCategory;
                final expenseMethod = _expenseMethod;

                print('저장 버튼 클릭');
                print('금액: $amount');
                print('상호: $businessName');
                print('날짜: $date');
                print('카테고리: $category');
                print('지출 방법: $expenseMethod');

                // 추가적으로 API 호출로 데이터를 저장하고 싶다면 아래와 같이 진행할 수 있습니다.
                //_saveExpenseData();
              },
              child: Text(
                '저장',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
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
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _receiptImage != null &&
                                          _receiptImage!.isNotEmpty
                                      ? Image.network(
                                          _receiptImage!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(Icons.broken_image,
                                                size: 40,
                                                color: Colors.grey[400]);
                                          },
                                        )
                                      : Icon(Icons.image,
                                          size: 40, color: Colors.grey[400]),
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
                              color: Colors.grey, // hintText 색상도 필요에 따라 설정 가능
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
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[500]),
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
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    inputDecorationTheme: InputDecorationTheme(
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
                                bottom: BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                _categoryId = selectedCategory['categoryId'];
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
                                  currentMethod: _expenseMethod,
                                ),
                              ),
                            );

                            if (selectedData != null) {
                              setState(() {
                                _expenseMethod = selectedData['method'];
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
                        OptionTile(title: '보고서'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
