import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String email = 'Loading...';
  String name = 'Loading...';

  @override
  void initState() {
    super.initState();
    _userData();
  }

  Future<void> _userData() async {
    try {
      final userData = await _secureStorage.read(key: 'user_data');
      if (userData != null) {
        final userJson = jsonDecode(userData) as Map<String, dynamic>;
        print(userJson);
        setState(() {
          email = userJson['email'] ?? 'No Email';
          name = userJson['name'] ?? 'No name';
        });
      }
    } catch (e) {
      print("Error loading email: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color(0xFF009EB4);
    const policyColor = Color(0xFF028490);
    const whiteText = TextStyle(color: Colors.white);
    const boldWhiteText = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFf0f0f0), // Scaffold 배경색 설정
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appBarColor,
        elevation: 0,
        toolbarHeight: 65,
        title: const Center(
          child: Text(
            'MY',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: appBarColor,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                AssetImage('assets/avatar_man.png'),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CRM',
                                  style: boldWhiteText,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  name,
                                  style: whiteText,
                                ),
                                Text(
                                  email,
                                  style: whiteText,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const FeatureSettingSection3(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureSettingSection3 extends StatelessWidget {
  const FeatureSettingSection3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const dividerColor = Color(0xFFF1F1F1);
    return Container(
      width: double.infinity,
      color: Colors.white, // 이 섹션의 배경색을 흰색으로 유지
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '앱 정보',
            style: TextStyle(fontSize: 12, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('버전', '1.0.0'),
          const Divider(color: dividerColor),
          _buildNavigationRow('Help & Feedback'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow(String title) {
    return GestureDetector(
      onTap: () {
        // 해당 섹션을 클릭했을 때의 동작을 여기에 추가
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 24,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
