import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF073F7D), Color(0xFF1A2E43)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '피드',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: Colors.white, // body 배경색 흰색으로 설정
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '피드가 없습니다.',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '새로운 알림이 등록되면 피드에서 알려드립니다.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 30, // 바텀 네비게이션 바보다 50px 위로 이동
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.camera_alt),
                        label: Text('촬영'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          backgroundColor:
                              Color(0xFF007AE1), // background color
                          foregroundColor: Colors.white, // text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.edit),
                        label: Text('셀프'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          backgroundColor:
                              Color(0xFF05A3DE), // background color
                          foregroundColor: Colors.white, // text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white, // BottomNavigationBar 배경색을 흰색으로 설정
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'label',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'label',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'label',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'label',
          ),
        ],
      ),
    );
  }
}
