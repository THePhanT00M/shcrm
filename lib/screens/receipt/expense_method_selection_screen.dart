// lib/screens/expense_method_selection_screen.dart
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
      appBar: AppBar(
        title: Text('지출 방법 선택'),
        backgroundColor: Color(0xFF009EB4),
      ),
      body: ListView.builder(
        itemCount: methods.length,
        itemBuilder: (context, index) {
          final method = methods[index];
          return ListTile(
            leading: _getMethodIcon(method),
            title: Text(method),
            trailing: method == currentMethod
                ? Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () {
              Navigator.pop(context, method); // 선택한 방법 반환
            },
          );
        },
      ),
    );
  }

  Widget _getMethodIcon(String method) {
    switch (method) {
      case '현금':
        return Icon(Icons.money, color: Colors.green);
      case '카드':
        return Icon(Icons.credit_card, color: Colors.blue);
      case '계좌이체':
        return Icon(Icons.account_balance, color: Colors.orange);
      case '기타':
        return Icon(Icons.more_horiz, color: Colors.grey);
      default:
        return Icon(Icons.help_outline, color: Colors.grey);
    }
  }
}
