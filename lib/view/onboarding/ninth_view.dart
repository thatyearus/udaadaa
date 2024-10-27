import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/view/onboarding/tenth_view.dart';


class NinthView extends StatelessWidget {
  const NinthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("챌린지에서 매일 진행하는\n미션 3개 확인 해볼까요?",
                  style: AppTextStyles.textTheme.displayMedium),
              AppSpacing.verticalSizedBoxXxl,
              Image.asset(
                  "assets/onboarding_mission1.png",
                width: double.infinity,
              ),
              AppSpacing.verticalSizedBoxXxl,
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "매일 몸무게를 재고\n식단을 기록하는 것만으로도\n다이어트 "
                      ),
                      TextSpan(
                        text: "성공률 4.2배 ",
                        style: AppTextStyles.displaySmall(
                          const TextStyle(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const TextSpan(
                        text: "증가",
                      ),
                    ],
                  ),
                  style: AppTextStyles.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        width: double.infinity,
        child: FloatingActionButton.extended(
          heroTag: 'onboarding8',
          onPressed: () {
            Analytics().logEvent(
              "온보딩_미션확인",
              parameters: {"버튼": "클릭"},
            );
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const TenthView()),
            );

          },
          label: Text(
            '미션 확인 했어요',
            style: AppTextStyles.textTheme.titleMedium
                ?.copyWith(color: AppColors.white),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
