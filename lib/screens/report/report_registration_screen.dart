import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker
import '../../services/api_service.dart';

class ReportRegistrationScreen extends StatefulWidget {
  final int? reportId;

  ReportRegistrationScreen({this.reportId});

  @override
  _ReportRegistrationScreenState createState() =>
      _ReportRegistrationScreenState();
}

class _ReportRegistrationScreenState extends State<ReportRegistrationScreen> {
  String? _employeeId;
  bool isLoading = true;
  bool hasError = false;
  Map<String, List<Map<String, dynamic>>> expensesByDate = {};

  String? _reportTitle;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Add selected files list
  List<PlatformFile> _selectedFiles = [];

  // Add history list
  List<Map<String, dynamic>> historyList = [];

  // Add comments list (optional)
  List<Map<String, dynamic>> commentsList = [];

  // TextEditingController for comments
  final TextEditingController _commentController = TextEditingController();
  bool _isCommentNotEmpty = false;

  @override
  void initState() {
    super.initState();
    _fetchData();

    // Add listener to the comment controller
    _commentController.addListener(() {
      setState(() {
        _isCommentNotEmpty = _commentController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _initializeNewReport(String employeeId) {
    setState(() {
      isLoading = false;
      // Initialize history list with a creation event
      historyList.add({
        'createdAt': DateTime.now().toIso8601String(),
        'employeeId': {
          'firstName': '홍',
          'lastName': '길동',
        },
        'action': '보고서가 생성되었습니다.',
      });
    });
  }

  Future<void> _fetchData() async {
    try {
      final employeeId = await _fetchEmployeeId();
      _employeeId = employeeId;
      if (employeeId != null) {
        if (widget.reportId != null) {
          await _loadReportData(employeeId);
        } else {
          _initializeNewReport(employeeId);
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

  Future<void> _loadReportData(String employeeId) async {
    try {
      final data = await ApiService.fetchReportDetails(
        widget.reportId!,
        employeeId,
      );

      // Group expenses by date
      final List<Map<String, dynamic>> expensesList =
          List<Map<String, dynamic>>.from(data['expensesData']);
      expensesByDate = {};
      for (var expense in expensesList) {
        final date = DateTime.parse(expense['createdAt'])
            .toLocal()
            .toString()
            .split(' ')[0];
        if (expensesByDate.containsKey(date)) {
          expensesByDate[date]!.add(expense);
        } else {
          expensesByDate[date] = [expense];
        }
      }

      // Initialize history list with existing history data if available
      if (data['historyData'] != null) {
        historyList = List<Map<String, dynamic>>.from(data['historyData']);
      } else {
        // 기본적으로 보고서 생성 이벤트 추가
        historyList.add({
          'createdAt': data['reportData']['createdAt'],
          'employeeId': {
            'firstName': data['reportData']['employeeId']['firstName'],
            'lastName': data['reportData']['employeeId']['lastName'],
          },
          'action': '보고서가 생성되었습니다.',
        });
      }

      setState(() {
        _reportTitle = data['reportData']['title']; // Add this line
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

  // 총 지출 건수 계산
  int get totalExpenses {
    return expensesByDate.values.fold(0, (sum, list) => sum + list.length);
  }

  // 총 지출 금액 계산
  double get totalAmount {
    return expensesByDate.values
        .expand((list) => list)
        .map((e) => e['amount'] is num ? e['amount'] as num : 0)
        .fold(0, (sum, amt) => sum + amt.toDouble());
  }

  // Method to pick files
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, // Allow multiple file selection
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });

        // Optionally, you can upload the files to your server here
        // await _uploadFiles(result.files);
      } else {
        // User canceled the picker
      }
    } catch (e) {
      print(e);
      _showError('파일을 선택하는 중 오류가 발생했습니다: $e');
    }
  }

  // Method to remove a selected file
  void _removeFile(PlatformFile file) {
    setState(() {
      _selectedFiles.remove(file);
    });
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
              // 뒤로가기 액션 처리
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          '보고서',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.email_outlined, size: 24, color: Colors.white),
            onPressed: () {
              // 메일 아이콘을 눌렀을 때 동작 추가
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 4, // 탭의 개수 설정
        child: Column(
          children: [
            // Common Header Area
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              color: Color(0xFF009EB4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _reportTitle ?? '새 보고서', // Change this line
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5.0),
                              bottomLeft: Radius.circular(5.0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 총 보고 금액
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '총 보고 금액',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '₩${_formatNumber(totalAmount)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              // 경비 환급 금액
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '경비 환급 금액',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(
                                    '₩0',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 62,
                          decoration: BoxDecoration(
                            color: Color(0xFF007792),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5.0),
                              bottomRight: Radius.circular(5.0),
                            ),
                          ),
                          child: Icon(
                            FontAwesomeIcons.chartPie,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // TabBar
            Container(
              color: Colors.white, // Tab background color
              child: TabBar(
                labelColor: Color(0xFF009EB4),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF009EB4),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(icon: Icon(Icons.description)), // Paper icon
                  Tab(icon: Icon(Icons.attach_file)), // Attachment icon
                  Tab(icon: Icon(Icons.history)), // History icon
                  Tab(icon: Icon(Icons.chat)), // Chat icon
                ],
              ),
            ),
            // TabBarView with Scrollable Content
            Expanded(
              child: TabBarView(
                children: [
                  // First Tab: Expenses
                  ListView(
                    padding: EdgeInsets.zero, // Remove default padding
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border(
                            bottom: BorderSide(
                              color: Colors
                                  .grey[300]!, // 보더 색상 설정 (원하는 색상으로 변경 가능)
                              width: 1.0, // 보더 두께 설정
                            ),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 3.0,
                        ), // Horizontal padding
                        width: double.infinity, // Full width
                        child: Text(
                          "지출 ${totalExpenses}건",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      // Expenses by Date
                      Container(
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: expensesByDate.keys.map((date) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12.0,
                                  ), // Vertical padding
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 3.0,
                                      ), // 패딩
                                      decoration: BoxDecoration(
                                        color: Colors
                                            .grey[300], // 배경색을 보더와 동일하게 설정
                                        borderRadius:
                                            BorderRadius.circular(8.0), // 둥근 보더
                                      ),
                                      child: Text(
                                        date.replaceAll('-', '.'),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // List of Expenses for the Date
                                ...expensesByDate[date]!.map((expense) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 5.0,
                                    ), // Margin
                                    padding: EdgeInsets.all(8.0), // 내부 패딩 추가
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 왼쪽 영역: 이미지 및 텍스트
                                        Row(
                                          children: [
                                            // 썸네일 이미지 또는 회색 배경
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: expense['image'] != null
                                                    ? Colors.transparent
                                                    : Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                image: expense['image'] != null
                                                    ? DecorationImage(
                                                        image: NetworkImage(
                                                            expense['image']),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            // 식대비 및 merchantName
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '식대비', // 필요에 따라 동적으로 변경 가능
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  expense['merchantName'] ??
                                                      'N/A',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        // 오른쪽 영역: 금액
                                        Text(
                                          '₩${_formatNumber(expense['amount'] ?? 0)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  // Second Tab: Attachments
                  ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Container(
                        color: Colors.grey[50],
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 3.0,
                        ),
                        width: double.infinity,
                        child: Text(
                          "첨부파일",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          border: Border(
                            top: BorderSide(
                              color: const Color.fromARGB(
                                  255, 224, 224, 224), // Top border color
                              width: 1.0, // Top border width
                            ),
                            bottom: BorderSide(
                              color: const Color.fromARGB(
                                  255, 224, 224, 224), // Bottom border color
                              width: 1.0, // Bottom border width
                            ),
                          ),
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                          vertical: 3.0,
                        ), // Horizontal padding
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap:
                                  _pickFile, // Function to handle file picking
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.rotate(
                                    angle: 45 *
                                        3.1415926535897932 /
                                        180, // Rotate 45 degrees in radians
                                    child: Icon(
                                      Icons.attach_file,
                                      size: 13,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    "파일 추가",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Display selected files
                            ..._selectedFiles.map((file) {
                              return ListTile(
                                leading: Icon(Icons.insert_drive_file),
                                title: Text(file.name),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeFile(file),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Third Tab: History
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: historyList.length + 1, // +1 for header
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border(
                              bottom: BorderSide(
                                color: Colors
                                    .grey[300]!, // 보더 색상 설정 (원하는 색상으로 변경 가능)
                                width: 1.0, // 보더 두께 설정
                              ),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 3.0,
                          ),
                          width: double.infinity,
                          child: Text(
                            "히스토리",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      }
                      final history = historyList[index - 1];
                      final dateTime =
                          DateTime.parse(history['createdAt']).toLocal();

                      // 연, 월, 일, 시, 분 추출
                      final year = dateTime.year;
                      final month = dateTime.month;
                      final day = dateTime.day;
                      final hour = dateTime.hour;
                      final minute = dateTime.minute;

                      // 두 자릿수로 포맷 (필요 시)
                      String twoDigits(int n) => n.toString().padLeft(2, '0');

                      // 포맷된 문자열 생성
                      final createdAt =
                          '$year.${twoDigits(month)}.${twoDigits(day)} ${twoDigits(hour)}:${twoDigits(minute)}';

                      final firstName =
                          history['employeeId']['firstName'] ?? '';
                      final lastName = history['employeeId']['lastName'] ?? '';
                      final action = history['action'] ?? '';

                      return Container(
                        color: Colors.white, // 각 아이템의 배경색을 흰색으로 설정
                        child: ListTile(
                          tileColor: Colors.white, // ListTile의 배경색을 흰색으로 설정
                          leading: CircleAvatar(
                            child: Icon(Icons.person, color: Colors.white),
                            backgroundColor:
                                const Color.fromARGB(255, 227, 227, 227),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$createdAt      $firstName$lastName',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                action,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Fourth Tab: Comments
                  Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: commentsList.length + 1, // +1 for header
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!, // Border color
                                      width: 1.0, // Border width
                                    ),
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 3.0,
                                ),
                                width: double.infinity,
                                child: Text(
                                  "코멘트",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            }

                            final comment = commentsList[index - 1];
                            final dateTime =
                                DateTime.parse(comment['createdAt']).toLocal();

                            // 날짜 및 시간 포맷팅
                            String twoDigits(int n) =>
                                n.toString().padLeft(2, '0');
                            final createdAt =
                                '${dateTime.year}.${twoDigits(dateTime.month)}.${twoDigits(dateTime.day)} ${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}';

                            final firstName =
                                comment['employeeId']['firstName'] ?? '';
                            final lastName =
                                comment['employeeId']['lastName'] ?? '';
                            final content = comment['content'] ?? '';

                            return Container(
                              color: Colors.white,
                              child: ListTile(
                                leading: CircleAvatar(
                                  child:
                                      Icon(Icons.person, color: Colors.white),
                                  backgroundColor:
                                      const Color.fromARGB(255, 227, 227, 227),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$createdAt      $firstName$lastName',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      content,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // 입력 필드와 등록 버튼
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            // 입력 필드
                            Expanded(
                              child: Container(
                                height: 35.0, // 입력 필드 높이 축소
                                decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: Color(0xFFA3A3A3)),
                                      bottom:
                                          BorderSide(color: Color(0xFFA3A3A3)),
                                      left:
                                          BorderSide(color: Color(0xFFA3A3A3)),
                                      // 오른쪽 테두리 제거
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5.0), // 왼쪽 상단 곡선
                                      bottomLeft:
                                          Radius.circular(5.0), // 왼쪽 하단 곡선
                                    ),
                                    color: Colors.white),
                                child: TextField(
                                  controller: _commentController,
                                  style: TextStyle(
                                    fontSize:
                                        14.0, // 입력 텍스트 폰트 크기 조절 (원하는 크기로 변경 가능)
                                    decoration:
                                        TextDecoration.none, // 텍스트 장식 제거
                                    color: Colors.black, // 텍스트 색상 (필요 시 추가)
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '내용을 입력해주세요',
                                    hintStyle: TextStyle(
                                      fontSize: 12.0, // hintText 폰트 크기 축소
                                      color: Colors
                                          .grey[600], // hintText 색상 (선택 사항)
                                      decoration: TextDecoration
                                          .none, // hintText 장식 제거 (필요 시)
                                    ),
                                    border: InputBorder.none, // TextField 보더 제거
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 12.0,
                                    ), // 패딩 조정
                                    counterText:
                                        '', // 최대 글자 수 카운터 숨기기 (maxLength 사용 시)
                                  ),
                                  maxLength: 200, // 최대 200자 입력 제한
                                ),
                              ),
                            ),
                            // 등록 버튼
                            GestureDetector(
                              onTap: _isCommentNotEmpty
                                  ? null
                                  : null, // 버튼 활성화 조건 수정
                              child: Container(
                                height: 35.0, // 입력 필드와 동일한 높이
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: _isCommentNotEmpty
                                          ? Colors.blueAccent
                                          : Color(0xFFA3A3A3),
                                    ),
                                    bottom: BorderSide(
                                      color: _isCommentNotEmpty
                                          ? Colors.blueAccent
                                          : Color(0xFFA3A3A3),
                                    ),
                                    right: BorderSide(
                                      color: _isCommentNotEmpty
                                          ? Colors.blueAccent
                                          : Color(0xFFA3A3A3),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5.0), // 오른쪽 상단 곡선
                                    bottomRight:
                                        Radius.circular(5.0), // 오른쪽 하단 곡선
                                  ),
                                  color: _isCommentNotEmpty
                                      ? Colors.blueAccent // 활성화 시 배경색 #adadad
                                      : Colors.grey, // 비활성화 시 회색
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                alignment: Alignment.center, // 텍스트 수직 중앙 정렬
                                child: Text(
                                  '등록',
                                  style: TextStyle(
                                      color: Colors.white, // 텍스트 색상 흰색

                                      fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 금액을 천 단위로 콤마를 추가하여 문자열로 반환하는 함수
  String _formatNumber(num number) {
    // 숫자를 정수로 변환하여 소수점 제거
    int integerNumber = number.toInt();

    // 정수 부분을 문자열로 변환하고 천 단위로 콤마 추가
    String formattedNumber = integerNumber.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    // 마지막에 붙는 불필요한 콤마 제거
    if (formattedNumber.endsWith(',')) {
      formattedNumber =
          formattedNumber.substring(0, formattedNumber.length - 1);
    }

    return formattedNumber;
  }
}
