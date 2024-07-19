import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReportsPage extends StatelessWidget {
  final List<Map<String, String>> dummyData = [
    {
      'status': '작성 중',
      'totalExpenses': '총 지출 0건',
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
      body: Column(
        children: [
          Container(
            height:
                170, // Adjust height to accommodate both title and search/filter
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF10D9B5), Color(0xFF009EB4)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Center(
                      child: Text(
                        '보고서',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            '지정안함',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height: 8), // Spacing between the title and search/filter
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Color(
                          0xFF028490), // Background color for the search/filter section
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/set.svg', // Path to your SVG asset
                          height: 16, // Adjust the height to fit your design
                          colorFilter: ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8), // Spacing between the icon and text
                        Text(
                          '검색 및 필터',
                          textAlign: TextAlign.center,
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
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: Color(0xFFf0f0f0), // body background color
                ),
                ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
                  itemCount: dummyData.length,
                  itemBuilder: (context, index) {
                    return CustomCard(
                      status: dummyData[index]['status']!,
                      totalExpenses: dummyData[index]['totalExpenses']!,
                      title: dummyData[index]['title']!,
                      amount: dummyData[index]['amount']!,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String status;
  final String totalExpenses;
  final String title;
  final String amount;

  CustomCard({
    required this.status,
    required this.totalExpenses,
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    Color getStatusColor(String status) {
      switch (status) {
        case '반려':
          return Colors.red;
        case '작성 중':
          return Color(0xFF10D9B5);
        case '완료':
          return Color(0xFF0088D4);
        case '검토 중':
          return Colors.yellow;
        default:
          return Colors.black;
      }
    }

    Color getTextColor(Color backgroundColor) {
      double luminance = backgroundColor.computeLuminance();
      return luminance > 0.7 ? Colors.black : Colors.white;
    }

    Color statusColor = getStatusColor(status);
    Color textColor = getTextColor(statusColor);

    return ClipRRect(
      child: Container(
        width: double.infinity,
        height: 98,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5),
            bottomLeft: Radius.circular(5),
            topRight: Radius.circular(13),
            bottomRight: Radius.circular(13),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 7,
              height: double.infinity,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                            ),
                          ),
                        ),
                        Text(
                          totalExpenses,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/file_folder.svg', // Path to your SVG asset
                          width: 30,
                          height: 37, // Adjust the height to fit your design
                          colorFilter: ColorFilter.mode(
                            statusColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          amount,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 7), // Adding padding to the right side
          ],
        ),
      ),
    );
  }
}
