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
  final bool challenger;

  const DayMiniReport({
    super.key,
    required this.title,
    required this.content,
    required this.unit,
    this.challenger = false,
  });

  @override
  Widget build(BuildContext context) {
    return CardView2(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: AppTextStyles.textTheme.headlineMedium),
              AppSpacing.horizontalSizedBoxS,
              (challenger
                  ? Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppSpacing.s),
                        ),
                      ),
                      padding: AppSpacing.edgeInsetsXxs,
                      child: Row(
                        children: [
                          CircleAvatar(
                            //backgroundColor: AppColors.white,
                            radius: 12,
                            child: Text(
                              "🏆",
                              style: AppTextStyles.bodyMedium(
                                const TextStyle(
                                  fontFamily: 'tossface',
                                ),
                              ),
                            ),
                          ),
                          //AppSpacing.horizontalSizedBoxXxs,
                          Text(
                            "챌린지",
                            style: AppTextStyles.bodySmall(
                              const TextStyle(color: AppColors.white),
                            ),
                          ),
                          AppSpacing.horizontalSizedBoxXxs,
                        ],
                      ),
                    )
                  : Container()),
            ],
          ),
          AppSpacing.verticalSizedBoxXxs,
          Text("$content $unit", style: AppTextStyles.textTheme.bodyLarge),
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
                            colors: [
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
                '권장 칼로리',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.verticalSizedBoxXs,
        Row(
          children: [
            DayMiniReport(
                title: '아침',
                content: '${report?.breakfast ?? 0}',
                unit: 'kcal'),
            AppSpacing.horizontalSizedBoxXs,
            DayMiniReport(
                title: '점심', content: '${report?.lunch ?? 0}', unit: 'kcal'),
          ],
        ),
        AppSpacing.verticalSizedBoxXs,
        Row(
          children: [
            DayMiniReport(
                title: '저녁', content: '${report?.dinner ?? 0}', unit: 'kcal'),
            AppSpacing.horizontalSizedBoxXs,
            DayMiniReport(
                title: '간식', content: '${report?.snack ?? 0}', unit: 'kcal'),
          ],
        ),
        AppSpacing.verticalSizedBoxL,
        Row(
          children: [
            DayMiniReport(
              title: "운동",
              content: '${report?.exercise ?? 0}',
              unit: "분",
            ),
            AppSpacing.horizontalSizedBoxXs,
            DayMiniReport(
              title: "체중",
              content: '${report?.weight ?? 0}',
              unit: 'kg',
              challenger: false,
            ),
          ],
        ),
      ],
    );
  }
}
