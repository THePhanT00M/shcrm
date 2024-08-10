import 'package:flutter/material.dart';

class ReceiptRegistrationScreen extends StatefulWidget {
  final String? title; // 영수증 제목, 수정용으로 전달됨
  final String? amount; // 영수증 금액, 수정용으로 전달됨
  final String? iconPath; // 영수증 아이콘 경로, 수정용으로 전달됨

  ReceiptRegistrationScreen({this.title, this.amount, this.iconPath});

  @override
  _ReceiptRegistrationScreenState createState() =>
      _ReceiptRegistrationScreenState();
}

class _ReceiptRegistrationScreenState extends State<ReceiptRegistrationScreen> {
  final _formKey = GlobalKey<FormState>(); // 폼 상태를 관리하기 위한 키
  bool _isStartWithCameraMode = false; // 카메라 모드 시작 스위치의 현재 상태
  DateTime _selectedDate = DateTime.now(); // 선택된 날짜, 기본값은 오늘 날짜

  @override
  void initState() {
    super.initState();
    // 초기 상태를 위젯의 인자로부터 설정할 수 있습니다.
    // 예를 들어, widget.isStartWithCameraMode이 있다면 아래와 같이 설정할 수 있습니다.
    // _isStartWithCameraMode = widget.isStartWithCameraMode;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.title != null &&
        widget.amount != null &&
        widget.iconPath != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 그라데이션을 위한 투명 배경
        elevation: 0, // 그림자 제거
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF10D9B5), Color(0xFF009EB4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Column(
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    isEditMode ? '지출 수정' : '지출 등록',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  left: -7,
                  top: -1.5,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // 이전 화면으로 돌아가기
                      },
                      child: Padding(
                        padding: EdgeInsets.all(8), // 패딩 제거
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // 패딩 제거
                        minimumSize: Size(50, 33), // 최소 크기 설정
                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap, // 버튼 크기에 맞게 축소
                      ),
                      onPressed: () {
                        // 저장 기능 구현
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditMode ? '지출이 수정되었습니다.' : '지출이 등록되었습니다.',
                              ),
                            ),
                          );
                          Navigator.pop(context); // 저장 후 이전 화면으로 돌아가기
                        }
                      },
                      child: Text(
                        '저장',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 폼 위젯
            Form(
              key: _formKey, // 폼 상태를 관리할 키
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 입력 필드
                  TextFormField(
                    initialValue: widget.title, // 수정 시 초기 값으로 설정
                    decoration: InputDecoration(
                      labelText: '금액',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '제목을 입력하세요'; // 제목 입력 필수
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  // 금액 입력 필드
                  TextFormField(
                    initialValue: widget.amount, // 수정 시 초기 값으로 설정
                    decoration: InputDecoration(
                      labelText: '상호',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '금액을 입력하세요'; // 금액 입력 필수
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),

                  // 구분선
                  Divider(color: Color.fromARGB(255, 241, 241, 241)),

                  // 날짜 선택
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: GestureDetector(
                            onTap: () => _selectDate(context),
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: TextEditingController(
                                  text: "${_selectedDate.toLocal()}"
                                      .split(' ')[0],
                                ),
                                decoration: InputDecoration(
                                  labelText: '날짜',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[700], // 아이콘 색상 조정
                      ),
                    ],
                  ),

                  // 구분선
                  Divider(color: Color.fromARGB(255, 241, 241, 241)),

                  // 폴리시 설정
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '폴리시',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700], // 짙은 회색
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[700], // 아이콘 색상 조정
                      ),
                    ],
                  ),

                  // 지정안함 텍스트
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '지정안함',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold, // 글씨를 두껍게
                              color: Colors.black87, // 카테고리와 같은 색상
                            ),
                          ),
                        ),
                      ),
                      // 아이콘 제거
                    ],
                  ),

                  // 구분선
                  Divider(color: Color.fromARGB(255, 241, 241, 241)),

                  // 카테고리 설정
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '카테고리',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                      ),
                    ],
                  ),

                  // 구분선
                  Divider(color: Color.fromARGB(255, 241, 241, 241)),

                  // 지출 방법 설정
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '지출 방법',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                      ),
                    ],
                  ),

                  SizedBox(height: 16.0),

                  // 카메라 모드 시작 스위치
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          '경비 환급',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      CustomSwitch(
                        value: _isStartWithCameraMode, // 스위치 현재 상태
                        onChanged: (bool newValue) {
                          // 스위치 상태 변경 시 호출되는 함수
                          setState(() {
                            _isStartWithCameraMode = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),

                  // 저장 버튼
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // 저장 또는 제출 기능
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditMode ? '지출이 수정되었습니다.' : '지출이 등록되었습니다.',
                            ),
                          ),
                        );
                        Navigator.pop(context); // 저장 후 이전 화면으로 돌아가기
                      }
                    },
                    child: Text(isEditMode ? '지출 수정' : '지출 등록'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 사용자 정의 스위치 위젯
class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  CustomSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
    );
  }
}
