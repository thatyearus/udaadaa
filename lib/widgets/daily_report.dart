import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/models/report.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/card_view.dart';

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
    return Column(
      children: [
        Row(
          children: [
            DayMiniReport(
              title: "총칼로리",
              content: '$totalCalorie',
              unit: "kcal",
            ),
            AppSpacing.horizontalSizedBoxXs,
            DayMiniReport(
              title: "체중",
              content: '${report?.weight ?? 0}',
              unit: 'kg',
              challenger: true,
            ),
          ],
        ),
        AppSpacing.verticalSizedBoxL,
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
      ],
    );
  }
}
