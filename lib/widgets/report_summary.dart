import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/constant.dart';

class ReportSummary extends StatelessWidget {
  const ReportSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ProfileCubit>().getReport;
    return Container(
      color: AppColors.neutral[100],
      padding: AppSpacing.edgeInsetsM,
      width: double.infinity,
      alignment: Alignment.center,
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (BuildContext context, ProfileState state) {
          if (report != null) {
            return Column(children: [
              const Text("오늘의 기록"),
              Text(
                  "총 칼로리 : ${(report.breakfast ?? 0) + (report.lunch ?? 0) + (report.dinner ?? 0) + (report.snack ?? 0)} kcal"),
              Text("운동 시간 : ${report.exercise ?? 0} 분"),
              Text("체중 : ${report.weight ?? 0} kg"),
            ]);
          } else {
            return const Text("오늘의 기록이 없습니다.");
          }
        },
      ),
    );
  }
}
