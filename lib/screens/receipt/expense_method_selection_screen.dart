import 'package:flutter/material.dart';

class ExpenseMethodSelectionScreen extends StatelessWidget {
  final String currentMethodValue; // 선택된 method의 value

  ExpenseMethodSelectionScreen({required this.currentMethodValue});

  final List<Map<String, String>> methods = [
    {'text': '현금', 'value': 'CASH'},
    {'text': '카드', 'value': 'CARD'},
    {'text': '계좌이체', 'value': 'TRANFER'},
    {'text': '기타', 'value': 'OTHER'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf0f0f0),
      appBar: AppBar(
        backgroundColor: Color(0xFF009EB4),
        toolbarHeight: 50,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.chevron_left, size: 24, color: Colors.white),
            onPressed: () {
              // 뒤로가기 액션 처리
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          '지출방법',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFffffff),
          child: ListView.builder(
            itemCount: methods.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final method = methods[index];
              final isSelected = method['value'] == currentMethodValue;
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF1F1F1)), // 보더 색과 두께 설정
                  ),
                ),
                child: ListTile(
                  leading: _getMethodIcon(method['text']!),
                  title: Transform.translate(
                    offset: Offset(-8, 0),
                    child: Text(method['text']!),
                  ),
                  trailing:
                      isSelected ? Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () {
                    Navigator.pop(context, {
                      'method': method['text'],
                      'value': method['value'],
                      'icon': _getMethodIcon(method['text']!),
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _getMethodIcon(String method) {
    switch (method) {
      case '현금':
        return Icon(Icons.money, color: Colors.grey);
      case '카드':
        return Icon(Icons.credit_card, color: Colors.grey);
      case '계좌이체':
        return Icon(Icons.account_balance, color: Colors.grey);
      case '기타':
        return Icon(Icons.more_horiz, color: Colors.grey);
      default:
        return Icon(Icons.help_outline, color: Colors.grey);
    }
  }
}
