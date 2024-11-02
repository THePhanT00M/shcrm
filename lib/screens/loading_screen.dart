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
    final appBarHeight = AppBar().preferredSize.height; // 앱바 기본 높이 가져오기

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: appBarHeight),
          child: _isConnected
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/logo.svg',
                      width: 60,
                      height: 60,
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'APP',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
      ),
    );
  }
}
