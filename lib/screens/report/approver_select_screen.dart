// approver_select_screen.dart

import 'dart:convert'; // For jsonDecode
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For CupertinoAlertDialog
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For secure storage
import '../../services/api_service.dart';

class ApproverSelectScreen extends StatefulWidget {
  final int? approverId; // Accept approverId as a parameter

  // Constructor accepting approverId
  ApproverSelectScreen({this.approverId});

  @override
  _ApproverSelectScreenState createState() => _ApproverSelectScreenState();
}

class _ApproverSelectScreenState extends State<ApproverSelectScreen> {
  final FlutterSecureStorage _secureStorage =
      FlutterSecureStorage(); // Initialize secure storage
  bool isLoading = true;
  bool hasError = false;
  List<Map<String, dynamic>> approvers = [];
  int? selectedApproverId;
  int? currentEmployeeId; // To store the current user's employeeId

  @override
  void initState() {
    super.initState();
    selectedApproverId = widget.approverId; // Initialize with passed approverId
    _fetchApprovers();
  }

  /// Fetch the list of approvers from the server
  Future<void> _fetchApprovers() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      // Read user data from secure storage
      final userData = await _secureStorage.read(key: 'user_data');
      if (userData == null) {
        throw Exception('User data not found.');
      }

      final userJson = jsonDecode(userData);
      if (userJson['employeeId'] == null) {
        throw Exception('Employee ID not found.');
      }

      currentEmployeeId = userJson['employeeId'];
      print('Current Employee ID: $currentEmployeeId');

      final data = await ApiService.fetchMembersData(); // Implement this method

      print('Fetched Approvers: $data');
      setState(() {
        approvers = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      setState(() {
        hasError = true;
      });
      _showAlertDialog('승인자 목록을 불러오는 중 오류가 발생했습니다: $e');
      // Navigate back if employeeId is not found
      if (e.toString().contains('Employee ID')) {
        Navigator.pop(context);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Handle approver selection
  void _selectApprover(Map<String, dynamic> approver) {
    if (currentEmployeeId == null) {
      _showAlertDialog('사용자 정보를 찾을 수 없습니다.');
      return;
    }

    if (approver['employeeId'] == currentEmployeeId) {
      _showAlertDialog('자기 자신을 승인자로 선택할 수 없습니다.');
      return;
    }

    Navigator.pop(context, {
      'id': approver['employeeId'], // Ensure this key matches your API response
      'name':
          '${approver['firstName']}${approver['lastName']}', // Ensure these keys match
    });
  }

  /// Display alert dialogs using CupertinoAlertDialog
  void _showAlertDialog(String message) {
    if (!mounted) return; // Ensure the widget is still mounted
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            '알림',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            message,
            style: TextStyle(color: Color(0xFF7A7A7A)), // Corrected color code
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                '확인',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          '승인선 지정',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Text('승인자 목록을 불러오는 데 실패했습니다.'),
                )
              : SafeArea(
                  child: Container(
                    color: const Color(0xFFffffff),
                    child: ListView.builder(
                      itemCount: approvers.length,
                      itemBuilder: (context, index) {
                        final approver = approvers[index];
                        final name =
                            '${approver['firstName']}${approver['lastName']}';
                        final isSelected =
                            approver['employeeId'] == selectedApproverId;
                        final isSelf =
                            approver['employeeId'] == currentEmployeeId;

                        return Container(
                          decoration: BoxDecoration(
                            color: isSelf
                                ? Color(
                                    0xFFE0E0E0) // Darker background for self
                                : Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                  color: Color(
                                      0xFFF1F1F1)), // Border color and thickness
                            ),
                          ),
                          child: Opacity(
                            opacity: isSelf
                                ? 0.8
                                : 1.0, // Optional: Reduce opacity for self
                            child: ListTile(
                              title: Text(
                                name,
                                style: TextStyle(
                                  color: isSelf ? Colors.grey : Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                'Email: ${approver['email']}',
                                style: TextStyle(
                                  color: isSelf ? Colors.grey : Colors.black54,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(Icons.check, color: Colors.green)
                                  : isSelf
                                      ? Icon(Icons.block, color: Colors.red)
                                      : null, // Show a block icon if it's the user themselves
                              onTap: isSelf
                                  ? () {
                                      _showAlertDialog(
                                          '자기 자신을 승인자로 선택할 수 없습니다.');
                                    }
                                  : () => _selectApprover(approver),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
