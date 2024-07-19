import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
      });
    } else {
      _checkToken();
    }
  }

  Future<void> _checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token != null) {
      _navigateToHome();
    } else {
      _navigateToAuthSelection();
    }
  }

  void _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _navigateToAuthSelection() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacementNamed(context, '/auth-selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 화이트로 설정
      body: Center(
        child: _isConnected
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/logo.svg',
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(width: 20), // 로고와 텍스트 사이의 간격
                  const Text(
                    'APP',
                    style: TextStyle(
                      fontSize: 40, // 텍스트 크기 조절
                      fontWeight: FontWeight.bold, // 텍스트 굵기 조절
                      color: Colors.black, // 텍스트 색상 조절
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('인터넷 연결이 필요합니다.'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _checkConnectivity,
                    child: Text('새로고침'),
                  ),
                ],
              ),
      ),
    );
  }
}
