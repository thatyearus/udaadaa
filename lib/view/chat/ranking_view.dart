import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';

class RankingView extends StatelessWidget {
  const RankingView({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context) {
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
              "평균 몸무게 변화: 3.0kg",
              style: AppTextStyles.textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class RankingChart extends StatelessWidget {
  RankingChart({super.key});

  final List<double> data = [-2.5, 2.8, 3, 4, 5, 6, 7, -5, -6, 3.0];

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
    return AspectRatio(
      aspectRatio: 1.4,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          rotationQuarterTurns: 1,
          barGroups: data
              .asMap()
              .map(
                (key, value) => MapEntry(
                  key,
                  makeGroupData(key, value.toDouble(), AppColors.primary),
                ),
              )
              .values
              .toList(),
        ),
      ),
    );
  }
}
