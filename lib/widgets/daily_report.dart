import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/models/report.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/card_view.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/utils/recommended_calorie_calculator.dart';

class DayMiniReport extends StatelessWidget {
  final String title;
  final String content;
  final String unit;
  final String? yesterdayContent;
  final bool challenger;

  const DayMiniReport({
    super.key,
    required this.title,
    required this.content,
    required this.unit,
    this.yesterdayContent,
    this.challenger = false,
  });

  @override
  Widget build(BuildContext context) {
    final double currentValue = double.tryParse(content) ?? 0;
    final double yesterdayValue =
        (yesterdayContent == null || yesterdayContent?.trim().isEmpty == true)
            ? 0
            : double.tryParse(yesterdayContent ?? '') ?? 0;
    final double diff = currentValue - yesterdayValue;
    final bool isUp = diff > 0;
    final Color diffColor = isUp ? Colors.red : Colors.blue;
    final IconData diffIcon =
        isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down;
    final String diffStr = (diff % 1 == 0)
        ? diff.abs().toInt().toString()
        : diff.abs().toStringAsFixed(1);
    return CardView2(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.grayscale[500],
                ),
              ),
            ],
          ),
          AppSpacing.verticalSizedBoxXs,
          Text(
            "$content $unit",
            style: AppTextStyles.textTheme.headlineMedium?.copyWith(
              height: 0.9,
            ),
          ),
          Row(
            children: [
              Text(
                "전일대비",
                style: AppTextStyles.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.grayscale[400],
                ),
              ),
              Transform.translate(
                offset: const Offset(-3.5, 0),
                child: Icon(
                  diffIcon,
                  size: 24,
                  color: diffColor,
                  weight: 900,
                ),
              ),
              Transform.translate(
                offset: const Offset(-8, 0),
                child: Text(
                  diffStr,
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: diffColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DailyReport extends StatelessWidget {
  const DailyReport({super.key});

  @override
  Widget build(BuildContext context) {
    Report? report = context.watch<ProfileCubit>().getSelectedReport;
    Report? yesterdayReport = context.watch<ProfileCubit>().getYesterdayReport;
    final totalCalorie = (report != null
        ? ((report.breakfast ?? 0) +
            (report.lunch ?? 0) +
            (report.dinner ?? 0) +
            (report.snack ?? 0))
        : 0);
    final profile = context.read<AuthCubit>().getProfile;
    final recommendedCalorie = profile != null
        ? RecommendedCalorieCalculator.calculate(profile).round()
        : 0;
    final percent = recommendedCalorie > 0
        ? (totalCalorie / recommendedCalorie).clamp(0.0, 1.0)
        : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  color: AppColors.primary[50],
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: percent,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19),
                          gradient: LinearGradient(
                            colors: totalCalorie > recommendedCalorie
                                ? [
                                    Colors.red[700]!, // 진한 빨간색
                                    Colors.red[400]!, // 중간 빨간색
                                    Colors.red[200]!, // 연한 빨간색
                                  ]
                                : [
                                    AppColors.primary, // 진한 브랜드 컬러
                                    AppColors.primary[200]!, // 중간 브랜드 컬러
                                    AppColors.primary[100]!, // 연한 브랜드 컬러
                                  ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$totalCalorie',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            TextSpan(
                              text: ' / $recommendedCalorie kcal',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '섭취 / 권장 칼로리',
                style: TextStyle(
                  color: totalCalorie > recommendedCalorie
                      ? Colors.red[700]
                      : AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.verticalSizedBoxXs,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              DayMiniReport(
                  title: '아침',
                  content: '${report?.breakfast ?? 0}',
                  unit: 'kcal',
                  yesterdayContent: '${yesterdayReport?.breakfast ?? 0}'),
              AppSpacing.horizontalSizedBoxM,
              DayMiniReport(
                  title: '점심',
                  content: '${report?.lunch ?? 0}',
                  unit: 'kcal',
                  yesterdayContent: '${yesterdayReport?.lunch ?? 0}'),
            ],
          ),
        ),
        AppSpacing.verticalSizedBoxXs,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              DayMiniReport(
                  title: '저녁',
                  content: '${report?.dinner ?? 0}',
                  unit: 'kcal',
                  yesterdayContent: '${yesterdayReport?.dinner ?? 0}'),
              AppSpacing.horizontalSizedBoxM,
              DayMiniReport(
                  title: '간식',
                  content: '${report?.snack ?? 0}',
                  unit: 'kcal',
                  yesterdayContent: '${yesterdayReport?.snack ?? 0}'),
            ],
          ),
        ),
        AppSpacing.verticalSizedBoxL,
        Padding(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 25,
          ),
          child: Row(
            children: [
              DayMiniReport(
                title: "운동",
                content: '${report?.exercise ?? 0}',
                unit: "분",
                yesterdayContent: '${yesterdayReport?.exercise ?? 0}',
              ),
              AppSpacing.horizontalSizedBoxM,
              DayMiniReport(
                title: "체중",
                content: '${report?.weight ?? 0}',
                unit: 'kg',
                yesterdayContent: '${yesterdayReport?.weight ?? 0}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
