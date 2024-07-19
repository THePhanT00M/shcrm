import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final Map<String, String> _dummyUsers = {
    '20212155@shcrm.com': 'shinhan24!',
    '20212156@shcrm.com': 'shinhan24!',
    '20211525@shcrm.com': 'shinhan24!',
    '20212159@shcrm.com': 'shinhan24!',
    '20212224@shcrm.com': 'shinhan24!',
  };

  void _showAlertDialog(String message) {
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

    // Regex pattern for validating an email address
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (id.isEmpty) {
      _showAlertDialog('이메일을 입력해 주세요.');
      _idFocusNode.requestFocus();
      return;
    }

    if (!emailRegex.hasMatch(id)) {
      _showAlertDialog('올바른 이메일 형식을 입력해 주세요.');
      _idFocusNode.requestFocus();
      return;
    }

    if (password.isEmpty) {
      _showAlertDialog('비밀번호를 입력해 주세요.');
      _passwordFocusNode.requestFocus();
      return;
    }

    if (_dummyUsers.containsKey(id) && _dummyUsers[id] == password) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', 'dummy_token'); // Save the token
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _errorMessage = '아이디 또는 비밀번호가 일치하지 않습니다.';
      });
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
                labelText: '이메일',
                hintText: 'abc@example.com',
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
