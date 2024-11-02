import 'package:flutter/material.dart';

class AuthSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 150.0, left: 32.0, right: 32.0),
                child: Text(
                  '성공한 기업들의\n혁신적인 비용관리, APP()',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 50.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        '로그인',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 47),
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF10D9B5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    //SizedBox(height: 20),
                    //OutlinedButton(
                    //  onPressed: () {
                    //    // 회원가입 페이지로 이동하는 코드 추가
                    //  },
                    //  child: Text(
                    //    '회원가입',
                    //    style: TextStyle(fontSize: 16),
                    //  ),
                    //  style: OutlinedButton.styleFrom(
                    //    minimumSize: Size(double.infinity, 47),
                    //    foregroundColor: Colors.white,
                    //    side: BorderSide(color: Colors.white),
                    //    shape: RoundedRectangleBorder(
                    //      borderRadius: BorderRadius.circular(5),
                    //    ),
                    //  ),
                    //),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
