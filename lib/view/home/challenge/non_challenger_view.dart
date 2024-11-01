import 'package:flutter/material.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/onboarding/eighth_view.dart';

class NonChallengerView extends StatelessWidget {
  const NonChallengerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("우다다 챌린지", style: AppTextStyles.textTheme.displayMedium),
        AppSpacing.verticalSizedBoxS,
        Text(
          "성공적인 다이어트를 위해\n챌린지에 도전해 보세요",
          textAlign: TextAlign.center,
          style: AppTextStyles.textTheme.titleLarge,
        ),
        AppSpacing.verticalSizedBoxL,
        const Text(
          "🏆",
          style: TextStyle(fontFamily: 'tossface', fontSize: 66),
        ),
        AppSpacing.verticalSizedBoxL,
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.s,
            ),
          ),
          onPressed: () {
            Analytics().logEvent(
              "홈_챌린지_참여하기",
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EighthView()),
            );
          },
          child: Text('챌린지 참여하기', style: AppTextStyles.textTheme.displaySmall),
        ),
        AppSpacing.verticalSizedBoxM,
        Text("참가자 81% 체중감량 성공", style: AppTextStyles.textTheme.titleSmall),
      ],
    );
  }
}
