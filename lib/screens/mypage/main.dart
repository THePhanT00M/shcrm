import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF10D9B5),
        elevation: 0,
        toolbarHeight: 240,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF10D9B5), Color(0xFF009EB4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin:
                      EdgeInsets.only(top: 30, right: 10, left: 10, bottom: 5),
                  child: Text(
                    'MY',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        child: CircleAvatar(
                          backgroundImage: AssetImage('assets/avatar_man.png'),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '회사 아이콘',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '이름',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '이메일',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '계정',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          Text(''),
                          Text(''),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF028490),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'little',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'subtitle',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: Color(0xFFf0f0f0),
                ),
                Center(
                  child: Column(
                    children: [
                      FeatureSettingSection2(),
                      FeatureSettingSection3(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureSettingSection2 extends StatefulWidget {
  @override
  _FeatureSettingSection2State createState() => _FeatureSettingSection2State();
}

class _FeatureSettingSection2State extends State<FeatureSettingSection2> {
  bool _isWiFiUploadOnly = false;
  bool _isImageAutoSave = false;
  bool _isStartWithCameraMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.only(left: 20, top: 8, right: 20, bottom: 8),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기능설정',
            style: TextStyle(fontSize: 12, color: Color(0xFF333333)),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'wi-fi upload only',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CustomSwitch(
                value: _isWiFiUploadOnly,
                onChanged: (bool newValue) {
                  setState(() {
                    _isWiFiUploadOnly = newValue;
                  });
                },
              ),
            ],
          ),
          Divider(color: Color.fromARGB(255, 241, 241, 241)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '이미지 자동 저장',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CustomSwitch(
                value: _isImageAutoSave,
                onChanged: (bool newValue) {
                  setState(() {
                    _isImageAutoSave = newValue;
                  });
                },
              ),
            ],
          ),
          Divider(color: Color.fromARGB(255, 241, 241, 241)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '카메라 모드로 시작',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CustomSwitch(
                value: _isStartWithCameraMode,
                onChanged: (bool newValue) {
                  setState(() {
                    _isStartWithCameraMode = newValue;
                  });
                },
              ),
            ],
          ),
          Divider(color: Color.fromARGB(255, 241, 241, 241)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '이미지 자동 저장',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right), // 화살표 아이콘
                onPressed: () {
                  // 여기에 버튼 클릭 시 실행할 코드를 작성하세요.
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeatureSettingSection3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.only(left: 20, top: 8, right: 20, bottom: 8),
      margin: EdgeInsets.only(bottom: 10),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '앱 정보',
            style: TextStyle(fontSize: 12, color: Color(0xFF333333)),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '버전',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '1.0.0',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Color.fromARGB(255, 241, 241, 241)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Help & Feedback',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 24,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double scale;

  const CustomSwitch({
    required this.value,
    required this.onChanged,
    this.scale = 1, // Default scale is 1.0
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Transform.scale(
        scale: scale,
        child: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xFF10D9B5),
          trackColor: Color(0xFFE1E1E1),
        ),
      ),
    );
  }
}
