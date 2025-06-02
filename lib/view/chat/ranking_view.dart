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
              "평균 몸무게 변화: ${average > 0 ? "+" : ""}${average.toStringAsFixed(2)} kg",
              style: AppTextStyles.textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class RankingChart extends StatefulWidget {
  const RankingChart({super.key});

  @override
  State<RankingChart> createState() => _RankingChartState();
}

class _RankingChartState extends State<RankingChart> {
  int? touchedGroupIndex;

  BarChartGroupData makeGroupData(int x, double y, Color color,
      {bool showTooltip = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 6,
        ),
      ],
      showingTooltipIndicators: showTooltip ? [0] : [],
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
            (index) => makeGroupData(
              index,
              data[index].value,
              AppColors.primary,
              showTooltip: touchedGroupIndex == index,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  return Padding(
                    padding: AppSpacing.edgeInsetsXxs,
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: GestureDetector(
                        onTapDown: (_) {
                          setState(() {
                            touchedGroupIndex = idx;
                          });
                        },
                        onTapUp: (_) {
                          setState(() {
                            touchedGroupIndex = null;
                          });
                        },
                        onTapCancel: () {
                          setState(() {
                            touchedGroupIndex = null;
                          });
                        },
                        child: Text(
                          data[idx].key.nickname,
                          style: AppTextStyles.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  );
                },
                reservedSize: 130,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                maxIncluded: false,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value % 0.5 != 0) return const SizedBox();
                  return RotatedBox(
                    quarterTurns: -1,
                    child: SizedBox(
                      width: 40,
                      child: Text(value.toStringAsFixed(1)),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchExtraThreshold:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 60),
            touchTooltipData: BarTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor: (group) => AppColors.primary[100]!,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toStringAsFixed(2)} kg',
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
