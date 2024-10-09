import 'package:flutter/material.dart';

class ReportRegistrationScreen extends StatefulWidget {
  final String? title;
  final String? amount;
  final String? totalExpenses;

  ReportRegistrationScreen({this.title, this.amount, this.totalExpenses});

  @override
  _ReportRegistrationScreenState createState() =>
      _ReportRegistrationScreenState();
}

class _ReportRegistrationScreenState extends State<ReportRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // 현재 선택된 화면 상태 관리
  int _selectedSection = 0; // 0: 첫 번째 화면, 1: 두 번째 화면, 2: 세 번째 화면, 3: 네 번째 화면

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.title != null &&
        widget.amount != null &&
        widget.totalExpenses != null;

    return Scaffold(
      backgroundColor: Color(0xFFf0f0f0),
      appBar: AppBar(
        backgroundColor: Color(0xFF10D9B5), // AppBar 배경색 설정
        toolbarHeight: 60, // 높이 조정
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Colors.white, size: 24), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications,
                color: Colors.white, size: 24), // 알림 아이콘
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.info_outline,
                color: Colors.white, size: 24), // 정보 아이콘
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 상단 섹션: 새 보고서 + 총 0건 섹션
          Container(
            padding: EdgeInsets.only(
                top: 0.0,
                left: 16.0,
                right: 16.0,
                bottom: 10.0), // 하단 패딩을 추가하여 배경색 확장
            decoration: BoxDecoration(
              color: Color(0xFF10D9B5), // 배경색 설정
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '새 보고서',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8), // 텍스트와 연필 아이콘 간격
                    Icon(
                      Icons.edit, // 연필 아이콘
                      color: Colors.white,
                      size: 24,
                    ),
                    Spacer(), // 오른쪽 아이콘 정렬을 위한 Spacer
                  ],
                ),
                SizedBox(height: 5),
                _buildReportTypeAndPolicyButtons(), // 보고서 타입, 일반 버튼과 폴리시, 지정안함 버튼 그룹화
                SizedBox(height: 5), // 버튼 아래에 여유 공간 추가

                // 총 0건 섹션
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white, // 위젯 배경 흰색
                    borderRadius: BorderRadius.circular(8), // 둥근 모서리
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '총 0건',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.teal,
                            ),
                          ),
                          SizedBox(width: 10), // '총 0건'과 구분자 사이 간격
                          Text(
                            '|', // 구분자
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      // 총 보고 금액과 경비 한급 금액을 같은 열에 배치
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '총 보고 금액',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 85), // 금액과 간격
                              Text(
                                '₩ 0',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5), // 총 보고 금액과 경비 한급 금액 사이 간격
                          Row(
                            children: [
                              Text(
                                '경비 한급 금액',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 70), // 금액과 간격
                              Text(
                                '₩ 0',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.teal[50], // 그래프 아이콘 배경색
                          borderRadius: BorderRadius.circular(8), // 둥근 모서리 처리
                        ),
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.bar_chart,
                          size: 40,
                          color: Colors.teal, // 그래프 아이콘 색상
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 네 가지 버튼으로 구성된 탭 메뉴
          Container(
            color: Colors.white, // 배경색 설정
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.receipt_long),
                  onPressed: () {
                    setState(() {
                      _selectedSection = 0; // 첫 번째 화면 선택
                    });
                  },
                  color: _selectedSection == 0 ? Colors.teal : Colors.grey,
                ),
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: () {
                    setState(() {
                      _selectedSection = 1; // 두 번째 화면 선택
                    });
                  },
                  color: _selectedSection == 1 ? Colors.teal : Colors.grey,
                ),
                IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () {
                    setState(() {
                      _selectedSection = 2; // 세 번째 화면 선택
                    });
                  },
                  color: _selectedSection == 2 ? Colors.teal : Colors.grey,
                ),
                IconButton(
                  icon: Icon(Icons.chat_bubble),
                  onPressed: () {
                    setState(() {
                      _selectedSection = 3; // 네 번째 화면 선택
                    });
                  },
                  color: _selectedSection == 3 ? Colors.teal : Colors.grey,
                ),
              ],
            ),
          ),

          // 배경색 없는 세션: 네 가지 화면 중 선택된 화면이 표시됨
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: _getSelectedSection(_selectedSection), // 선택된 화면을 표시
            ),
          ),
        ],
      ),
    );
  }

  // 보고서 타입과 폴리시 버튼 빌드 함수
  Widget _buildReportTypeAndPolicyButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 첫 번째 버튼: 보고서 타입 + 일반
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                // 특정 버튼 선택 상태 관리 (필요시)
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '보고서 타입',
                  style: TextStyle(
                    color: Colors.white, // 텍스트 색상을 흰색으로
                  ),
                ),
                SizedBox(width: 30),
                Text(
                  '일반',
                  style: TextStyle(
                    color: Colors.white, // 텍스트 색상을 흰색으로
                  ),
                ),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF007792), // 배경색 설정
              minimumSize: Size(double.infinity, 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        // 두 번째 버튼: 폴리시 + 지정안함
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                // 다른 버튼 선택 상태 관리
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '폴리시',
                  style: TextStyle(
                    color: Colors.white, // 텍스트 색상을 흰색으로
                  ),
                ),
                SizedBox(width: 30),
                Text(
                  '지정 안함',
                  style: TextStyle(
                    color: Colors.white, // 텍스트 색상을 흰색으로
                  ),
                ),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF007792), // 배경색 설정
              minimumSize: Size(double.infinity, 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 선택된 화면에 따라 다른 위젯을 표시
  Widget _getSelectedSection(int index) {
    if (index == 0) {
      return _firstSection();
    } else if (index == 1) {
      return _secondSection();
    } else if (index == 2) {
      return _thirdSection();
    } else {
      return _fourthSection();
    }
  }

  // 첫 번째 화면 내용
  Widget _firstSection() {
    return Center(
      child: Text('첫 번째 화면의 내용입니다.'),
    );
  }

  // 두 번째 화면 내용
  Widget _secondSection() {
    return Center(
      child: Text('두 번째 화면의 내용입니다.'),
    );
  }

  // 세 번째 화면 내용
  Widget _thirdSection() {
    return Center(
      child: Text('세 번째 화면의 내용입니다.'),
    );
  }

  // 네 번째 화면 내용
  Widget _fourthSection() {
    return Center(
      child: Text('네 번째 화면의 내용입니다.'),
    );
  }
}
