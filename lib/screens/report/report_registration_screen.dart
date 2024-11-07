import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _initializeNewReport(String employeeId) {
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchData() async {
    try {
      final employeeId = await _fetchEmployeeId();
      _employeeId = employeeId;
      if (employeeId != null) {
        if (widget.reportId != null) {
          await _loadReceiptData(employeeId);
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

  Future<void> _loadReceiptData(String employeeId) async {
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

      setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFefefef),
      appBar: AppBar(
        backgroundColor: Color(0xFF009EB4),
        toolbarHeight: 60,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 24, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
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
                        '새 보고서',
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
                        color: Colors.grey[50], // Background color
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
                        padding: EdgeInsets.all(16.0),
                        alignment: Alignment.center,
                        child: Text(
                          "탭 2 내용",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  // Third Tab: History
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
                          "히스토리",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        alignment: Alignment.center,
                        child: Text(
                          "탭 3 내용",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  // Fourth Tab: Comments
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
                          "코멘트",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        alignment: Alignment.center,
                        child: Text(
                          "탭 4 내용",
                          style: TextStyle(fontSize: 16),
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
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
