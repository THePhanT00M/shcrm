import 'package:flutter/material.dart';

class ExpenseMethodSelectionScreen extends StatelessWidget {
  final String currentMethod;

  ExpenseMethodSelectionScreen({required this.currentMethod});

  final List<String> methods = [
    '현금',
    '카드',
    '계좌이체',
    '기타',
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
              return ListTile(
                leading: _getMethodIcon(method),
                title: Transform.translate(
                  offset: Offset(-8, 0),
                  child: Text(method),
                ),
                trailing: method == currentMethod
                    ? Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  Navigator.pop(context, {
                    'method': method,
                    'icon': _getMethodIcon(method),
                  });
                },
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
