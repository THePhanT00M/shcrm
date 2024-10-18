import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'feed/main.dart';
import 'receipt/main.dart';
import 'report/main.dart';
import 'mypage/main.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isOverlayVisible = false;
  final ImagePicker _picker = ImagePicker();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
  }

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // Handle the captured image here
      print('Image Path: ${image.path}');
      // You can also navigate to another page to display the image or process it further
    }
  }

  BottomNavigationBarItem _buildNavItem(
      String iconPath, String label, int index) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        iconPath,
        height: 24,
        width: 24,
        colorFilter: ColorFilter.mode(
          _selectedIndex == index ? Color(0xFF009EB4) : Color(0xFF666666),
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
        return ReceiptsPage();
      case 2:
        return ReportsPage();
      case 3:
        return MyPage();
      default:
        return Container();
    }
  }

  Widget _buildFloatingButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _openCamera,
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
            backgroundColor: const Color(0xFF009EB4), // background color
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
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70, // Set your desired height here
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white, // BottomNavigationBar 배경 색상
                  selectedItemColor: Color(0xFF009EB4), // 선택된 항목 색상
                  unselectedItemColor: Color(0xFF666666), // 선택되지 않은 항목 색상
                  selectedFontSize: 12, // 선택된 항목의 폰트 크기
                  unselectedFontSize: 12, // 선택되지 않은 항목의 폰트 크기
                  iconSize: 24, // 아이콘 크기
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  items: [
                    _buildNavItem('assets/icons/icon1.svg', '알림', 0),
                    _buildNavItem('assets/icons/receipt.svg', '지출', 1),
                    _buildNavItem('assets/icons/icon2.svg', '보고서', 2),
                    _buildNavItem('assets/icons/icon4.svg', '마이', 3),
                  ],
                ),
              ),
            ),
            if (_selectedIndex != 2 && _selectedIndex != 3)
              Positioned(
                bottom: 45,
                left: MediaQuery.of(context).size.width / 2 - 25,
                child: GestureDetector(
                  onTap: _toggleOverlay,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF009EB4), // 배경 색상
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white, // 아이콘 색상
                      size: 30, // 아이콘 크기
                    ),
                  ),
                ),
              ),
            if (_isOverlayVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleOverlay,
                  child: Container(
                    color: Colors.black54,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildFloatingButtons(),
                        SizedBox(height: 130),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
