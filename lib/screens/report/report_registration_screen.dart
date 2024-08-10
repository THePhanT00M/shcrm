import 'package:flutter/material.dart';

class ReportRegistrationScreen extends StatelessWidget {
  final String? title; // Title of the report, passed in for editing
  final String? amount; // Amount of the report, passed in for editing
  final String? totalExpenses; // Total expenses detail, passed in for editing

  ReportRegistrationScreen({this.title, this.amount, this.totalExpenses});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool isEditMode =
        title != null && amount != null && totalExpenses != null;

    return Scaffold(
      backgroundColor: Color(0xFFf0f0f0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 120,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Text(
            '<',
            style: TextStyle(
              fontSize: 24, // Adjust size as needed
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF10D9B5), Color(0xFF009EB4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Text(
              '보고서',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: title, // Pre-fill if editing
                decoration: InputDecoration(
                  labelText: '보고서 제목',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력하세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                initialValue: amount, // Pre-fill if editing
                decoration: InputDecoration(
                  labelText: '총 지출 금액',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '금액을 입력하세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                initialValue: totalExpenses, // Pre-fill if editing
                decoration: InputDecoration(
                  labelText: '지출 내역',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '지출 내역을 입력하세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save or submit the report data
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              isEditMode ? '보고서가 수정되었습니다.' : '보고서가 등록되었습니다.')),
                    );
                    Navigator.pop(context); // Go back to the previous screen
                  }
                },
                child: Text(isEditMode ? '보고서 수정' : '보고서 등록'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
