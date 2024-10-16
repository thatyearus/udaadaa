import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';

class WeeklyReport extends StatelessWidget {
  const WeeklyReport({super.key});
  double sanitizeToY(double? value) {
    return (value == null || value.isNaN || value.isInfinite) ? 0 : value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("주간 리포트", style: AppTextStyles.textTheme.displaySmall),
        AppSpacing.verticalSizedBoxL,
        SizedBox(
          height: 200, // 차트 높이 설정
          child: BarChart(
            BarChartData(
              maxY: 20, // y축의 최대 값
              minY: 0, // y축의 최소 값
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: sanitizeToY(8.0),
                      color: Colors.blue,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: sanitizeToY(10.0),
                      color: Colors.blue,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(
                      toY: sanitizeToY(13.0),
                      rodStackItems: [
                        BarChartRodStackItem(
                          sanitizeToY(0.0),
                          sanitizeToY(5.0),
                          AppColors.primary[100]!,
                        ),
                        BarChartRodStackItem(
                          sanitizeToY(5.0),
                          sanitizeToY(10.0),
                          AppColors.primary[300]!,
                        ),
                        BarChartRodStackItem(
                          sanitizeToY(10.0),
                          sanitizeToY(12.0),
                          AppColors.primary,
                        ),
                        BarChartRodStackItem(
                          sanitizeToY(12.0),
                          sanitizeToY(13.0),
                          AppColors.primary[700]!,
                        ),
                      ],
                      color: AppColors.primary,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 3,
                  barRods: [
                    BarChartRodData(
                      toY: sanitizeToY(14.0),
                      color: Colors.blue,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 4,
                  barRods: [
                    BarChartRodData(
                      toY: sanitizeToY(16.0),
                      color: Colors.blue,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 5,
                  barRods: [
                    BarChartRodData(
                      toY: sanitizeToY(18.0),
                      color: Colors.blue,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 6,
                  barRods: [
                    BarChartRodData(
                      toY: sanitizeToY(20.0),
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final style = AppTextStyles.textTheme.headlineSmall;
                      /*const style = TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      );*/
                      switch (value.toInt()) {
                        case 0:
                          return Text('월', style: style);
                        case 1:
                          return Text('화', style: style);
                        case 2:
                          return Text('수', style: style);
                        case 3:
                          return Text('목', style: style);
                        case 4:
                          return Text('금', style: style);
                        case 5:
                          return Text('토', style: style);
                        case 6:
                          return Text('일', style: style);
                        default:
                          return Text('', style: style);
                      }
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // 우측 축 숨기기
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // 상단 축 숨기기
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}
