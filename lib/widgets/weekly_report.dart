import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/legend_widget.dart';

class WeeklyReport extends StatelessWidget {
  const WeeklyReport({super.key});

  double sanitizeToY(double? value) {
    return (value == null || value.isNaN || value.isInfinite) ? 0 : value;
  }

  String getDate(DateTime date) {
    return "${date.month}/${date.day}";
  }

  BarChartGroupData chartData(
    int x,
    double val1,
    double val2,
    double val3,
    double val4,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: sanitizeToY(val1 + val2 + val3 + val4),
          rodStackItems: [
            BarChartRodStackItem(
              sanitizeToY(0.0),
              sanitizeToY(val1),
              AppColors.primary[100]!,
            ),
            BarChartRodStackItem(
              sanitizeToY(val1),
              sanitizeToY(val1 + val2),
              AppColors.primary[300]!,
            ),
            BarChartRodStackItem(
              sanitizeToY(val1 + val2),
              sanitizeToY(val1 + val2 + val3),
              AppColors.primary,
            ),
            BarChartRodStackItem(
              sanitizeToY(val1 + val2 + val3),
              sanitizeToY(val1 + val2 + val3 + val4),
              AppColors.primary[700]!,
            ),
          ],
          color: AppColors.primary,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final weeklyReport = context.watch<ProfileCubit>().getWeeklyReport;
    final selectedDate = context.select<ProfileCubit, DateTime?>(
            (cubit) => cubit.getSelectedDate) ??
        DateTime.now();
    return Column(
      children: [
        Text("주간 리포트", style: AppTextStyles.textTheme.displaySmall),
        AppSpacing.verticalSizedBoxL,
        SizedBox(
          height: 200, // 차트 높이 설정
          child: BarChart(
            BarChartData(
              barGroups: List.generate(weeklyReport.length, (index) {
                final report = weeklyReport[index];
                return chartData(
                  index,
                  report?.breakfast?.toDouble() ?? 0.0,
                  report?.lunch?.toDouble() ?? 0.0,
                  report?.dinner?.toDouble() ?? 0.0,
                  report?.snack?.toDouble() ?? 0.0,
                );
              }),
              /*
                chartData(0, 3.0, 4.0, 3.0, 2.0),
                chartData(2, 2.0, 4.0, 3.0, 2.0),
                chartData(3, 4.0, 3.0, 5.0, 2.0),
                chartData(4, 3.0, 2.0, 4.0, 3.0),
                chartData(5, 2.0, 3.0, 2.0, 3.0),
                chartData(6, 3.0, 4.0, 3.0, 4.0),*/

              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final style = AppTextStyles.textTheme.bodyMedium;
                      /*const style = TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      );*/
                      switch (value.toInt()) {
                        case 0:
                          return Text(
                              getDate(
                                selectedDate.subtract(const Duration(days: 6)),
                              ),
                              style: style);
                        case 1:
                          return Text(
                              getDate(
                                selectedDate.subtract(const Duration(days: 5)),
                              ),
                              style: style);
                        case 2:
                          return Text(
                              getDate(
                                selectedDate.subtract(const Duration(days: 4)),
                              ),
                              style: style);
                        case 3:
                          return Text(
                              getDate(
                                selectedDate.subtract(const Duration(days: 3)),
                              ),
                              style: style);
                        case 4:
                          return Text(
                              getDate(
                                selectedDate.subtract(const Duration(days: 2)),
                              ),
                              style: style);
                        case 5:
                          return Text(
                              getDate(
                                selectedDate.subtract(const Duration(days: 1)),
                              ),
                              style: style);
                        case 6:
                          return Text(getDate(selectedDate), style: style);
                        default:
                          return Text('', style: style);
                      }
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: AppTextStyles.textTheme.bodyMedium,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        AppSpacing.verticalSizedBoxS,
        LegendsListWidget(legends: [
          Legend("아침", AppColors.primary[100]!),
          Legend("점심", AppColors.primary[300]!),
          Legend("저녁", AppColors.primary),
          Legend("간식", AppColors.primary[700]!),
        ]),
      ],
    );
  }
}
