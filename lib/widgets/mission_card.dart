import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart';
import 'package:udaadaa/utils/constant.dart';

class MissionCard extends StatelessWidget {
  final int index;
  final List<String> missionName = ["feed", "weight", "reaction"];
  final List<int> missionRequired = [2, 1, 3];
  final List<String> missionDetail = [
    "피드에 식단 사진 2장 인증하기",
    "오늘의 몸무게 인증하기",
    "피드에 응원 3개 남기기",
  ];
  MissionCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final missionCompleted = context.watch<ChallengeCubit>().getSelectedMission;
    final completionRate = min(
        1.0, missionCompleted[missionName[index]]! / missionRequired[index]);
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
                  "미션 ${index + 1}",
                  style: AppTextStyles.textTheme.headlineMedium,
                ),
                Text(
                  missionDetail[index],
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
