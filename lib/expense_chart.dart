import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'db_helper.dart';

class ExpenseChart extends StatefulWidget {
  @override
  _ExpenseChartState createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  List<PieChartSectionData> _sections = [];
  String _topCategory = "데이터 없음";
  int _totalAmount = 0;
  List<Map<String, dynamic>> _summaryData = []; // 범례를 위한 데이터 저장용

  // 차트에 사용할 공통 색상 리스트
  final List<Color> _chartColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  void _loadChartData() async {
    final summary = await DBHelper().getCategorySummary();

    int tempTotal = 0;
    String topCat = "없음";
    double maxAmount = 0;

    for (var row in summary) {
      double amount = double.parse(row['total'].toString());
      tempTotal += amount.toInt();
      if (amount > maxAmount) {
        maxAmount = amount;
        topCat = row['category'];
      }
    }

    setState(() {
      _summaryData = summary;
      _totalAmount = tempTotal;
      _topCategory = topCat;

      _sections = List.generate(summary.length, (i) {
        final data = summary[i];
        final double val = double.parse(data['total'].toString());

        // [수정] 비중이 15% 미만인 작은 칸은 글자를 숨겨서 겹침 방지
        bool isTooSmall = (val / _totalAmount) < 0.15;

        return PieChartSectionData(
          color: _chartColors[i % _chartColors.length],
          value: val,
          showTitle: !isTooSmall,
          title: '${data['category']}\n${val.toInt()}원',
          radius: 100,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('소비 분석 그래프')),
      body: _sections.isEmpty
          ? Center(child: Text('분석할 데이터가 없습니다.'))
          : SingleChildScrollView(
              // 화면이 작은 폰에서 리포트가 잘리지 않도록 스크롤 추가
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Text("카테고리별 지출 비중",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                  // 1. 그래프 영역 (고정 높이 부여)
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(sections: _sections, centerSpaceRadius: 40),
                    ),
                  ),

                  // 2. [추가] 범례(Legend) 영역: 작은 칸의 정보를 여기서 확인
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10),
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _summaryData.asMap().entries.map((entry) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                width: 12,
                                height: 12,
                                color: _chartColors[
                                    entry.key % _chartColors.length]),
                            SizedBox(width: 4),
                            Text(
                                "${entry.value['category']}: ${entry.value['total']}원",
                                style: TextStyle(fontSize: 13)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 60),
                  // 3. 분석 리포트 카드
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 0, // 그림자를 없애고 배경색으로 깔끔하게
                    color: Colors.blue.shade50.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // 상단 타이틀 부분
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome,
                                  color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "소비 분석 리포트",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue.shade900),
                              ),
                            ],
                          ),
                          Divider(height: 30, color: Colors.blue.shade100),

                          // 총 지출액 (RichText 적용)
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 15),
                              children: [
                                TextSpan(text: "이번 달 총 지출은 "),
                                TextSpan(
                                  text: "${_totalAmount}원",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700),
                                ),
                                TextSpan(text: "입니다."),
                              ],
                            ),
                          ),

                          SizedBox(height: 10),

                          // 주요 소비 분야 (RichText 적용)
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 15),
                              children: [
                                TextSpan(text: "가장 많이 지출한 분야는 "),
                                TextSpan(
                                  text: "[$_topCategory]",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17, // 조금 더 크게 강조
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                TextSpan(text: "입니다!"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
