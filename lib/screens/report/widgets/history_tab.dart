import 'package:flutter/material.dart';

class HistoryTab extends StatelessWidget {
  final List<Map<String, dynamic>> historyList;
  final Future<void> Function() onRefresh;

  const HistoryTab({
    Key? key,
    required this.historyList,
    required this.onRefresh,
  }) : super(key: key);

  String _formatDateTime(String dateTimeStr) {
    DateTime dateTime = DateTime.parse(dateTimeStr).toLocal();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final year = dateTime.year;
    final month = twoDigits(dateTime.month);
    final day = twoDigits(dateTime.day);
    final hour = twoDigits(dateTime.hour);
    final minute = twoDigits(dateTime.minute);
    return '$year.$month.$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: Colors.white,
      color: Color(0xFF009EB4),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: historyList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1.0,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 3.0,
              ),
              width: double.infinity,
              child: Text(
                "히스토리",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[600],
                ),
              ),
            );
          }
          final history = historyList[index - 1];
          final createdAt = _formatDateTime(history['createdAt']);

          final firstName = history['employeeId']['firstName'] ?? '';
          final lastName = history['employeeId']['lastName'] ?? '';
          final action = history['action'] ?? '';

          return Container(
            color: Colors.white,
            child: ListTile(
              tileColor: Colors.white,
              leading: CircleAvatar(
                child: Icon(Icons.person, color: Colors.white),
                backgroundColor: const Color.fromARGB(255, 227, 227, 227),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$createdAt      $firstName$lastName',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    action,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
