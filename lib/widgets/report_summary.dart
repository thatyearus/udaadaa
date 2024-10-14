import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/constant.dart';

class ReportSummary extends StatelessWidget {
  const ReportSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ProfileCubit>().getReport;
    final nickname = context.watch<AuthCubit>().getProfile?.nickname ?? "사용자";
    final totalCalorie = (report != null
        ? ((report.breakfast ?? 0) +
            (report.lunch ?? 0) +
            (report.dinner ?? 0) +
            (report.snack ?? 0))
        : 0);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral[0],
        border: Border.all(color: AppColors.primary[100]!),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary[100]!,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      margin: AppSpacing.edgeInsetsXxs,
      padding: AppSpacing.edgeInsetsM,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$nickname 님의 리포트",
              style: AppTextStyles.headlineMedium(
                  const TextStyle(color: AppColors.primary))),
          AppSpacing.verticalSizedBoxS,
          Text("총칼로리 : $totalCalorie kcal",
              style: AppTextStyles.textTheme.headlineMedium),
          AppSpacing.verticalSizedBoxXs,
          /*Text("아침 : ${report?.breakfast ?? 0} kcal",
              style: AppTextStyles.textTheme.bodyMedium),
          AppSpacing.verticalSizedBoxXxs,
          Text("점심 : ${report?.lunch ?? 0} kcal",
              style: AppTextStyles.textTheme.bodyMedium),
          AppSpacing.verticalSizedBoxXxs,
          Text("저녁 : ${report?.dinner ?? 0} kcal",
              style: AppTextStyles.textTheme.bodyMedium),
          AppSpacing.verticalSizedBoxXxs,
          Text("간식 : ${report?.snack ?? 0} kcal",
              style: AppTextStyles.textTheme.bodyMedium),*/
          Row(
            children: [
              Expanded(
                child: MiniCard(
                  title: "아침",
                  content: (report?.breakfast ?? 0).toString(),
                  unit: "kcal",
                  color: AppColors.white,
                ),
              ),
              Expanded(
                child: MiniCard(
                  title: "점심",
                  content: (report?.lunch ?? 0).toString(),
                  unit: "kcal",
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSizedBoxXxs,
          Row(
            children: [
              Expanded(
                child: MiniCard(
                  title: "저녁",
                  content: (report?.dinner ?? 0).toString(),
                  unit: "kcal",
                  color: AppColors.white,
                ),
              ),
              Expanded(
                child: MiniCard(
                  title: "간식",
                  content: (report?.snack ?? 0).toString(),
                  unit: "kcal",
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MiniCard extends StatelessWidget {
  final String title;
  final String content;
  final String unit;
  final Color color;

  const MiniCard({
    super.key,
    required this.title,
    required this.content,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral[0],
        border: Border.all(color: AppColors.primary[100]!),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary[100]!,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      margin: AppSpacing.edgeInsetsXxs,
      padding: AppSpacing.edgeInsetsM,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.textTheme.headlineSmall),
          AppSpacing.verticalSizedBoxXxs,
          Text("$content $unit", style: AppTextStyles.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
