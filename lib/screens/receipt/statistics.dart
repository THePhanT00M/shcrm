import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';

class Statistics extends StatefulWidget {
  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  List<ChartData> pieChartData = [];
  List<ChartData> barChartData = [];
  List<ChartData> spendListData = []; // 두 번째 탭에 사용할 데이터
  List<ChartData> forecastData = []; // 세 번째 탭 - 비용 예측 데이터
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChartData();
  }

  Future<void> _fetchChartData() async {
    final combinedJson = '''
      [
        {"spend": "카드", "item": "공책", "category": "소모품비", "amount": 5000, "name": "홍길동"},
        {"spend": "현금", "item": "버스요금", "category": "교통비", "amount": 10000, "name": "이수정"},
        {"spend": "계좌이체", "item": "강의료", "category": "교육훈련비", "amount": 15000, "name": "박지민"},
        {"spend": "카드", "item": "식비", "category": "복리후생비", "amount": 20000, "name": "김민수"},
        {"spend": "카드", "item": "관리비용", "category": "관리비", "amount": 25000, "name": "최영희"}
      ]
    ''';

    final forecastJson = '''
      [
        {"category": "1월", "amount": 18000},
        {"category": "2월", "amount": 22000},
        {"category": "3월", "amount": 20000},
        {"category": "4월", "amount": 25000},
        {"category": "5월", "amount": 24000},
        {"category": "6월", "amount": 26000},
        {"category": "7월", "amount": 28000},
        {"category": "8월", "amount": 27000},
        {"category": "9월", "amount": 30000},
        {"category": "10월", "amount": 31000},
        {"category": "11월", "amount": 29000},
        {"category": "12월", "amount": 32000}
      ]
    ''';

    final combinedData = json.decode(combinedJson) as List;
    final forecastDataJson = json.decode(forecastJson) as List;

    setState(() {
      // pieChartData는 지출 품목 기준
      pieChartData = combinedData
          .where((item) => ["소모품비", "교통비", "교육훈련비", "복리후생비", "관리비"]
              .contains(item['category']))
          .map((item) => ChartData(
                item['category'],
                item['amount'] as int,
                item['name'],
                spend: item['spend'],
                item: item['item'],
              ))
          .toList();

      // barChartData는 결제 방법 (spend) 기준으로 합산 및 색상 지정
      Map<String, int> spendAmounts = {
        "현금": 0,
        "계좌이체": 0,
        "카드": 0,
      };

      for (var item in combinedData) {
        if (item['spend'] != null && spendAmounts.containsKey(item['spend'])) {
          spendAmounts[item['spend']] =
              spendAmounts[item['spend']]! + (item['amount'] as int);
        }
      }

      barChartData = spendAmounts.entries.map((entry) {
        Color color;
        switch (entry.key) {
          case "현금":
            color = Colors.green;
            break;
          case "계좌이체":
            color = Colors.blue;
            break;
          case "카드":
            color = Colors.red;
            break;
          default:
            color = Colors.grey;
        }
        return ChartData(entry.key, entry.value, null, color: color);
      }).toList();

      // 두 번째 탭에 사용될 지출 방법별 리스트 데이터
      spendListData = combinedData
          .map((item) => ChartData(
                item['spend'] ?? "",
                item['amount'] as int,
                item['name'],
                spend: item['spend'],
              ))
          .toList();

      // 세 번째 탭 - 월별 비용 예측 데이터를 생성
      forecastData = forecastDataJson
          .map((item) =>
              ChartData(item['category'], item['amount'] as int, null))
          .toList();

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
              Tab(text: "지출 방법"),
              Tab(text: "비용 예측"),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // 첫 번째 탭 - 원형 차트 및 막대 그래프
                  Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: SfCircularChart(
                            backgroundColor: Colors.white,
                            title: ChartTitle(text: '용도'),
                            legend: Legend(isVisible: true),
                            series: <CircularSeries>[
                              PieSeries<ChartData, String>(
                                dataSource: pieChartData,
                                xValueMapper: (ChartData data, _) =>
                                    data.category,
                                yValueMapper: (ChartData data, _) =>
                                    data.amount,
                                dataLabelSettings:
                                    DataLabelSettings(isVisible: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: SfCartesianChart(
                            backgroundColor: Colors.white,
                            title: ChartTitle(text: '지출 방법'),
                            primaryXAxis: CategoryAxis(),
                            series: <CartesianSeries<ChartData, String>>[
                              ColumnSeries<ChartData, String>(
                                dataSource: barChartData,
                                xValueMapper: (ChartData data, _) =>
                                    data.category,
                                yValueMapper: (ChartData data, _) =>
                                    data.amount,
                                pointColorMapper: (ChartData data, _) =>
                                    data.color,
                                dataLabelSettings:
                                    DataLabelSettings(isVisible: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 두 번째 탭 - 지출 방법 리스트
                  Container(
                    color: Colors.white, // ListView 배경색을 화이트로 설정
                    child: ListView(
                      children: spendListData
                          .where((data) => data.spend != null)
                          .map((data) {
                        return ListTile(
                          title: Text("[${data.spend}] ${data.name}"),
                          trailing: Text("₩${data.amount}"),
                        );
                      }).toList(),
                    ),
                  ),
                  // 세 번째 탭 - 비용 예측 그래프
                  SfCartesianChart(
                    backgroundColor: Colors.white,
                    title: ChartTitle(text: '월별 비용 예측'),
                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(text: '월'),
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(text: '예상 지출 (₩)'),
                      minimum: 15000, // 최소 Y축 값을 설정하여 시작점을 조정
                    ),
                    series: <LineSeries<ChartData, String>>[
                      LineSeries<ChartData, String>(
                        dataSource: forecastData,
                        xValueMapper: (ChartData data, _) => data.category,
                        yValueMapper: (ChartData data, _) => data.amount,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                        color: Colors.blue,
                        width: 2,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

// 그래프에 사용할 데이터 모델 클래스
class ChartData {
  final String category;
  final int amount;
  final String? name;
  final String? spend;
  final String? item;
  final Color? color; // 색상 추가

  ChartData(this.category, this.amount, this.name,
      {this.spend, this.item, this.color});
}
