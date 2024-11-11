import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'dart:convert';

class ReportScreen extends StatefulWidget {
  final int? reportId; // 선택된 카테고리 ID를 받을 필드 추가

  ReportScreen({this.reportId});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Map<String, dynamic>> reportsData = [];
  bool isLoading = true;
  bool hasError = false;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final employeeId = await _fetchEmployeeId();
      if (employeeId != null) {
        await _loadReportsData(employeeId);
      } else {
        _showError('로그인 정보가 없습니다. 다시 로그인 해주세요.');
      }
    } catch (e) {
      _showError('오류가 발생했습니다: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    await _fetchData();
  }

  Future<String?> _fetchEmployeeId() async {
    final userData = await _secureStorage.read(key: 'user_data');
    if (userData != null) {
      final userJson = jsonDecode(userData);
      return userJson['employeeId']?.toString();
    }
    return null;
  }

  Future<void> _loadReportsData(String employeeId) async {
    try {
      final data = await ApiService.fetchReportsData(employeeId);
      setState(() {
        reportsData = data;
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

  Widget _buildReportItem(Map<String, dynamic> report) {
    String status = _mapStatus(report['status']);
    String title = report['title'] ?? '제목 없음';
    int reportId = report['reportId'] ?? 0; // Ensure reportId is an integer

    // Placeholder values for expenditure data
    String expenditureCount = '0건';
    String amount = '₩0';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2.0,
      child: InkWell(
        // Make the card tappable
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          // When tapped, pop and return reportId and title
          Navigator.pop(context, {'reportId': reportId, 'title': title});
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: _getStatusColor(report['status']),
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                            color: _getStatusColor(report['status'])),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    // Title and Confirm Icon
                    Row(
                      children: [
                        Icon(Icons.sticky_note_2_outlined,
                            color: _getStatusColor(report['status']), size: 24),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Right Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '총 지출 $expenditureCount',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf0f0f0),
      appBar: AppBar(
        backgroundColor: Color(0xFF009EB4),
        toolbarHeight: 50,
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'))
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  backgroundColor: Colors.white, // 배경색을 흰색으로 설정
                  color: Color(0xFF009EB4), // 프로그레스 인디케이터의 색상 설정
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    itemCount: reportsData.length,
                    itemBuilder: (context, index) {
                      final report = reportsData[index];
                      return _buildReportItem(report);
                    },
                  ),
                ),
    );
  }

  String _mapStatus(String status) {
    switch (status) {
      case 'PENDING':
        return '작성 중';
      case 'APPROVED':
        return '완료';
      case 'REJECTED':
        return '반려';
      default:
        return '알 수 없음';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.blue;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
