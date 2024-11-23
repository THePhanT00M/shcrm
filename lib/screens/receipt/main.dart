import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'filter_screen.dart';
import 'receipt_registration_screen.dart';
import 'statistics.dart';
import '../../services/api_service.dart';

class ReceiptsPage extends StatefulWidget {
  @override
  _ReceiptsPageState createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  List<Map<String, dynamic>> receiptData = [];
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
        await _loadReceiptData(employeeId);
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

  Future<void> _loadReceiptData(String employeeId) async {
    try {
      final data = await ApiService.fetchExpensesData(employeeId);
      setState(() {
        receiptData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        receiptData = [];
        isLoading = false;
      });
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
      backgroundColor: Color(0xFFf0f0f0),
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : receiptData.isEmpty
              ? _buildNoReceiptsMessage()
              : _buildReceiptList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReceiptRegistrationScreen()),
          ).then((result) {
            if (result == true) {
              _refreshData();
            }
          });
        },
        backgroundColor: Color(0xFF009EB4),
        child: Icon(Icons.add),
      ),
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
                  '지출',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              Positioned(
                left: 0,
                top: 6,
                child: Text('지정안함',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ),
              Positioned(
                right: 0,
                top: -4,
                child: Padding(
                  padding: EdgeInsets.all(8.0), // 원하는 만큼 여백을 조정
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Statistics()),
                      );
                    },
                    child: FaIcon(
                      FontAwesomeIcons.chartPie,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FilterScreen()));
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                  color: Color(0xFF028490),
                  borderRadius: BorderRadius.circular(8.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/icons/set.svg',
                      height: 16,
                      colorFilter:
                          ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                  SizedBox(width: 8),
                  Text('검색 및 필터',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReceiptsMessage() {
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
                '등록된 지출이 없습니다.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      color: Color(0xFF009EB4), // 프로그레스 인디케이터의 색상 설정
      child: Padding(
        padding: EdgeInsets.only(bottom: 70),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          itemCount: receiptData.length,
          itemBuilder: (context, index) {
            final receipt = receiptData[index];
            return ReceiptCard(
              expenseId: receipt['expenseId'],
              iconPath: receipt['url'] ?? 'assets/icons/none_picture.svg',
              status: receipt['status'] ?? ' ',
              merchantName: receipt['merchantName'] ?? '제목 없음',
              amount: receipt['amount'] ?? 0,
            );
          },
        ),
      ),
    );
  }
}

class ReceiptCard extends StatelessWidget {
  final int expenseId;
  final String iconPath;
  final String status;
  final String merchantName;
  final int amount;

  ReceiptCard({
    required this.expenseId,
    required this.iconPath,
    required this.status,
    required this.merchantName,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ReceiptRegistrationScreen(expenseId: expenseId),
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

        // 새로 고침 실행
        if (result == true) {
          context.findAncestorStateOfType<_ReceiptsPageState>()?._refreshData();
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15.0),
        padding: EdgeInsets.all(10.0),
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
            _buildIcon(),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status,
                    style: TextStyle(fontSize: 12, color: Color(0xFF009EB4))),
                SizedBox(height: 8),
                Text(merchantName,
                    style: TextStyle(fontSize: 16, color: Color(0xFF009EB4))),
              ],
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SvgPicture.asset(
                  'assets/icons/money.svg',
                  height: 20,
                  width: 20,
                ),
                SizedBox(height: 2),
                Text('₩${_formatNumber(amount)}',
                    style: TextStyle(fontSize: 16, color: Color(0xFF333333))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (iconPath.endsWith('.svg')) {
      return SvgPicture.asset(
        iconPath,
        height: 50,
        width: 50,
        placeholderBuilder: (BuildContext context) => Container(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Image.network(
        iconPath,
        height: 50,
        width: 50,
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          // 오류 로그 출력
          print('이미지 로딩 실패: $exception');
          // 대체 이미지 반환
          return SvgPicture.asset(
            'assets/icons/none_picture.svg',
            height: 50,
            width: 50,
          );
        },
      );
    }
  }

  /// 금액을 천 단위로 콤마를 추가하여 문자열로 반환하는 함수
  String _formatNumber(num number) {
    // 숫자를 정수로 변환하여 소수점 제거
    int integerNumber = number.toInt();

    // 정수 부분을 문자열로 변환하고 천 단위로 콤마 추가
    String formattedNumber = integerNumber.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (Match m) => '${m[1]},',
        );

    return formattedNumber;
  }
}
