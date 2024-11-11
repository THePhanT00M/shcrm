import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpensesTab extends StatelessWidget {
  final LinkedHashMap<String, List<Map<String, dynamic>>> expensesByDate;
  final int totalExpenses;
  final Map<int, String> categories;
  final Future<void> Function() onRefresh;

  const ExpensesTab({
    Key? key,
    required this.expensesByDate,
    required this.totalExpenses,
    required this.categories,
    required this.onRefresh,
  }) : super(key: key);

  String _formatNumber(num number) {
    int integerNumber = number.toInt();

    String formattedNumber = integerNumber.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    if (formattedNumber.endsWith(',')) {
      formattedNumber =
          formattedNumber.substring(0, formattedNumber.length - 1);
    }

    return formattedNumber;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: Colors.white,
      color: Color(0xFF009EB4),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
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
              "지출 ${totalExpenses}건",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: expensesByDate.keys.map((date) {
                DateTime dateTime = DateTime.parse(date);
                String formattedDate =
                    DateFormat('yyyy.MM.dd EEEE', 'ko_KR').format(dateTime);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12.0,
                      ),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 3.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_month_outlined,
                                  size: 14, color: Colors.grey[700]),
                              SizedBox(width: 5),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ...expensesByDate[date]!.map((expense) {
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 5.0,
                        ),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: expense['image'] != null
                                        ? Colors.transparent
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(5.0),
                                    image: expense['image'] != null
                                        ? DecorationImage(
                                            image:
                                                NetworkImage(expense['image']),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      categories[expense['categoryId']] ??
                                          '알 수 없음',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      expense['merchantName'] ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              '₩${_formatNumber(expense['amount'] ?? 0)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
