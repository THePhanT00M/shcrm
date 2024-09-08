import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _idFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscureText = true;
  String _errorMessage = '';

  // Create an instance of FlutterSecureStorage
  final _secureStorage = const FlutterSecureStorage();

  void _showAlertDialog(String message) {
    if (!mounted) return; // Check if the widget is still mounted
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _login() async {
    final id = _idController.text;
    final password = _passwordController.text;

    // Regex pattern for validating only digits
    final numberRegex = RegExp(r'^\d+$');

    if (id.isEmpty) {
      _showAlertDialog('아이디를 입력해 주세요.');
      _idFocusNode.requestFocus();
      return;
    }

    if (!numberRegex.hasMatch(id)) {
      _showAlertDialog('숫자만 입력해 주세요.');
      _idFocusNode.requestFocus();
      return;
    }

    if (password.isEmpty) {
      _showAlertDialog('비밀번호를 입력해 주세요.');
      _passwordFocusNode.requestFocus();
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8080/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'employeeId': id, 'password': password}),
      );

      if (!mounted) return; // Check if the widget is still mounted

      if (response.statusCode == 200) {
        // Extract token from response headers
        final token = response.headers[
            'authorization']; // Assume token is in the 'authorization' header
        print(token);

        if (token != null) {
          // Store the token securely using FlutterSecureStorage
          await _secureStorage.write(key: 'jwt_token', value: token);

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            _errorMessage = '로그인 응답에서 토큰을 찾을 수 없습니다.';
          });
        }
      } else {
        _showAlertDialog('아이디 또는 비밀번호가 일치하지 않습니다.');
      }
    } catch (e) {
      if (mounted) {
        _showAlertDialog('네트워크 오류가 발생했습니다. 인터넷 연결을 확인해 주세요.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고와 텍스트 APP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/logo.svg', // 로고 이미지 경로를 올바르게 설정하세요.
                  width: 80,
                  height: 80,
                ),
                SizedBox(width: 16),
                Text(
                  'APP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 100),
            // 아이디 텍스트 필드
            TextField(
              controller: _idController,
              focusNode: _idFocusNode,
              decoration: InputDecoration(
                labelText: '아이디',
                hintText: '숫자만 입력해 주세요',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
            ),
            SizedBox(height: 16),
            // 비밀번호 텍스트 필드
            TextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: '비밀번호',
                hintText: '영문, 숫자를 포함한 12글자 이내',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '영문, 숫자를 포함한 12글자 이내',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // 비밀번호 찾기 페이지로 이동하는 코드 추가
                },
                child: Text(
                  '비밀번호 찾기',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            if (_errorMessage.isNotEmpty) ...[
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 8),
            ],
            SizedBox(height: 16),
            // 로그인 버튼
            ElevatedButton(
              onPressed: _login,
              child: Text(
                '로그인',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Color(0xFF10D9B5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            // 회원가입 버튼
            OutlinedButton(
              onPressed: () {
                // 회원가입 페이지로 이동하는 코드 추가
              },
              child: Text(
                '회원가입',
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                foregroundColor: Color(0xFF10D9B5),
                side: BorderSide(color: Color(0xFF10D9B5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _idFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
