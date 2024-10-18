import 'package:flutter/material.dart';

class ReceiptRegistrationScreen extends StatefulWidget {
  @override
  _ReceiptRegistrationScreenState createState() =>
      _ReceiptRegistrationScreenState();
}

class _ReceiptRegistrationScreenState extends State<ReceiptRegistrationScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _merchantController = TextEditingController();
  DateTime? _selectedDate;
  bool _isReimbursement = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf0f0f0),
      appBar: AppBar(
        backgroundColor: Color(0xFF009EB4),
        toolbarHeight: 60,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '지출',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 5,
                  child: Transform.translate(
                    offset: Offset(0, 0), // 아이콘 높이의 절반만큼 위로 이동
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 2,
                  child: TextButton(
                    onPressed: () {
                      // 지정안함 버튼 클릭 시 동작할 코드 작성
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, // 여백 제거
                      minimumSize: Size(26, 26), // 버튼 최소 크기 설정 (필요에 따라 조정)
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // 버튼 크기를 최소화
                    ),
                    child: Text(
                      '저장',
                      style: TextStyle(
                        color: Colors.white,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _selectedDate == null
                    ? '날짜 *'
                    : '${_selectedDate!.toLocal()}'.split(' ')[0],
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('폴리시'),
              subtitle: Text('지정 안함'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('카테고리'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('지출방법'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('경비 환급'),
              value: _isReimbursement,
              onChanged: (bool value) {
                setState(() {
                  _isReimbursement = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _registerReceipt() {
    String amount = _amountController.text;
    String merchant = _merchantController.text;
    String date = _selectedDate != null
        ? _selectedDate!.toLocal().toString().split(' ')[0]
        : '';

    if (amount.isNotEmpty && merchant.isNotEmpty && date.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('영수증이 성공적으로 등록되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }
}
