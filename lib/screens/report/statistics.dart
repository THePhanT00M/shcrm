import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // For number formatting

import '../../services/api_service.dart';

class Statistics extends StatefulWidget {
  final int? reportId;

  const Statistics({Key? key, required this.reportId}) : super(key: key);

  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  int? _reportId;
  String? _employeeId;

  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  Map<int, String> _categories = {};

  List<ChartData> _pieChartData = [];
  List<PaymentMethodData> _barChartData = [];

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Initialize NumberFormat for compact numbers
  final NumberFormat _compactNumberFormat =
      NumberFormat.compact(locale: 'ko_KR');

  // Define the formatCurrency function
  String formatCurrency(double amount) {
    return '₩${_compactNumberFormat.format(amount)}';
  }

  @override
  void initState() {
    super.initState();
    if (widget.reportId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlertDialog('필수값이 누락되었습니다.');
        Navigator.pop(context);
      });
    } else {
      _reportId = widget.reportId;
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      _employeeId = await _fetchEmployeeId();
      if (_employeeId == null) {
        throw Exception('로그인 정보가 없습니다. 다시 로그인 해주세요.');
      }

      await Future.wait([
        _fetchCategories(),
        _loadReportData(_employeeId!),
      ]);
    } catch (e) {
      _handleError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _fetchEmployeeId() async {
    try {
      final userData = await _secureStorage.read(key: 'user_data');
      if (userData != null) {
        final userJson = jsonDecode(userData);
        return userJson['employeeId']?.toString();
      }
    } catch (e) {
      // Log or handle the error as needed
    }
    return null;
  }

  Future<void> _fetchCategories() async {
    try {
      final data = await ApiService.fetchCategoriesData();
      final Map<int, String> fetchedCategories = {};
      for (var item in data) {
        final categoryId = item['categoryId'];
        final categoryName = item['categoryName'];
        if (categoryId != null && categoryName != null) {
          fetchedCategories[categoryId] = categoryName;
        }
      }
      if (mounted) {
        setState(() {
          _categories = fetchedCategories;
        });
      }
    } catch (e) {
      _showAlertDialog('카테고리를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _loadReportData(String employeeId) async {
    try {
      final data = await ApiService.fetchReportDetails(
        _reportId!,
        employeeId,
      );

      final expensesData = data['expensesData'] as List<dynamic>?;

      if (expensesData != null) {
        // Process Pie Chart Data
        final List<ChartData> fetchedPieChartData = expensesData.map((item) {
          final categoryId = item['categoryId'];
          final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
          final categoryName = _categories[categoryId] ?? 'Unknown';
          return ChartData(categoryName, amount);
        }).toList();

        // Group by category and sum amounts
        final Map<String, double> categoryTotals = {};
        for (var data in fetchedPieChartData) {
          categoryTotals[data.category] =
              (categoryTotals[data.category] ?? 0) + data.value;
        }

        final List<ChartData> groupedPieChartData = categoryTotals.entries
            .map((e) => ChartData(e.key, e.value))
            .toList();

        // Process Bar Chart Data
        final Map<String, double> paymentMethodTotals = {};
        for (var item in expensesData) {
          String paymentMethod =
              item['paymentMethod']?.toString().toUpperCase() ?? 'UNKNOWN';
          double amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
          String paymentLabel = _mapPaymentMethod(paymentMethod);
          paymentMethodTotals[paymentLabel] =
              (paymentMethodTotals[paymentLabel] ?? 0) + amount;
        }

        final List<PaymentMethodData> fetchedBarChartData =
            paymentMethodTotals.entries.map((e) {
          Color color = _getPaymentMethodColor(e.key);
          return PaymentMethodData(e.key, e.value, color);
        }).toList();

        if (mounted) {
          setState(() {
            _pieChartData = groupedPieChartData;
            _barChartData = fetchedBarChartData;
          });
        }
      } else {
        throw Exception('No expenses data available.');
      }
    } catch (e) {
      _showAlertDialog('데이터를 불러오지 못했습니다: $e');
      throw e; // Re-throw to be caught in _fetchData
    }
  }

  // Mapping functions
  String _mapPaymentMethod(String method) {
    switch (method) {
      case 'CASH':
        return '현금';
      case 'TRANFER':
        return '계좌';
      case 'CARD':
        return '카드';
      default:
        return '미지정';
    }
  }

  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case '현금':
        return Colors.green;
      case '계좌':
        return Colors.blue;
      case '카드':
        return Colors.red;
      case '미지정':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  void _handleError(String message) {
    if (!mounted) return;
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    _showAlertDialog(message);
    Navigator.pop(context);
  }

  void _showError(String message) {
    _handleError(message);
  }

  // Alert Dialog
  void _showAlertDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            '알림',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Color(0xFF7A7A7A)),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text(
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Text(
          _errorMessage ?? '오류가 발생했습니다.',
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    if (_pieChartData.isEmpty && _barChartData.isEmpty) {
      return const Center(
        child: Text(
          '표시할 데이터가 없습니다.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData, // Assign the _fetchData method to handle refresh
      backgroundColor: Colors.white,
      color: Color(0xFF009EB4),
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Ensures the scroll view is always scrollable for pull-to-refresh
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pie Chart Section
            Container(
              color: Colors.white, // Set background color to white
              margin: const EdgeInsets.only(bottom: 20.0), // 20px bottom margin
              padding: const EdgeInsets.all(10.0), // Optional: inner padding
              child: SfCircularChart(
                title: ChartTitle(
                  text: '카테고리별 지출 통계',
                  textStyle: TextStyle(
                    color: Colors.black, // Set title text color to black
                    fontSize: 13, // Optional: adjust as needed
                  ),
                ),
                legend: Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap,
                  textStyle: TextStyle(
                    color: Colors.black, // Set legend text color to black
                    fontSize: 12, // Optional: adjust as needed
                  ),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CircularSeries>[
                  PieSeries<ChartData, String>(
                    dataSource: _pieChartData,
                    xValueMapper: (ChartData data, _) => data.category,
                    yValueMapper: (ChartData data, _) => data.value,
                    dataLabelMapper: (ChartData data, _) =>
                        '${data.category}: ${formatCurrency(data.value)}',
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(
                        color:
                            Colors.black, // Set data label text color to black
                        fontSize: 12, // Optional: adjust as needed
                      ),
                    ),
                  )
                ],
              ),
            ),
            // Bar Chart Section
            Container(
              color: Colors.white, // Set background color to white
              margin: const EdgeInsets.only(bottom: 20.0), // 20px bottom margin
              padding: const EdgeInsets.all(10.0), // Optional: inner padding
              child: SfCartesianChart(
                title: ChartTitle(
                  text: '결제수단별 지출 금액',
                  textStyle: TextStyle(
                    color: Colors.black, // Set title text color to black
                    fontSize: 13, // Optional: adjust as needed
                  ),
                ),
                legend: Legend(
                  isVisible: false, // Set to true if you want legends
                  textStyle: TextStyle(
                    color: Colors
                        .black, // Set legend text color to black (if visible)
                    fontSize: 12, // Optional: adjust as needed
                  ),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(
                    text: '결제수단',
                    textStyle: TextStyle(
                      color:
                          Colors.black, // Set X-axis title text color to black
                      fontSize: 12, // Optional: adjust as needed
                    ),
                  ),
                  labelStyle: TextStyle(
                    color:
                        Colors.black, // Set X-axis labels text color to black
                    fontSize: 12, // Optional: adjust as needed
                  ),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(
                    text: '금액 (₩)',
                    textStyle: TextStyle(
                      color:
                          Colors.black, // Set Y-axis title text color to black
                      fontSize: 12, // Optional: adjust as needed
                    ),
                  ),
                  numberFormat: _compactNumberFormat,
                  labelFormat: '{value}',
                  labelStyle: TextStyle(
                    color:
                        Colors.black, // Set Y-axis labels text color to black
                    fontSize: 12, // Optional: adjust as needed
                  ),
                ),
                series: <CartesianSeries>[
                  ColumnSeries<PaymentMethodData, String>(
                    dataSource: _barChartData,
                    xValueMapper: (PaymentMethodData data, _) =>
                        data.paymentMethod,
                    yValueMapper: (PaymentMethodData data, _) => data.amount,
                    pointColorMapper: (PaymentMethodData data, _) => data.color,
                    dataLabelMapper: (PaymentMethodData data, _) =>
                        formatCurrency(data.amount),
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.top,
                      textStyle: TextStyle(
                        color:
                            Colors.black, // Set data label text color to black
                        fontSize: 12, // Optional: adjust as needed
                      ),
                    ),
                    name: '지출 금액',
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If reportId is null, an empty scaffold is shown briefly before popping
    return Scaffold(
      backgroundColor: const Color(0xFFf0f0f0), // Light grey background
      appBar: AppBar(
        backgroundColor: const Color(0xFF009EB4),
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
        title: const Text(
          '보고서 지출현황 통계',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0), // Outer padding
        child: _buildBody(),
      ),
    );
  }
}

class ChartData {
  final String category;
  final double value;

  ChartData(this.category, this.value);
}

class PaymentMethodData {
  final String paymentMethod;
  final double amount;
  final Color color;

  PaymentMethodData(this.paymentMethod, this.amount, this.color);
}
