// report_registration_screen.dart

import 'dart:convert';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

import 'titleEdit.dart';
import 'statistics.dart';
import 'approver_select_screen.dart'; // Import the ApproverSelectScreen

import '../../services/api_service.dart';
import '../report/widgets/expenses_tab.dart';
import '../report/widgets/attachments_tab.dart';
import '../report/widgets/history_tab.dart';
import '../report/widgets/comments_tab.dart';
import '../report/widgets/common_widgets.dart';

class ReportRegistrationScreen extends StatefulWidget {
  final int? reportId;

  ReportRegistrationScreen({this.reportId});

  @override
  _ReportRegistrationScreenState createState() =>
      _ReportRegistrationScreenState();
}

class _ReportRegistrationScreenState extends State<ReportRegistrationScreen>
    with SingleTickerProviderStateMixin {
  String? _employeeId;
  bool isLoading = true;
  bool hasError = false;

  LinkedHashMap<String, List<Map<String, dynamic>>> expensesByDate =
      LinkedHashMap();

  String? _reportTitle;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<PlatformFile> _selectedFiles = [];

  List<Map<String, dynamic>> historyList = [];

  List<Map<String, dynamic>> commentsList = [];

  final TextEditingController _commentController = TextEditingController();
  bool _isCommentNotEmpty = false;

  int? _reportId;

  Map<int, String> categories = {};

  final ScrollController _scrollController = ScrollController();

  Map<String, List<Map<String, dynamic>>> commentsByDate = {};

  /// State variable to track mail sending process
  bool isUploading = false;

  // State Variables for Submitter and Approver Names
  String submitterName = ""; // Default value
  String approverName = ""; // Default value
  int? approverId; // Variable to store approver ID

  // TabController for managing tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _reportId = widget.reportId;

    // Initialize TabController with 4 tabs
    _tabController = TabController(length: 4, vsync: this);

    _fetchData();

    _commentController.addListener(() {
      if (mounted) {
        setState(() {
          _isCommentNotEmpty = _commentController.text.trim().isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _tabController.dispose(); // Dispose TabController
    super.dispose();
  }

  /// Initialize a new report if no reportId is provided
  Future<void> _initializeNewReport(String employeeId) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final data = {
        'title': '새 보고서',
        'content': '새 보고서',
        'status': 'PENDING',
        'categoryId': 1,
        'employeeId': employeeId,
        'approvalRequestId': 2,
      };

      final response = await ApiService.createReportData(data);

      final newReportId = response['reportId'];

      if (newReportId != null) {
        setState(() {
          _reportId = newReportId;
        });

        await _fetchData();
      } else {
        throw Exception('보고서 ID를 가져올 수 없습니다.');
      }
    } catch (e) {
      _showError('보고서 생성 중 오류가 발생했습니다: $e');

      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Fetch necessary data for the screen
  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final employeeId = await _fetchEmployeeId();
      _employeeId = employeeId;
      if (employeeId != null) {
        await _fetchCategories();

        if (_reportId != null) {
          await _loadReportData(employeeId);
          await _loadComments();
        } else {
          await _initializeNewReport(employeeId);
        }
      } else {
        _showError('로그인 정보가 없습니다. 다시 로그인 해주세요.');
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showError('오류가 발생했습니다: $e');
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Fetch report categories from the server
  Future<void> _fetchCategories() async {
    try {
      final data = await ApiService.fetchCategoriesData();
      categories = {};
      for (var item in data) {
        final categoryId = item['categoryId'];
        final categoryName = item['categoryName'];
        if (categoryId != null && categoryName != null) {
          categories[categoryId] = categoryName;
        }
      }
    } catch (e) {
      _showAlertDialog('카테고리를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  /// Retrieve employee ID from secure storage
  Future<String?> _fetchEmployeeId() async {
    final userData = await _secureStorage.read(key: 'user_data');
    if (userData != null) {
      final userJson = jsonDecode(userData);
      return userJson['employeeId']?.toString();
    }
    return null;
  }

  /// Load report data including expenses and history
  Future<void> _loadReportData(String employeeId) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final data = await ApiService.fetchReportDetails(
        _reportId!,
        employeeId,
      );

      final List<Map<String, dynamic>> expensesList =
          List<Map<String, dynamic>>.from(data['expensesData']);
      expensesByDate = LinkedHashMap();

      for (var expense in expensesList) {
        final date = DateTime.parse(expense['expenseDate'])
            .toLocal()
            .toString()
            .split(' ')[0];
        if (expensesByDate.containsKey(date)) {
          expensesByDate[date]!.add(expense);
        } else {
          expensesByDate[date] = [expense];
        }
      }

      List<String> sortedDates = expensesByDate.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      LinkedHashMap<String, List<Map<String, dynamic>>> sortedExpensesByDate =
          LinkedHashMap.fromIterable(
        sortedDates,
        key: (date) => date as String,
        value: (date) => expensesByDate[date]!,
      );

      expensesByDate = sortedExpensesByDate;

      print('API 결과 : ${data['expensesData']}');

      if (data['historyData'] != null) {
        historyList = List<Map<String, dynamic>>.from(data['historyData']);
      } else {
        historyList = [
          {
            'createdAt': data['reportData']['createdAt'],
            'employeeId': {
              'firstName': data['authorData']['firstName'],
              'lastName': data['authorData']['lastName'],
            },
            'action': '보고서가 생성되었습니다.',
          }
        ];
      }

      print('API 결과 111111');

      // Extract Submitter and Approver Names
      final authorData = data['authorData'];
      final approverData = data['approverData'];
      print('API 결과 : ${data}');

      if (authorData != null) {
        String firstName = authorData['firstName'] ?? '';
        String lastName = authorData['lastName'] ?? '';

        setState(() {
          submitterName = '$firstName$lastName';
        });
      } else {
        // Fallback to default value or handle accordingly
        setState(() {
          submitterName = 'A';
        });
      }

      if (approverData != null) {
        String firstName = approverData['firstName'] ?? '';
        String lastName = approverData['lastName'] ?? '';
        setState(() {
          approverName = '$firstName$lastName';
          approverId =
              approverData['employeeId']; // Assuming employeeId is available
        });
      } else {
        // Fallback to default value or handle accordingly
        setState(() {
          approverName = '미지정';
          approverId = null;
        });
      }

      setState(() {
        _reportTitle = data['reportData']['title'];
        isLoading = false;
      });
    } catch (e) {
      _showAlertDialog('데이터를 불러오지 못했습니다: $e');
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Load comments associated with the report
  Future<void> _loadComments() async {
    try {
      final data = await ApiService.fetchCommentData(_reportId!);

      commentsList = List<Map<String, dynamic>>.from(data);

      _groupCommentsByDate();

      if (mounted) {
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      _showAlertDialog('코멘트를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  /// Group comments by date for display
  void _groupCommentsByDate() {
    commentsByDate.clear();
    for (var comment in commentsList) {
      String date = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(comment['createdAt']).toLocal());
      if (commentsByDate.containsKey(date)) {
        commentsByDate[date]!.add(comment);
      } else {
        commentsByDate[date] = [comment];
      }
    }
  }

  /// Display error messages using SnackBar
  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      isLoading = false;
      hasError = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
            style: TextStyle(color: Color(0xFFF7a7a7a)),
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

  /// Calculate total number of expenses
  int get totalExpenses {
    return expensesByDate.values.fold(0, (sum, list) => sum + list.length);
  }

  /// Calculate total amount of expenses
  double get totalAmount {
    return expensesByDate.values
        .expand((list) => list)
        .map((e) => e['amount'] is num ? e['amount'] as num : 0)
        .fold(0, (sum, amt) => sum + amt.toDouble());
  }

  /// Pick files using file_picker package
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      } else {
        // User canceled the picker
      }
    } catch (e) {
      print(e);
      _showAlertDialog('파일을 선택하는 중 오류가 발생했습니다: $e');
    }
  }

  /// Remove a selected file
  void _removeFile(PlatformFile file) {
    setState(() {
      _selectedFiles.remove(file);
    });
  }

  /// Save updated report data to the server
  Future<void> _saveReportData() async {
    final data = {
      'reportId': _reportId,
      'employeeId': _employeeId,
      'title': _reportTitle,
    };

    try {
      await ApiService.updateReportData(data);
      _showAlertDialog('보고서 제목이 업데이트되었습니다.');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목 업데이트에 실패했습니다: $e')),
      );
    }
  }

  /// Submit a new comment
  Future<void> _submitComment(String content) async {
    if (content.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final data = {
        'reportId': _reportId,
        'employeeId': _employeeId,
        'content': content,
        'attachmentId': 1,
        'relatedType': "REPORT"
      };

      await ApiService.submitComment(data);

      if (mounted) {
        setState(() {
          _commentController.clear();
          _isCommentNotEmpty = false;
        });
      }

      await _loadComments();
    } catch (e) {
      _showError('코멘트 제출 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Handle sending mail related to the report
  Future<void> _sendMail() async {
    if (_reportId == null || _employeeId == null) {
      _showAlertDialog('보고서 정보가 충분하지 않습니다.');
      return;
    }

    setState(() {
      isUploading = true; // Start uploading
      hasError = false;
    });

    try {
      final data = {
        'reportId': _reportId,
        'employeeId': int.tryParse(_employeeId!),
        'approvalRequestId': 2,
      };

      await ApiService.sendMail(data);

      _showAlertDialog('메일이 성공적으로 전송되었습니다.');
    } catch (e) {
      _showError('메일 전송 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false; // Stop uploading
        });
      }
    }
  }

  /// Handle editing the approver by navigating to ApproverSelectScreen
  Future<void> _editApprover() async {
    if (_employeeId == null) {
      _showAlertDialog('로그인 정보가 없습니다.');
      return;
    }

    setState(() {
      isUploading = true; // Optionally, show loading while selecting
    });

    try {
      // Navigate to ApproverSelectScreen and pass the current approverId
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApproverSelectScreen(
            approverId: approverId, // Pass the current approverId
          ),
        ),
      );

      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          approverName = result['name'] ?? approverName; // Update approverName
          approverId = result['id'] ?? approverId; // Update approverId
        });

        // Optionally, update the report data on the server
        await _updateApproverOnServer();
      }
    } catch (e) {
      _showError('승인자를 선택하는 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  /// Update the approver information on the server
  Future<void> _updateApproverOnServer() async {
    try {
      final data = {
        'reportId': _reportId,
        'approvalRequestId': approverId,
      };

      await ApiService.updateReportData(data);

      _showAlertDialog('승인자가 업데이트되었습니다.');
    } catch (e) {
      _showError('승인자 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  /// Format numbers with commas
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

  /// Format DateTime strings
  String _formatDateTime(String dateTimeStr) {
    DateTime dateTime = DateTime.parse(dateTimeStr).toLocal();
    return DateFormat('yyyy.MM.dd HH:mm').format(dateTime);
  }

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
          '보고서',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.email_outlined, size: 24, color: Colors.white),
            onPressed: _sendMail, // Call _sendMail when pressed
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Content
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Header Section
                    CommonHeader(
                      reportTitle: _reportTitle,
                      totalAmount: totalAmount,
                      onTitleEdit: () async {
                        final updatedTitle = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TitleEditScreen(currentTitle: _reportTitle),
                          ),
                        );

                        if (updatedTitle != null &&
                            updatedTitle != _reportTitle) {
                          if (mounted) {
                            setState(() {
                              _reportTitle = updatedTitle;
                            });
                          }
                          _saveReportData();
                        }
                      },
                      onStatistics: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Statistics(reportId: _reportId),
                          ),
                        );
                      },
                      onApproverEdit: _editApprover, // Pass the callback
                      submitterName: submitterName, // Pass submitter name
                      approverName: approverName, // Pass approver name
                    ),
                    // TabBar Section
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController, // Assign TabController
                        labelColor: Color(0xFF009EB4),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Color(0xFF009EB4),
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: [
                          Tab(icon: Icon(Icons.description)),
                          Tab(
                            icon: Transform.rotate(
                              angle: 45 * 3.1415926535897932 / 180,
                              child: Icon(
                                Icons.attach_file,
                              ),
                            ),
                          ),
                          Tab(icon: Icon(Icons.history)),
                          Tab(icon: Icon(Icons.chat)),
                        ],
                      ),
                    ),
                    // TabBarView Section
                    Expanded(
                      child: TabBarView(
                        controller: _tabController, // Assign TabController
                        children: [
                          // Expenses Tab
                          ExpensesTab(
                            expensesByDate: expensesByDate,
                            totalExpenses: totalExpenses,
                            categories: categories,
                            onRefresh: _fetchData,
                          ),
                          // Attachments Tab
                          AttachmentsTab(
                            selectedFiles: _selectedFiles,
                            onPickFile: _pickFile,
                            onRemoveFile: _removeFile,
                            onRefresh: _fetchData,
                          ),
                          // History Tab
                          HistoryTab(
                            historyList: historyList,
                            onRefresh: _fetchData,
                          ),
                          // Comments Tab
                          CommentsTab(
                            commentsByDate: commentsByDate,
                            employeeId: _employeeId,
                            commentController: _commentController,
                            isCommentNotEmpty: _isCommentNotEmpty,
                            onSubmitComment: _submitComment,
                            onRefresh: _fetchData,
                            scrollController: _scrollController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

          // Loading Overlay for Mail Sending or Approver Editing
          if (isUploading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '발송중...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
