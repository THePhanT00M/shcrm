import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'feed/main.dart';
import 'report/main.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _buildNavItem(
      String iconPath, String label, int index) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        iconPath,
        height: 24,
        width: 24,
        colorFilter: ColorFilter.mode(
          _selectedIndex == index ? Color(0xFF10D9B5) : Color(0xFF666666),
          BlendMode.srcIn,
        ),
      ),
      label: label,
    );
  }

  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return NotificationsPage();
      case 1:
        return ReportsPage();
      case 2:
        return BoardPage();
      case 3:
        return MyPage();
      default:
        return Container();
    }
  }

  Widget _buildFloatingButtons() {
    if (_selectedIndex == 2 || _selectedIndex == 3) {
      return SizedBox.shrink();
    }

    return Positioned(
      bottom: 30, // 바텀 네비게이션 바보다 50px 위로 이동
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.camera_alt,
              size: 14,
            ),
            label: const Text('촬영'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
              backgroundColor: const Color(0xFF0088D4), // background color
              foregroundColor: Colors.white, // text color
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.edit,
              size: 14,
            ),
            label: const Text('셀프'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
              backgroundColor: const Color(0xFF0CCEAB), // background color
              foregroundColor: Colors.white, // text color
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Center(child: _getSelectedPage(_selectedIndex)),
            _buildFloatingButtons(),
          ],
        ),
        bottomNavigationBar: Container(
          height: 80, // Set the height of the BottomNavigationBar
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor:
                Colors.white, // BottomNavigationBar background color
            selectedItemColor: Color(0xFF10D9B5), // Selected item color
            unselectedItemColor: Color(0xFF666666), // Unselected item color
            selectedFontSize: 12, // Set the font size for selected items
            unselectedFontSize: 12, // Set the font size for unselected items
            iconSize: 24, // Set the icon size to be consistent
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              _buildNavItem('assets/icons/icon1.svg', '알림', 0),
              _buildNavItem('assets/icons/icon2.svg', '보고서', 1),
              _buildNavItem('assets/icons/icon3.svg', '보드', 2),
              _buildNavItem('assets/icons/icon4.svg', '마이', 3),
            ],
          ),
        ),
      ),
    );
  }
}

class BoardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('보드 페이지'));
  }
}

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('마이 페이지'));
  }
}
