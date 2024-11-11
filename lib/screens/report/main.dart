import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'report_registration_screen.dart';
import 'filter_screen.dart';
import '../../services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
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
      if (!mounted) return; // Ensure the widget is still mounted
      setState(() {
        reportsData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        reportsData = [];
        isLoading = false;
      });
      //_showError('데이터를 불러오지 못했습니다: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return; // Check if the widget is still mounted
    setState(() {
      isLoading = false;
      hasError = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf0f0f0),
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : reportsData.isEmpty
              ? _buildNoReportsMessage()
              : _buildReportsList(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFF009EB4),
      toolbarHeight: 120,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Column(
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  '보고서',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 3,
                child: GestureDetector(
                  onTap: () async {
                    // 수정된 부분: Navigator.push를 await하고 _refreshData 호출
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ReportRegistrationScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                    _refreshData(); // 데이터 새로고침
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FilterScreen()),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Color(0xFF028490),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/set.svg',
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '검색 및 필터',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReportsMessage() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      backgroundColor: Colors.white,
      color: Color(0xFF009EB4),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(), // 항상 스크롤 가능하게 설정
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 180, // 높이 조절
            color: Color(0xFFf0f0f0),
            child: Center(
              child: Text(
                '등록된 보고서가 없습니다.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      color: Color(0xFF009EB4), // 프로그레스 인디케이터의 색상 설정
      child: Padding(
        padding: EdgeInsets.only(bottom: 70),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          itemCount: reportsData.length,
          itemBuilder: (context, index) {
            final report = reportsData[index];
            return CustomCard(
              reportId: report['reportId']!,
              status: report['status']!,
              title: report['title']!,
              onRefresh: _refreshData, // 수정된 부분: 콜백 전달
            );
          },
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final int reportId;
  final String status;
  final String title;
  final VoidCallback onRefresh; // 추가된 부분

  CustomCard({
    required this.reportId,
    required this.status,
    required this.title,
    required this.onRefresh, // 추가된 부분
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () async {
        // 수정된 부분: Navigator.push를 await하고 onRefresh 호출
        await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ReportRegistrationScreen(reportId: reportId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                  position: animation.drive(tween), child: child);
            },
          ),
        );
        onRefresh(); // 데이터 새로고침 콜백 호출
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15.0),
        padding: EdgeInsets.only(right: 15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 71,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8)),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          _getStatusText(status),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
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

  String _getStatusText(String status) {
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
}
