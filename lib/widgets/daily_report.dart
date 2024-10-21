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

  const DayMiniReport({
    super.key,
    required this.title,
    required this.content,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return CardView2(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.textTheme.headlineMedium),
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
