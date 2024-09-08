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
    final totalExercise = report?.exercise ?? 0;
    final weight = report?.weight ?? 0;

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
      padding: AppSpacing.edgeInsetsM,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("$nickname 님의 리포트",
            style: AppTextStyles.headlineMedium(
                const TextStyle(color: AppColors.primary))),
        AppSpacing.verticalSizedBoxS,
        Text("총칼로리 : $totalCalorie kcal",
            style: AppTextStyles.textTheme.bodyLarge),
        Text("운동 시간 : $totalExercise 분",
            style: AppTextStyles.textTheme.bodyLarge),
        Text("체중 : $weight kg", style: AppTextStyles.textTheme.bodyLarge),
      ]),
    );
  }
}
