import 'package:flutter/material.dart';

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
    '20212155': 'shinhan24!',
    '20212156': 'shinhan24!',
    '20211525': 'shinhan24!',
    '20212159': 'shinhan24!',
    '20212224': 'shinhan24!',
  };

  void _login() {
    final id = _idController.text;
    final password = _passwordController.text;

    if (id.isEmpty) {
      setState(() {
        _errorMessage = '아이디를 입력해주세요.';
      });
      _idFocusNode.requestFocus();
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = '비밀번호를 입력해주세요.';
      });
      _passwordFocusNode.requestFocus();
      return;
    }

    if (_dummyUsers.containsKey(id) && _dummyUsers[id] == password) {
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
            // 로고
            Column(
              children: [
                Image.asset(
                  'assets/logo.png', // 로고 이미지 경로를 올바르게 설정하세요.
                  height: 80,
                ),
                SizedBox(height: 16),
              ],
            ),
            SizedBox(height: 32),
            // 아이디 텍스트 필드
            TextField(
              controller: _idController,
              focusNode: _idFocusNode,
              decoration: InputDecoration(
                labelText: '아이디',
                hintText: 'app@naver.com',
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
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // 비밀번호 찾기 페이지로 이동하는 코드 추가
                },
                child: Text('비밀번호 찾기'),
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
                backgroundColor: Color(0xFF1C31F0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
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
                foregroundColor: Color(0xFF1C31F0),
                side: BorderSide(color: Color(0xFF1C31F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
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
