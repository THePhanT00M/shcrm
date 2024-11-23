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

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  // Explicit TabController
  late TabController _tabController;

  // Data for "내 보고서" (My Reports)
  List<Map<String, dynamic>> reportsData = [];
  bool isLoadingReports = true;
  bool hasErrorReports = false;

  // Data for "결제 요청 보고서" (Payment Request Reports)
  List<Map<String, dynamic>> paymentReportsData = [];
  bool isLoadingPayments = true;
  bool hasErrorPayments = false;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // Initialize TabController with length 2 for two tabs
    _tabController = TabController(length: 2, vsync: this);
    _fetchAllData();

    // Optionally, listen to tab changes if needed
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Handle tab change if necessary
        // For example, you can refresh data when the user switches tabs
      }
    });
  }

  // Fetch data for both tabs
  Future<void> _fetchAllData() async {
    await Future.wait([
      _fetchReportsData(),
      _fetchPaymentReportsData(),
    ]);
  }

  // Refresh data based on the current tab index
  Future<void> _refreshData(int tabIndex) async {
    if (tabIndex == 0) {
      await _fetchReportsData();
    } else if (tabIndex == 1) {
      await _fetchPaymentReportsData();
    }
  }

  // Fetch employee ID from secure storage
  Future<String?> _fetchEmployeeId() async {
    final userData = await _secureStorage.read(key: 'user_data');
    if (userData != null) {
      final userJson = jsonDecode(userData);
      return userJson['employeeId']?.toString();
    }
    return null;
  }

  // Fetch data for "내 보고서"
  Future<void> _fetchReportsData() async {
    setState(() {
      isLoadingReports = true;
      hasErrorReports = false;
    });

    try {
      final employeeId = await _fetchEmployeeId();
      if (employeeId != null) {
        final data = await ApiService.fetchReportsData(employeeId);
        if (!mounted) return;
        setState(() {
          reportsData = data;
          isLoadingReports = false;
        });
      } else {
        _showError('로그인 정보가 없습니다. 다시 로그인 해주세요.', isPayment: false);
      }
    } catch (e) {
      setState(() {
        reportsData = [];
        isLoadingReports = false;
        hasErrorReports = true;
      });
      //_showError('데이터를 불러오지 못했습니다: $e', isPayment: false);
    }
  }

  // Fetch data for "결제 요청 보고서"
  Future<void> _fetchPaymentReportsData() async {
    setState(() {
      isLoadingPayments = true;
      hasErrorPayments = false;
    });

    try {
      final employeeId = await _fetchEmployeeId();
      if (employeeId != null) {
        final data = await ApiService.fetchReportPaymentsData(employeeId);
        if (!mounted) return;
        setState(() {
          paymentReportsData = data;
          isLoadingPayments = false;
        });
      } else {
        _showError('로그인 정보가 없습니다. 다시 로그인 해주세요.', isPayment: true);
      }
    } catch (e) {
      setState(() {
        paymentReportsData = [];
        isLoadingPayments = false;
        hasErrorPayments = true;
      });
      //_showError('데이터를 불러오지 못했습니다: $e', isPayment: true);
    }
  }

  // Display error messages using SnackBar
  void _showError(String message, {required bool isPayment}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    setState(() {
      if (isPayment) {
        isLoadingPayments = false;
        hasErrorPayments = true;
      } else {
        isLoadingReports = false;
        hasErrorReports = true;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Build the list of reports based on the provided data and state
  Widget _buildReportsList(
    List<Map<String, dynamic>> data,
    bool isLoading,
    bool hasError,
    Future<void> Function() onRefresh,
  ) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (hasError) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        backgroundColor: Colors.white,
        color: Color(0xFF009EB4),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 180,
              color: Color(0xFFf0f0f0),
              child: Center(
                child: Text(
                  '',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (data.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        backgroundColor: Colors.white,
        color: Color(0xFF009EB4),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 180,
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
    } else {
      return RefreshIndicator(
        onRefresh: onRefresh,
        backgroundColor: Colors.white,
        color: Color(0xFF009EB4),
        child: Padding(
          padding: EdgeInsets.only(bottom: 70),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final report = data[index];
              return CustomCard(
                reportId: report['reportId']!,
                status: report['status']!,
                title: report['title']!,
                onRefresh:
                    onRefresh, // Correctly passed as Future<void> Function()
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf0f0f0),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Move TabBar from AppBar to body
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController, // Assign TabController
              labelColor: Color(0xFF009EB4),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF009EB4),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: '내 보고서'),
                Tab(text: '결제 요청 보고서'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 첫번째 탭: 내 보고서 (My Reports)
                _buildReportsList(
                  reportsData,
                  isLoadingReports,
                  hasErrorReports,
                  () => _refreshData(0), // Correctly passing tabIndex 0
                ),
                // 두번째 탭: 결제 요청 보고서 (Payment Request Reports)
                _buildReportsList(
                  paymentReportsData,
                  isLoadingPayments,
                  hasErrorPayments,
                  () => _refreshData(1), // Correctly passing tabIndex 1
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the AppBar without TabBar
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
                    // Refresh data based on the current tab
                    await _refreshData(_tabController.index);
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
}

class CustomCard extends StatelessWidget {
  final int reportId;
  final String status;
  final String title;
  final Future<void> Function() onRefresh; // Correctly typed

  CustomCard({
    required this.reportId,
    required this.status,
    required this.title,
    required this.onRefresh, // Correctly passed
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () async {
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
        await onRefresh(); // Correctly await the refresh callback
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

  // Determine the color based on the status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.blue;
      case 'SUBMITTED':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get the status text based on the status code
  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return '작성 중';
      case 'SUBMITTED':
        return '상신';
      case 'APPROVED':
        return '완료';
      case 'REJECTED':
        return '반려';
      default:
        return '알 수 없음';
    }
  }
}
