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
  List<_ChartData> predictionData = [];

  bool isInitialLoading = true; // 초기 로딩 상태
  String currentMonth = "2024-11"; // 현재 월을 설정
  final NumberFormat currencyFormat =
      NumberFormat('#,###'); // NumberFormat 인스턴스 생성

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  @override
  void dispose() {
    // 추가적인 정리 작업이 필요하다면 여기에 수행
    super.dispose();
  }

  // 모든 데이터를 가져오는 메소드
  Future<void> _fetchAllData() async {
    try {
      await Future.wait([
        _fetchChartData(),
        _fetchPredictionData(),
      ]);

      if (!mounted) return; // 위젯이 아직 트리에 존재하는지 확인

      setState(() {
        isInitialLoading = false;
      });
    } catch (e) {
      print('에러 발생: $e');

      if (!mounted) return; // 위젯이 아직 트리에 존재하는지 확인

      setState(() {
        isInitialLoading = false;
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

        if (!mounted) return; // 위젯이 아직 트리에 존재하는지 확인

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

        // Combine predicted and actual usage into _ChartData list
        List<_ChartData> combinedData = [];

        predictedUsage.forEach((key, value) {
          double actual = actualUsage[key]?.toDouble() ?? 0.0;
          combinedData.add(_ChartData(
            category: key,
            amount: (value as num).toDouble(),
            seriesName: '예측',
          ));
          combinedData.add(_ChartData(
            category: key,
            amount: actual,
            seriesName: '실제',
          ));
        });

        if (!mounted) return; // 위젯이 아직 트리에 존재하는지 확인

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

  // 새로고침을 처리하는 메소드
  Future<void> _handleRefresh() async {
    try {
      await _fetchAllData();
    } catch (e) {
      // 에러 발생 시 스낵바로 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('새로고침 중 오류가 발생했습니다.')),
      );
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
        body: isInitialLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // 첫 번째 탭 - 원형 차트 및 막대 그래프
                  RefreshIndicator(
                    onRefresh: _handleRefresh, // 새로고침 콜백 연결
                    backgroundColor: Colors.white, // 배경색을 흰색으로 설정
                    color: Color(0xFF009EB4), // 프로그레스 인디케이터의 색상 설정
                    child: SingleChildScrollView(
                      physics:
                          AlwaysScrollableScrollPhysics(), // 항상 스크롤 가능하게 설정
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
                                    labelPosition:
                                        ChartDataLabelPosition.outside,
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
                                title: AxisTitle(text: ''),
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
                                  pointColorMapper:
                                      (PaymentMethodData data, _) => data.color,
                                  dataLabelSettings: DataLabelSettings(
                                    isVisible: true,
                                    labelPosition:
                                        ChartDataLabelPosition.outside,
                                    textStyle: TextStyle(
                                        color: Colors.black, // Changed to black
                                        fontSize: 10),
                                  ),
                                  dataLabelMapper: (PaymentMethodData data,
                                          _) =>
                                      '₩${currencyFormat.format(data.amount)}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 두 번째 탭 - 비용 예측
                  RefreshIndicator(
                    onRefresh: _handleRefresh, // 새로고침 콜백 연결
                    backgroundColor: Colors.white, // 배경색을 흰색으로 설정
                    color: Color(0xFF009EB4), // 프로그레스 인디케이터의 색상 설정
                    child: predictionData.isEmpty
                        ? SingleChildScrollView(
                            physics:
                                AlwaysScrollableScrollPhysics(), // 항상 스크롤 가능하게 설정
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  '비용 예측 데이터를 불러오는 중입니다.',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            physics:
                                AlwaysScrollableScrollPhysics(), // 항상 스크롤 가능하게 설정
                            child: Container(
                              height: MediaQuery.of(context).size.height - 125,
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: SfCartesianChart(
                                  backgroundColor: Colors.white,
                                  title: ChartTitle(text: ''),
                                  primaryXAxis: CategoryAxis(
                                    title: AxisTitle(text: ''),
                                  ),
                                  primaryYAxis: NumericAxis(
                                    title: AxisTitle(text: ''),
                                    numberFormat: NumberFormat.compact(),
                                  ),
                                  axes: <ChartAxis>[
                                    NumericAxis(
                                      name: 'secondaryYAxis',
                                      title: AxisTitle(text: ''),
                                      opposedPosition: true, // 오른쪽에 배치
                                      numberFormat: NumberFormat.compact(),
                                    ),
                                  ],
                                  tooltipBehavior: TooltipBehavior(
                                    enable: true,
                                    shared: true,
                                    format: 'point.x : ₩point.y',
                                  ),
                                  legend: Legend(
                                    isVisible: true,
                                    position: LegendPosition.bottom,
                                  ),
                                  series: <CartesianSeries<_ChartData, String>>[
                                    // 예측 지출 BarSeries (primaryYAxis에 매핑)
                                    BarSeries<_ChartData, String>(
                                      name: '예측',
                                      dataSource: predictionData
                                          .where(
                                              (data) => data.seriesName == '예측')
                                          .toList(),
                                      xValueMapper: (_ChartData data, _) =>
                                          data.category,
                                      yValueMapper: (_ChartData data, _) =>
                                          data.amount,
                                      color: Colors.blue
                                          .withOpacity(0.8), // 불투명도 적용
                                      yAxisName: 'primaryYAxis',
                                      dataLabelSettings: DataLabelSettings(
                                        isVisible: true,
                                        labelPosition:
                                            ChartDataLabelPosition.outside,
                                        textStyle: TextStyle(
                                          color: Colors.black, // 텍스트 색상
                                          fontSize: 10,
                                        ),
                                      ),
                                      dataLabelMapper: (_ChartData data, _) =>
                                          '₩${currencyFormat.format(data.amount)}',
                                    ),
                                    // 실제 지출 BarSeries (secondaryYAxis에 매핑)
                                    BarSeries<_ChartData, String>(
                                      name: '실제',
                                      dataSource: predictionData
                                          .where(
                                              (data) => data.seriesName == '실제')
                                          .toList(),
                                      xValueMapper: (_ChartData data, _) =>
                                          data.category,
                                      yValueMapper: (_ChartData data, _) =>
                                          data.amount,
                                      color: Colors.red
                                          .withOpacity(0.8), // 불투명도 적용
                                      yAxisName: 'secondaryYAxis',
                                      dataLabelSettings: DataLabelSettings(
                                        isVisible: true,
                                        labelPosition:
                                            ChartDataLabelPosition.outside,
                                        textStyle: TextStyle(
                                          color: Colors.black, // 텍스트 색상
                                          fontSize: 10,
                                        ),
                                      ),
                                      dataLabelMapper: (_ChartData data, _) =>
                                          '₩${currencyFormat.format(data.amount)}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

// 데이터 모델 클래스 for generic Bar Series
class _ChartData {
  final String category;
  final double amount;
  final String seriesName; // To distinguish between different series

  _ChartData({
    required this.category,
    required this.amount,
    required this.seriesName,
  });
}
