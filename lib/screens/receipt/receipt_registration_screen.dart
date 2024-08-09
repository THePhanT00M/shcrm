import 'package:flutter/material.dart';

class ReceiptRegistrationScreen extends StatelessWidget {
  final String? title; // Title of the receipt, passed in for editing
  final String? amount; // Amount of the receipt, passed in for editing
  final String? iconPath; // Icon path for the receipt, passed in for editing

  ReceiptRegistrationScreen({this.title, this.amount, this.iconPath});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = title != null && amount != null && iconPath != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 그라데이션을 위해 투명색 설정
        //toolbarHeight: 120,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                        Navigator.pop(
                            context); // Navigate back to the previous screen
                      },
                      child: Padding(
                        padding: EdgeInsets.all(8), // Remove padding
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
                        padding: EdgeInsets.zero, // Remove padding
                        minimumSize: Size(
                            50, 33), // Minimum size to ensure touchable area
                        tapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // Shrink wrap the button
                      ),
                      onPressed: () {
                        // Implement save functionality here
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditMode ? '지출이 수정되었습니다.' : '지출이 등록되었습니다.',
                              ),
                            ),
                          );
                          Navigator.pop(
                              context); // Go back to the previous screen after saving
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: title, // Pre-fill if editing
                decoration: InputDecoration(
                  labelText: '지출 제목',
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
              // You might want to include other fields for the receipt
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save or submit the receipt data
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              isEditMode ? '지출이 수정되었습니다.' : '지출이 등록되었습니다.')),
                    );
                    Navigator.pop(context); // Go back to the previous screen
                  }
                },
                child: Text(isEditMode ? '지출 수정' : '지출 등록'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
