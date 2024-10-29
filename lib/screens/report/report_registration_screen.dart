import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // 데이터 항목과 입력 날짜를 관리하는 리스트
  final List<Map<String, dynamic>> _items = [
    {
      'title': '은사 즉석떡볶이',
      'amount': '₩ 14,500',
      'date': DateTime(2024, 8, 8),
      'description': '미지정',
    },
    {
      'title': '식대비',
      'amount': '₩ 70,070',
      'date': DateTime(2024, 8, 9),
      'description': '미입력',
    },
  ];

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
                            '총 ${_items.length}건',
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
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final formattedDate =
            DateFormat('yyyy.MM.dd EEE', 'ko_KR').format(item['date']);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 날짜 표시 버튼 스타일
            Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              margin: EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                formattedDate,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 3)],
              ),
              child: Row(
                children: [
                  Image.network(
                    'https://via.placeholder.com/50', // 이미지 URL 또는 Asset 경로
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        item['description'],
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  Spacer(),
                  Text(
                    item['amount'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // 두 번째 화면 내용
  Widget _secondSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 첨부파일 텍스트
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Text(
            '첨부파일',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 90, 90, 90),
            ),
          ),
        ),

        // 파일 추가 버튼과 스크린샷 정보가 포함된 앱바 스타일 컨테이너
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Column(
            children: [
              // 파일 추가 버튼
              GestureDetector(
                onTap: () {
                  // 파일 추가 기능을 여기에 구현
                  print("파일 추가 버튼이 클릭되었습니다.");
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attach_file, color: Colors.black), // 종이클립 아이콘
                    SizedBox(width: 8), // 아이콘과 텍스트 사이 간격
                    Text(
                      '파일 추가',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 구분선
              Divider(
                color: Colors.grey,
                thickness: 1.0,
                height: 20.0,
              ),

              // 스크린샷 이미지와 파일 정보
              Row(
                children: [
                  // 이미지 아이콘
                  Image.network(
                    'https://via.placeholder.com/50', // 임시 이미지 URL
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 10), // 이미지와 텍스트 사이 간격

                  // 파일 정보 텍스트
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '스크린샷 2024-08-07 3847.png',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '파일 크기: 1.2 MB',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 세 번째 화면 내용
  Widget _thirdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 히스토리 텍스트
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Text(
            '히스토리',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),

        // 히스토리 항목들
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final formattedDate =
                  DateFormat('yyyy.MM.dd HH:mm').format(item['date']);

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 1), // 그림자 위치
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 날짜, 시간, 작성자 정보 표시
                      Text(
                        '$formattedDate 홍길동', // 날짜, 시간, 작성자 정보
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      SizedBox(height: 5),

                      // 보고서 생성 문구
                      Text(
                        '보고서가 생성되었습니다.', // 보고서 생성 문구
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 네 번째 화면 내용
  Widget _fourthSection() {
    return Column(
      children: [
        // 상단에 "코멘트" 텍스트와 구분선 추가
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Row(
            children: [
              Text(
                '코멘트',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(221, 94, 94, 94),
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.grey,
          thickness: 1,
          height: 1, // 구분선 두께
        ),
        Spacer(), // 아이콘과 텍스트 위 여백 추가
        Icon(
          Icons.chat_bubble_outline,
          size: 60,
          color: Colors.grey,
        ),
        SizedBox(height: 10),
        Text(
          '코멘트가 없습니다.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        Spacer(flex: 2), // 하단 여백 추가로 더 아래로 내림
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '내용을 입력해주세요.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // 등록 버튼 눌렀을 때 동작 추가
                },
                child: Text('등록'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(60, 50),
                  backgroundColor: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
