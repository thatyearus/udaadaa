import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/utils/constant.dart';

class RankingView extends StatelessWidget {
  const RankingView({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context) {
    final average = context.select((ChatCubit cubit) => cubit.getWeightAverage);
    return Scaffold(
      appBar: AppBar(
        title: Text('랭킹', style: AppTextStyles.textTheme.headlineLarge),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        child: Column(
          children: [
            /*
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '순위',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '닉네임',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '점수',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('1'),
                    subtitle: Text('닉네임'),
                    trailing: Text('100'),
                  );
                },
              ),
            ),*/
            const SizedBox(height: AppSpacing.l),
            Expanded(
              child: RankingChart(),
            ),
            Text(
              "평균 몸무게 변화: ${average > 0 ? "+" : ""}${average.toStringAsPrecision(3)} kg",
              style: AppTextStyles.textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class RankingChart extends StatelessWidget {
  const RankingChart({super.key});

  BarChartGroupData makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 6,
        ),
      ],
      // showingTooltipIndicators: touchedGroupIndex == x ? [0] : [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.select((ChatCubit cubit) => cubit.getRanking);
    return AspectRatio(
      aspectRatio: 1.4,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          rotationQuarterTurns: 1,
          barGroups: List.generate(
            data.length,
            (index) =>
                makeGroupData(index, data[index].value, AppColors.primary),
          ),
          /* data
              .map(
                (value) => MapEntry(
                  value.key,
                  makeGroupData(
                      key.hashCode, value.value, AppColors.primary),
                ),
              )
              .values
              .toList(),*/

          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Padding(
                  padding: AppSpacing.edgeInsetsXxs,
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: Text(
                      data[value.toInt()].key.nickname,
                      style: AppTextStyles.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
                reservedSize: 130,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                maxIncluded: false,
                reservedSize: 26,
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor: (group) => AppColors.primary[100]!,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toStringAsFixed(2),
                  AppTextStyles.textTheme.bodySmall!,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
