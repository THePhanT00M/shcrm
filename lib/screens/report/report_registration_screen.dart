import 'dart:convert';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'titleEdit.dart';

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

class _ReportRegistrationScreenState extends State<ReportRegistrationScreen> {
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

  @override
  void initState() {
    super.initState();
    _reportId = widget.reportId;
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
    super.dispose();
  }

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
      _showError('카테고리를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  Future<String?> _fetchEmployeeId() async {
    final userData = await _secureStorage.read(key: 'user_data');
    if (userData != null) {
      final userJson = jsonDecode(userData);
      return userJson['employeeId']?.toString();
    }
    return null;
  }

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

      if (data['historyData'] != null) {
        historyList = List<Map<String, dynamic>>.from(data['historyData']);
      } else {
        historyList = [
          {
            'createdAt': data['reportData']['createdAt'],
            'employeeId': {
              'firstName': data['reportData']['employeeId']['firstName'],
              'lastName': data['reportData']['employeeId']['lastName'],
            },
            'action': '보고서가 생성되었습니다.',
          }
        ];
      }

      setState(() {
        _reportTitle = data['reportData']['title'];
        isLoading = false;
      });
    } catch (e) {
      _showError('데이터를 불러오지 못했습니다: $e');
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
      _showError('코멘트를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

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

  int get totalExpenses {
    return expensesByDate.values.fold(0, (sum, list) => sum + list.length);
  }

  double get totalAmount {
    return expensesByDate.values
        .expand((list) => list)
        .map((e) => e['amount'] is num ? e['amount'] as num : 0)
        .fold(0, (sum, amt) => sum + amt.toDouble());
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      } else {}
    } catch (e) {
      print(e);
      _showError('파일을 선택하는 중 오류가 발생했습니다: $e');
    }
  }

  void _removeFile(PlatformFile file) {
    setState(() {
      _selectedFiles.remove(file);
    });
  }

  Future<void> _saveReportData() async {
    final data = {
      'reportId': _reportId,
      'employeeId': _employeeId,
      'title': _reportTitle,
      'approvalRequestId': 2,
    };

    try {
      await ApiService.updateReportData(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('보고서 제목이 업데이트되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목 업데이트에 실패했습니다: $e')),
      );
    }
  }

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

  String _formatDateTime(String dateTimeStr) {
    DateTime dateTime = DateTime.parse(dateTimeStr).toLocal();
    return DateFormat('yyyy.MM.dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko'),
      ],
      home: Scaffold(
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
              onPressed: () {},
            ),
          ],
        ),
        body: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              // Header
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

                  if (updatedTitle != null && updatedTitle != _reportTitle) {
                    if (mounted) {
                      setState(() {
                        _reportTitle = updatedTitle;
                      });
                    }
                    _saveReportData();
                  }
                },
              ),
              // TabBar
              Container(
                color: Colors.white,
                child: TabBar(
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
              // TabBarView
              Expanded(
                child: TabBarView(
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
        ),
      ),
    );
  }
}
