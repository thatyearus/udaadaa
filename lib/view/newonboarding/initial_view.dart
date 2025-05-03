import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/newonboarding/first_view.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';

class InitialView extends StatelessWidget {
  const InitialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("2주 동안 챌린지를 통해\n함께 다이어트해요",
                    style: AppTextStyles.textTheme.displayMedium),
                const SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    'assets/mission.png',
                    height: 240,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),
                const ChallengeDetailsList(),
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Analytics().logEvent(
                        "온보딩_첫번째_뷰",
                        parameters: {"버튼": "클릭"},
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const FirstView()),
                      );
                    },
                    child: Text(
                      "시작하기",
                      style: AppTextStyles.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChallengeDetailsList extends StatelessWidget {
  const ChallengeDetailsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "챌린지는 2개의 미션이 있어요",
          style: AppTextStyles.textTheme.headlineMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            children: [
              _buildFeatureItem(
                "식단 2번 인증",
                Icons.restaurant_rounded,
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                "몸무게 인증",
                Icons.monitor_weight_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        AppSpacing.horizontalSizedBoxM,
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
