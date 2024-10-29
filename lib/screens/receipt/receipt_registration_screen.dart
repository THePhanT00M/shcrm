// lib/screens/receipt_registration_screen.dart
import 'package:flutter/material.dart';
import 'expense_method_selection_screen.dart';
import '../receipt/option_tile.dart';

class ReceiptRegistrationScreen extends StatefulWidget {
  @override
  _ReceiptRegistrationScreenState createState() =>
      _ReceiptRegistrationScreenState();
}

class _ReceiptRegistrationScreenState extends State<ReceiptRegistrationScreen> {
  // Controllers for text fields
  final TextEditingController _amountController =
      TextEditingController(text: '10,000');
  final TextEditingController _businessNameController =
      TextEditingController(text: '맥도날드');
  final TextEditingController _dateController =
      TextEditingController(text: '2024.10.25');

  // Define the 'date' variable
  DateTime _selectedDate = DateTime(2024, 10, 25);

  String _expenseMethod = '현금'; // 기본 지출 방법

  @override
  void dispose() {
    _amountController.dispose();
    _businessNameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Define the 'onDateSelected' method
  void _onDateSelected(DateTime selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
      _dateController.text =
          '${selectedDate.year}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the background color to #efefef
      backgroundColor: Color(0xFFefefef),
      // Custom Header
      appBar: AppBar(
        backgroundColor: Color(0xFF009EB4),
        toolbarHeight: 60,
        elevation: 0,
        centerTitle: true, // Center the title
        leading: Padding(
          padding: const EdgeInsets.only(), // Adjust left padding
          child: IconButton(
            icon: Icon(Icons.chevron_left, size: 24, color: Colors.white),
            onPressed: () {
              // Handle back action
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          '지출',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Adjust right padding
            child: TextButton(
              onPressed: () {
                // Handle save action
              },
              child: Text(
                '저장',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
      // Main Content
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16), // Increased padding for better spacing
        child: Column(
          children: [
            // Amount & Business Name Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // Amount Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '금액 *',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF007792),
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '금액을 입력하세요',
                              ),
                            ),
                          ),
                          SizedBox(width: 16), // Increased spacing
                          // KRW Label with Image
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'KRW',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                      16), // Increased spacing between KRW and image
                              // Image next to KRW
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.asset(
                                  'assets/images/placeholder.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey[400],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Business Name Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '상호 *',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      TextField(
                        controller: _businessNameController,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF007792),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '상호를 입력하세요',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Date, Policy, Category, Expense Method Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // Modified Date Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '날짜 *',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate:
                                _selectedDate, // Use the defined 'date'
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                            initialEntryMode: DatePickerEntryMode.calendarOnly,
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  inputDecorationTheme: InputDecorationTheme(
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 0.5,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  colorScheme: ColorScheme.light(
                                    onPrimary: Colors.white,
                                    primary: Colors.blue,
                                    background: Colors.white,
                                  ),
                                  datePickerTheme: DatePickerThemeData(
                                    headerBackgroundColor: Colors.blue,
                                    backgroundColor: Colors.white,
                                    headerForegroundColor: Colors.white,
                                    surfaceTintColor: Colors.white,
                                    dividerColor: Colors.blue,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (selectedDate != null &&
                              selectedDate != _selectedDate) {
                            _onDateSelected(
                                selectedDate); // Call the defined method
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dateController.text.isNotEmpty
                                    ? _dateController.text
                                    : '날짜를 선택하세요',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _dateController.text.isNotEmpty
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                              Icon(
                                Icons.add, // Changed icon from calendar to plus
                                color: Colors.grey[400],
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  OptionTile(
                    title: '카테고리',
                    onTap: () {
                      // 카테고리 선택 로직
                    },
                  ),
                  OptionTile(
                    title: '지출방법',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: Colors.green,
                          size: 15,
                        ),
                        //SizedBox(width: 8),
                        Text(
                          _expenseMethod,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      // 지출방법 선택 페이지로 이동
                      final selectedMethod = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExpenseMethodSelectionScreen(
                            currentMethod: _expenseMethod,
                          ),
                        ),
                      );

                      if (selectedMethod != null) {
                        setState(() {
                          _expenseMethod = selectedMethod;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            // Participants & Memo Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  OptionTile(title: '보고서'),
                ],
              ),
            ),
            // Footer with Switch
            // (필요시 추가)
          ],
        ),
      ),
    );
  }
}
