import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart';
import 'package:udaadaa/utils/constant.dart';

class MissionCard extends StatelessWidget {
  const MissionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final missionCompleted = context.watch<ChallengeCubit>().getSelectedMission;
    final completionRate = missionCompleted['feed']! / 3;
    return Container(
      padding: AppSpacing.edgeInsetsM,
      margin: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxs,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.neutral[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.neutral[300],
          ),
          AppSpacing.horizontalSizedBoxS,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "미션",
                  style: AppTextStyles.textTheme.headlineMedium,
                ),
                Text(
                  "미션을 수행하세요!",
                  style: AppTextStyles.textTheme.bodyLarge,
                ),
                // Text("${missionCompleted['feed']}")
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: completionRate,
                  strokeWidth: 6,
                  color: AppColors.primary,
                  backgroundColor: AppColors.neutral[300],
                ),
              ),
              Padding(
                padding: AppSpacing.edgeInsetsS,
                child: Text(
                  '${(completionRate * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
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
