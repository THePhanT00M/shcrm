import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacementNamed(context, '/auth-selection');
    //Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 화이트로 설정
      body: Center(
        child: _isConnected
            ? Image.asset('assets/loading.png')
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
