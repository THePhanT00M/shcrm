import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReceiptsPage extends StatelessWidget {
  final List<Map<String, String>> dummyData = [
    {
      'status': '작성 중',
      'totalExpenses': '총 지출 1건',
      'title': '6월 경비 지출 건',
      'amount': '₩ 645,250'
    },
    {
      'status': '완료',
      'totalExpenses': '총 지출 3건',
      'title': '7월 경비 지출 건',
      'amount': '₩ 1,150,000'
    },
    {
      'status': '검토 중',
      'totalExpenses': '총 지출 1건',
      'title': '8월 경비 지출 건',
      'amount': '₩ 300,750'
    },
    {
      'status': '작성 중',
      'totalExpenses': '총 지출 2건',
      'title': '9월 경비 지출 건',
      'amount': '₩ 850,500'
    },
    {
      'status': '반려',
      'totalExpenses': '총 지출 1건',
      'title': '10월 경비 지출 건',
      'amount': '₩ 400,000'
    },
    // Add more dummy data as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf0f0f0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF10D9B5),
        elevation: 0,
        toolbarHeight: 140,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF10D9B5), Color(0xFF009EB4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin:
                    EdgeInsets.only(top: 25, right: 10, left: 10, bottom: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            // Add your onPressed code here
                          },
                          child: Text(
                            '지정안함',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '지출',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.add), // Icon for the plus button
                          onPressed: () {
                            // Add your onPressed code here
                          },
                          color: Colors.white, // Adjust the color as needed
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                padding: EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Color(0xFF028490),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/set.svg', // Path to your SVG asset
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
              SizedBox(height: 8), // Space below the search/filter
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
            bottom:
                70), // Add padding to avoid being hidden by the BottomNavigationBar
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: dummyData.length,
          itemBuilder: (context, index) {
            return CustomCard(
              iconPath: 'assets/icons/none_picture.svg', // Placeholder path
              text1: '',
              title: dummyData[index]['title']!,
              amount: dummyData[index]['amount']!,
            );
          },
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String iconPath;
  final String text1;
  final String title;
  final String amount;

  CustomCard({
    required this.iconPath,
    required this.text1,
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
      padding: EdgeInsets.all(20.0),
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
          SvgPicture.asset(
            iconPath,
            height: 80,
            width: 80,
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text1,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF009EB4),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF009EB4),
                    ),
                  ),
                  SizedBox(width: 16),
                ],
              ),
            ],
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SvgPicture.asset(
                'assets/icons/re_icon.svg',
                height: 20,
                width: 14,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
