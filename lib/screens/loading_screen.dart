import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isConnected = true;

  // Create an instance of FlutterSecureStorage
  final _secureStorage = const FlutterSecureStorage();

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
    // Get token from secure storage
    String? token = await _secureStorage.read(key: 'jwt_token');

    if (token != null) {
      try {
        // Decode the JWT
        final jwt = JWT.decode(token);

        // Get the current time
        final currentTime =
            DateTime.now().millisecondsSinceEpoch ~/ 1000; // In seconds

        // Check the 'exp' field from the token payload
        if (jwt.payload['exp'] != null && jwt.payload['exp'] > currentTime) {
          // Token is still valid, navigate to home
          _navigateToHome();
        } else {
          // Token is expired, navigate to auth selection
          _navigateToAuthSelection();
        }
      } catch (e) {
        // In case of any error (invalid token or other), navigate to auth selection
        _navigateToAuthSelection();
      }
    } else {
      // No token found, navigate to auth selection
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
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
