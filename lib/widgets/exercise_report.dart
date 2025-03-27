import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/legend_widget.dart';

class ExerciseReport extends StatelessWidget {
  const ExerciseReport({super.key});

  double sanitizeToY(double? value) {
    return (value == null || value.isNaN || value.isInfinite) ? 0 : value;
  }

  String getDate(DateTime date) {
    return "${date.month}/${date.day}";
  }

  BarChartGroupData chartData(
    int x,
    double val1,
  ) {
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: [
        BarChartRodData(
          fromY: sanitizeToY(0.0),
          toY: sanitizeToY(val1),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("운동 시간", style: AppTextStyles.textTheme.displaySmall),
          ],
        ),
        AppSpacing.verticalSizedBoxL,
        SizedBox(
          height: 200, // 차트 높이 설정
          child: BarChart(
            BarChartData(
              barGroups: List.generate(weeklyReport.length, (index) {
                final report = weeklyReport[index];
                return chartData(
                  index,
                  report?.weight ?? 0.0,
                );
              }),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => AppColors.primary[100]!,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final allValue = rod.toY;

                    final text = '$allValue kg';

                    return BarTooltipItem(
                      text,
                      AppTextStyles.textTheme.bodySmall!,
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final style = AppTextStyles.textTheme.bodySmall;
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
                    reservedSize: 32,
                    maxIncluded: false,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: AppTextStyles.textTheme.bodySmall,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        AppSpacing.verticalSizedBoxS,
        LegendsListWidget(legends: [
          Legend("운동 시간(분)", AppColors.primary),
        ]),
      ],
    );
  }
}
