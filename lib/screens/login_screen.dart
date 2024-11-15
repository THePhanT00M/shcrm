import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart'; // FCM 패키지 추가

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 텍스트 컨트롤러 및 포커스 노드 설정
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _idFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscureText = true;
  String _errorMessage = '';

  // FlutterSecureStorage 인스턴스 생성
  final _secureStorage = const FlutterSecureStorage();

  // FCM 토큰 변수 추가
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  // FCM 초기화 및 토큰 획득 함수
  Future<void> _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 사용자에게 알림 권한 요청 (iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // 토큰 획득
      String? token = await messaging.getToken();
      setState(() {
        _fcmToken = token;
      });
      print('FCM Token: $_fcmToken');

      // 토큰 갱신 시 처리
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        setState(() {
          _fcmToken = newToken;
        });
        print('FCM Token refreshed: $_fcmToken');
        // 필요시 서버에 새로운 토큰을 전송
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // 경고 대화상자 표시 함수
  void _showAlertDialog(String message) {
    if (!mounted) return; // 위젯이 마운트되어 있는지 확인
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            '알림',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            message,
            style: TextStyle(color: Color(0xFFF7a7a7a)),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                '확인',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 로그인 함수
  Future<void> _login() async {
    final id = _idController.text;
    final password = _passwordController.text;

    // 숫자만 입력되었는지 확인하는 정규 표현식
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

    final url = Uri.parse('http://shcrm.ddns.net:8080/login');

    // FCM 토큰을 포함한 바디 생성
    final body = {
      'employeeId': id,
      'password': password,
      'fcmToken': _fcmToken ?? '', // 토큰이 없을 경우 빈 문자열 전송
    };

    print('로그인 파라미터 : ${body}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Apikey': '4sfItxEd9YHjpTS96jxFnZoKseT5PdDM'
        },
        body: jsonEncode(body),
      );

      // 응답 출력
      print('Response 출력: ${response.body}');

      if (!mounted) return; // 위젯이 마운트되어 있는지 확인

      if (response.statusCode == 200) {
        // 응답 바디에서 JSON 데이터 추출
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        final employeeId = jsonResponse['employeeId'];
        final email = jsonResponse['email'];
        final name = jsonResponse['name'];

        // JSON 데이터를 저장
        final userData = jsonEncode(
            {'employeeId': employeeId, 'email': email, 'name': name});
        await _secureStorage.write(key: 'user_data', value: userData);

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showAlertDialog('아이디 또는 비밀번호가 일치하지 않습니다.');
      }
    } catch (e) {
      if (mounted) {
        _showAlertDialog('네트워크 오류가 발생했습니다.\n인터넷 연결을 확인해 주세요.');
      }
    }
  }

  // 저장된 사용자 데이터를 불러오는 함수
  Future<Map<String, dynamic>?> _getUserData() async {
    final userData = await _secureStorage.read(key: 'user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // 키보드가 올라올 때 화면이 자동으로 조정되도록 설정
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        // 스크롤 가능하도록 설정
        child: Padding(
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
                keyboardType: TextInputType.number,
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
              //SizedBox(height: 16),
              //// 회원가입 버튼 (현재 주석 처리됨)
              //OutlinedButton(
              //  onPressed: () {
              //    // 회원가입 페이지로 이동하는 코드 추가
              //  },
              //  child: Text(
              //    '회원가입',
              //    style: TextStyle(fontSize: 16),
              //  ),
              //  style: OutlinedButton.styleFrom(
              //    minimumSize: Size(double.infinity, 50),
              //    foregroundColor: Color(0xFF10D9B5),
              //    side: BorderSide(color: Color(0xFF10D9B5)),
              //    shape: RoundedRectangleBorder(
              //      borderRadius: BorderRadius.circular(8),
              //    ),
              //  ),
              //),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 텍스트 컨트롤러 및 포커스 노드 해제
    _idController.dispose();
    _passwordController.dispose();
    _idFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
