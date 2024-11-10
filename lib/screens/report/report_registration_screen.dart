import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'expense_method_selection_screen.dart';
import '../receipt/option_tile.dart';
import '../../services/api_service.dart';
import '../../services/category.dart';
import '../../services/report.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter

class ReceiptRegistrationScreen extends StatefulWidget {
  final int? expenseId; // 선택적 expenseId로 변경

  ReceiptRegistrationScreen({this.expenseId});

  @override
  _ReceiptRegistrationScreenState createState() =>
      _ReceiptRegistrationScreenState();
}

class _ReceiptRegistrationScreenState extends State<ReceiptRegistrationScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _employeeId;

  DateTime _selectedDate = DateTime.now();

  String _selectedCategory = '카테고리 선택';
  int? _categoryId;

  String _expenseMethod = '카드';
  String _expenseValue = 'CASH';
  Icon? _expenseIcon = Icon(Icons.money, color: Colors.grey);

  String _selectedReport = '보고서 선택';
  int? _reportId;

  bool isLoading = true;
  bool hasError = false;

  String? _receiptImage;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _amountController.addListener(_formatAmount);
  }

  @override
  void dispose() {
    _amountController.removeListener(_formatAmount);
    _amountController.dispose();
    _businessNameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// Formats a number by adding commas as thousand separators.
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

  // Listener to format the amount as the user types
  void _formatAmount() {
    String currentText = _amountController.text.replaceAll(',', '');
    if (currentText.isEmpty) return;

    num? number = num.tryParse(currentText);
    if (number == null) return;

    String formatted = _formatNumber(number);

    if (formatted != _amountController.text) {
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  // ... rest of your existing code ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFefefef),
      appBar: AppBar(
        backgroundColor: Color(0xFF009EB4),
        toolbarHeight: 60,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.chevron_left, size: 24, color: Colors.white),
            onPressed: () {
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
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () {
                // 입력된 데이터를 확인
                final amount = _amountController.text.trim();
                final merchantName = _businessNameController.text.trim();

                // 필수 필드 검증
                if (amount.isEmpty) {
                  _showAlertDialog('금액을 입력해주세요.');
                  return;
                }

                if (merchantName.isEmpty) {
                  _showAlertDialog('상호를 입력해주세요.');
                  return;
                }

                // 금액이 숫자인지 확인 (선택 사항)
                if (double.tryParse(amount.replaceAll(',', '')) == null) {
                  _showAlertDialog('유효한 금액을 입력해주세요.');
                  return;
                }

                // 모든 검증을 통과하면 저장 함수 호출
                _saveExpenseData();
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: EdgeInsets.only(bottom: 20),
                    child: Column(
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
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF007792),
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '금액을 입력하세요',
                                  hintStyle: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  // The listener handles the formatting
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
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
                                        fontSize: 12, color: Colors.black),
                                  ),
                                ),
                                SizedBox(width: 16),
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: _receiptImage != null &&
                                            _receiptImage!.isNotEmpty
                                        ? (_receiptImage!.startsWith('http')
                                            ? Image.network(
                                                _receiptImage!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Icon(
                                                      Icons.broken_image,
                                                      size: 40,
                                                      color: Colors.grey[400]);
                                                },
                                              )
                                            : Image.file(
                                                File(_receiptImage!),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Icon(
                                                      Icons.broken_image,
                                                      size: 40,
                                                      color: Colors.grey[400]);
                                                },
                                              ))
                                        : Icon(Icons.image,
                                            size: 40, color: Colors.grey[400]),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
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
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ... rest of your existing widgets ...
                ],
              ),
            ),
    );
  }

  // ... rest of your existing methods ...
}
