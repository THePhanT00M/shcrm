import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'report_registration_screen.dart'; // Import the registration screen
import 'filter_screen.dart'; // Import the filter screen
import '../../services/api_service.dart'; // Import API service
import '../../widgets/custom_card.dart'; // Import CustomCard widget
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage
import 'dart:convert'; // For JSON decoding

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<Map<String, dynamic>> reportsData = [];
  bool isLoading = true;
  bool hasError = false;

  // FlutterSecureStorage 인스턴스 생성
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchEmployeeIdAndReportsData();
  }

  // user_data에서 employeeId를 불러와 데이터를 가져오는 함수
  Future<void> fetchEmployeeIdAndReportsData() async {
    try {
      // FlutterSecureStorage에서 저장된 user_data 불러오기
      String? userData = await _secureStorage.read(key: 'user_data');

      if (userData != null) {
        // JSON 디코딩하여 employeeId 추출
        Map<String, dynamic> userJson = jsonDecode(userData);
        String employeeId = userJson['employeeId'].toString();

        // API 호출하여 보고서 데이터 가져오기
        await fetchReportsData(employeeId);
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 정보가 없습니다. 다시 로그인 해주세요.')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
      print('Error: $e');
    }
  }

  // employeeId를 받아서 보고서 데이터를 가져오는 함수
  Future<void> fetchReportsData(String employeeId) async {
    try {
      final data =
          await ApiService.fetchReportsData(employeeId); // employeeId 전달
      setState(() {
        reportsData = data;
        print(reportsData);
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오지 못했습니다: $e')),
      );

      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf0f0f0),
      appBar: AppBar(
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
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
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
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('데이터를 불러오지 못했습니다.'),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: fetchEmployeeIdAndReportsData,
                        child: Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(bottom: 70),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    itemCount: reportsData.length,
                    itemBuilder: (context, index) {
                      return CustomCard(
                        status: reportsData[index]['status']!,
                        title: reportsData[index]['title']!,
                      );
                    },
                  ),
                ),
    );
  }
}
