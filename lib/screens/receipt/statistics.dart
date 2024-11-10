import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(StatisticsApp());
}

class StatisticsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '지출 현황',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Statistics(),
    );
  }
}

class Statistics extends StatefulWidget {
  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  // 차트 데이터를 저장할 리스트
  List<CategoryData> pieChartData = [];
  List<PaymentMethodData> barChartData = [];

  // 비용 예측 데이터를 저장할 리스트
  List<PredictionData> predictionData = [];

  bool isLoading = true;
  String currentMonth = "2024-11"; // 현재 월을 설정
  final NumberFormat currencyFormat =
      NumberFormat('#,###'); // NumberFormat 인스턴스 생성

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  // 모든 데이터를 가져오는 메소드
  Future<void> _fetchAllData() async {
    try {
      await Future.wait([
        _fetchChartData(),
        _fetchPredictionData(),
      ]);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('에러 발생: $e');
      setState(() {
        isLoading = false;
      });
      // 사용자에게 에러 알리기 (옵션)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오는 중 오류가 발생했습니다.')),
      );
    }
  }

  // 월별 합계 데이터 가져오기 메소드
  Future<void> _fetchChartData() async {
    final url = Uri.parse('http://shcrm.ddns.net:5000/monthly_totals');

    try {
      // POST 요청 (추가 데이터가 필요 없다면 빈 바디로 전송)
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        // UTF-8로 디코딩하여 JSON 파싱
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));

        final List<dynamic> monthlyTotals = data['monthly_totals'];

        // 현재 월 데이터 찾기
        final Map<String, dynamic>? currentMonthData = monthlyTotals.firstWhere(
            (item) => item['month'] == currentMonth,
            orElse: () => null);

        if (currentMonthData == null) {
          throw Exception('현재 월 데이터가 존재하지 않습니다.');
        }

        final Map<String, dynamic> categories =
            currentMonthData['categories'] as Map<String, dynamic>;
        final Map<String, dynamic> paymentMethod =
            currentMonthData['payment_method'] as Map<String, dynamic>;

        setState(() {
          // 원형 차트 데이터: categories
          pieChartData = categories.entries.map((entry) {
            return CategoryData(
              category: entry.key,
              amount: (entry.value as num).toDouble(),
            );
          }).toList();

          // 막대 그래프 데이터: payment_method
          barChartData = paymentMethod.entries.map((entry) {
            Color color;
            switch (entry.key) {
              case "현금":
                color = Colors.green;
                break;
              case "계좌":
                color = Colors.blue;
                break;
              case "카드":
                color = Colors.red;
                break;
              case "미지정":
                color = Colors.grey;
                break;
              default:
                color = Colors.black;
            }
            return PaymentMethodData(
              method: entry.key,
              amount: (entry.value as num).toDouble(),
              color: color,
            );
          }).toList();
        });
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('데이터 가져오기 실패: $e');
    }
  }

  // 비용 예측 데이터 가져오기 메소드
  Future<void> _fetchPredictionData() async {
    final url = Uri.parse('http://shcrm.ddns.net:5000/predict');

    try {
      // POST 요청 (추가 데이터가 필요 없다면 빈 바디로 전송)
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        // UTF-8로 디코딩하여 JSON 파싱
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));

        final Map<String, dynamic> predictedUsage = data['예측_사용량'];
        final Map<String, dynamic> actualUsage = data['실제_11월_사용량'];

        // Combine predicted and actual usage into PredictionData list
        List<PredictionData> combinedData = [];

        predictedUsage.forEach((key, value) {
          double actual = actualUsage[key]?.toDouble() ?? 0.0;
          combinedData.add(PredictionData(
            category: key,
            predictedAmount: (value as num).toDouble(),
            actualAmount: actual,
          ));
        });

        setState(() {
          predictionData = combinedData;
        });
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('비용 예측 데이터 가져오기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 두 개의 탭
      child: Scaffold(
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
                // 뒤로가기 액션 처리
                Navigator.pop(context);
              },
            ),
          ),
          title: Text(
            '지출현황',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "그래프"),
              Tab(text: "비용 예측"),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // 첫 번째 탭 - 원형 차트 및 막대 그래프
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: [
                          // 원형 차트: categories
                          SfCircularChart(
                            backgroundColor: Colors.white,
                            title: ChartTitle(text: '용도'),
                            legend: Legend(
                              isVisible: true,
                              overflowMode: LegendItemOverflowMode.wrap,
                            ),
                            tooltipBehavior: TooltipBehavior(
                              enable: true,
                              format: 'point.y ₩',
                            ),
                            series: <CircularSeries>[
                              PieSeries<CategoryData, String>(
                                dataSource: pieChartData,
                                xValueMapper: (CategoryData data, _) =>
                                    data.category,
                                yValueMapper: (CategoryData data, _) =>
                                    data.amount,
                                dataLabelSettings: DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.outside,
                                ),
                                dataLabelMapper: (CategoryData data, _) =>
                                    '₩${currencyFormat.format(data.amount)}',
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          // 막대 그래프: payment_method
                          SfCartesianChart(
                            backgroundColor: Colors.white,
                            title: ChartTitle(text: '지출방법'),
                            primaryXAxis: CategoryAxis(
                              title: AxisTitle(text: ''),
                            ),
                            primaryYAxis: NumericAxis(
                              title: AxisTitle(text: '지출액 (₩)'),
                              numberFormat: NumberFormat.compact(),
                            ),
                            tooltipBehavior: TooltipBehavior(
                              enable: true,
                              format: 'point.y ₩',
                            ),
                            series: <CartesianSeries>[
                              ColumnSeries<PaymentMethodData, String>(
                                dataSource: barChartData,
                                xValueMapper: (PaymentMethodData data, _) =>
                                    data.method,
                                yValueMapper: (PaymentMethodData data, _) =>
                                    data.amount,
                                pointColorMapper: (PaymentMethodData data, _) =>
                                    data.color,
                                dataLabelSettings: DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.outside,
                                ),
                                dataLabelMapper: (PaymentMethodData data, _) =>
                                    '₩${currencyFormat.format(data.amount)}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 두 번째 탭 - 비용 예측
                  predictionData.isEmpty
                      ? Center(
                          child: Text(
                            '비용 예측 데이터를 불러오는 중입니다.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(0),
                          child: SfCartesianChart(
                            backgroundColor: Colors.white,
                            title: ChartTitle(text: '비용 예측'),
                            primaryXAxis: CategoryAxis(
                              title: AxisTitle(text: '카테고리'),
                            ),
                            primaryYAxis: NumericAxis(
                              title: AxisTitle(text: '금액 (₩)'),
                              numberFormat: NumberFormat.compact(),
                            ),
                            tooltipBehavior: TooltipBehavior(
                              enable: true,
                              shared: true,
                              format: 'point.x : ₩point.y',
                            ),
                            legend: Legend(
                              isVisible: true,
                              position: LegendPosition.bottom,
                            ),
                            series: <CartesianSeries>[
                              ColumnSeries<PredictionData, String>(
                                name: '예측',
                                dataSource: predictionData,
                                xValueMapper: (PredictionData data, _) =>
                                    data.category,
                                yValueMapper: (PredictionData data, _) =>
                                    data.predictedAmount,
                                color: Colors.blue,
                                dataLabelSettings: DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.outside,
                                  textStyle: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                  labelAlignment: ChartDataLabelAlignment
                                      .middle, // Corrected
                                ),
                                dataLabelMapper: (PredictionData data, _) =>
                                    '₩${currencyFormat.format(data.predictedAmount)}',
                              ),
                              ColumnSeries<PredictionData, String>(
                                name: '실제',
                                dataSource: predictionData,
                                xValueMapper: (PredictionData data, _) =>
                                    data.category,
                                yValueMapper: (PredictionData data, _) =>
                                    data.actualAmount,
                                color: Colors.red,
                                dataLabelSettings: DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.outside,
                                  textStyle: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                  labelAlignment: ChartDataLabelAlignment
                                      .middle, // Corrected
                                ),
                                dataLabelMapper: (PredictionData data, _) =>
                                    '₩${currencyFormat.format(data.actualAmount)}',
                              ),
                            ],
                          ),
                        ),
                ],
              ),
      ),
    );
  }
}

// 데이터 모델 클래스 for Pie Chart
class CategoryData {
  final String category;
  final double amount;

  CategoryData({
    required this.category,
    required this.amount,
  });
}

// 데이터 모델 클래스 for Bar Chart
class PaymentMethodData {
  final String method;
  final double amount;
  final Color color;

  PaymentMethodData({
    required this.method,
    required this.amount,
    required this.color,
  });
}

// 데이터 모델 클래스 for Prediction Chart
class PredictionData {
  final String category;
  final double predictedAmount;
  final double actualAmount;

  PredictionData({
    required this.category,
    required this.predictedAmount,
    required this.actualAmount,
  });
}
