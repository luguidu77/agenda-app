import 'package:agendacitas/widgets/line_titles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

//https://www.youtube.com/watch?v=LB7B3zudivI
class LineChartWidget extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final dynamic data;
  LineChartWidget({Key? key, this.data}) : super(key: key);

  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  Widget build(BuildContext context) {
    debugPrint(data.toString());
    double maxY = 0.0;
    for (var item in data) {
      maxY = (item >= maxY) ? item : maxY;
    }

    return LineChart(
      LineChartData(
          backgroundColor: Colors.white10,
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: 11,
          minY: 0,
          maxY: maxY,
          titlesData: LineTitles.getTitleData(),
          gridData: FlGridData(show: false),
          lineBarsData: [
            LineChartBarData(
                spots: [
                  FlSpot(0, data[0]),
                  FlSpot(1, data[1]),
                  FlSpot(2, data[2]),
                  FlSpot(3, data[3]),
                  FlSpot(4, data[4]),
                  FlSpot(5, data[5]),
                  FlSpot(6, data[6]),
                  FlSpot(7, data[7]),
                  FlSpot(8, data[8]),
                  FlSpot(9, data[9]),
                  FlSpot(10, data[10]),
                  FlSpot(11, data[11]),
                ],
                isCurved: true,
                color: const Color(0xff02d39a),
                barWidth: 5,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xff02d39a).withOpacity(0.3))),
          ]),
    );
  }
}
