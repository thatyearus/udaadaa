import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';

class MissionCard extends StatelessWidget {
  const MissionCard({super.key});

  @override
  Widget build(BuildContext context) {
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
          Column(
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
            ],
          ),
        ],
      ),
    );
  }
}
