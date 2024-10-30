import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/onboarding/ninth_view.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/view/main_view.dart';

class EighthView extends StatelessWidget {
  const EighthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "우다다 친구들과 함께\n일주일 다이어트 챌린지\n무료로 참여해볼까요?",
                style: AppTextStyles.textTheme.displayMedium,
              ),
              AppSpacing.sizedBoxXxl,
              AppSpacing.sizedBoxXxl,
              Center(
                // 중앙 정렬을 위해 Center 위젯으로 감싸기
                child: Column(
                  children: [
                    Image.asset(
                      "assets/onboarding_effect.png",
                      width: 300,
                    ),
                    AppSpacing.sizedBoxXl,
                    Text.rich(
                      TextSpan(children: [
                        const TextSpan(text: "실험 결과, 챌린지 참여자\n"),
                        TextSpan(
                          text: "다이어트 성공 확률 87%\n",
                          style: AppTextStyles.displaySmall(
                            const TextStyle(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const TextSpan(text: "우다다와 함께 해봐요\n"),
                      ]),
                      style: AppTextStyles.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            width: double.infinity,
            child: FloatingActionButton.extended(
              heroTag: 'onboarding7',
              onPressed: () {
                Analytics().logEvent(
                  "온보딩_챌린지참여",
                  parameters: {"버튼": "클릭"},
                );
                PreferencesService().setBool('isOnboardingComplete', true);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const NinthView()),
                );
              },
              label: Text(
                '챌린지 참여하기',
                style: AppTextStyles.textTheme.titleMedium
                    ?.copyWith(color: AppColors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          AppSpacing.verticalSizedBoxS,
          GestureDetector(
            onTap: () {
              Analytics().logEvent(
                "온보딩_챌린지_미참여",
                parameters: {"다음에_할래요": "클릭"},
              );
              PreferencesService().setBool('isOnboardingComplete', true);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainView()),
              );
            },
            child: Text(
              '다음에 할래요',
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral[500],
                decoration: TextDecoration.underline,
                decorationColor: AppColors.neutral[500],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
