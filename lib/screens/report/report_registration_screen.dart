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
            // 공통 영역
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
                            color: Colors.white),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '총 보고 금액',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.black87),
                                  ),
                                  Text(
                                    '₩1111',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '경비 환급 금액',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.blue),
                                  ),
                                  Text(
                                    '₩1111',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.w700),
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
                  )
                ],
              ),
            ),
            // TabBar 및 TabBarView 추가
            Container(
              color: Colors.white, // 탭 배경을 화이트로 설정
              child: TabBar(
                labelColor: Color(0xFF009EB4),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF009EB4),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(icon: Icon(Icons.description)), // 종이 아이콘
                  Tab(icon: Icon(Icons.attach_file)), // 첨부 파일 아이콘
                  Tab(icon: Icon(Icons.history)), // 히스토리 아이콘
                  Tab(icon: Icon(Icons.chat)), // 대화 아이콘
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                    children: [
                      Container(
                        color: Colors.grey[50], // 배경색 설정
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 3.0), // 좌우 패딩만 설정
                        width: double.infinity, // 너비 100% 설정
                        child: Text(
                          "지출 1건",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[600]),
                        ),
                      ),
                      Container(
                        //color: Colors.white,
                        padding: EdgeInsets.all(16.0),
                        alignment: Alignment.center, // 두 번째 컨테이너는 가운데 정렬 유지
                        child: Text(
                          "탭 1 내용",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                    children: [
                      Container(
                        color: Colors.grey[50], // 배경색 설정
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 3.0), // 좌우 패딩만 설정
                        width: double.infinity, // 너비 100% 설정
                        child: Text(
                          "첨부파일",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[600]),
                        ),
                      ),
                      Container(
                        //color: Colors.white,
                        padding: EdgeInsets.all(16.0),
                        alignment: Alignment.center, // 두 번째 컨테이너는 가운데 정렬 유지
                        child: Text(
                          "탭 1 내용",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                    children: [
                      Container(
                        color: Colors.grey[50], // 배경색 설정
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 3.0), // 좌우 패딩만 설정
                        width: double.infinity, // 너비 100% 설정
                        child: Text(
                          "히스토리",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[600]),
                        ),
                      ),
                      Container(
                        //color: Colors.white,
                        padding: EdgeInsets.all(16.0),
                        alignment: Alignment.center, // 두 번째 컨테이너는 가운데 정렬 유지
                        child: Text(
                          "탭 1 내용",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                    children: [
                      Container(
                        color: Colors.grey[50], // 배경색 설정
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 3.0), // 좌우 패딩만 설정
                        width: double.infinity, // 너비 100% 설정
                        child: Text(
                          "코멘트",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[600]),
                        ),
                      ),
                      Container(
                        //color: Colors.white,
                        padding: EdgeInsets.all(16.0),
                        alignment: Alignment.center, // 두 번째 컨테이너는 가운데 정렬 유지
                        child: Text(
                          "탭 1 내용",
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
}
