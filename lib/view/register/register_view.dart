import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/bottom_nav_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/register/login_view.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            context.read<BottomNavCubit>().selectTab(BottomNavState.home);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 섹션
              Text(
                "다이어트 챌린지\n함께 해볼까요?",
                style: AppTextStyles.textTheme.displayMedium,
              ),
              Center(
                child: Image.asset(
                  'assets/apply_trophy.png',
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
              AppSpacing.verticalSizedBoxL,
              // 혜택 리스트
              const ChallengeFeatureList(),

              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginView(),
                    ),
                  );
                },
                child: Text(
                  "코드 입력하기",
                  style: AppTextStyles.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              AppSpacing.verticalSizedBoxS,
              GestureDetector(
                onTap: () async {
                  const url =
                      'https://slashpage.com/dietchallenge'; // 랜딩페이지 링크 갱신되면 변경 필요.
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Center(
                  child: Text(
                    "코드가 없으신가요?",
                    style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                      color: AppColors.grayscale[500],
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.grayscale[500],
                    ),
                  ),
                ),
              ),
              AppSpacing.verticalSizedBoxL,
            ],
          ),
        ),
      ),
    );
  }
}

class ChallengeFeatureList extends StatelessWidget {
  const ChallengeFeatureList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureItem(
          "미션 성공 시 100% 환급",
          Icons.monetization_on_rounded,
        ),
        _buildFeatureItem(
          "AI를 이용한 칼로리 측정",
          Icons.smart_toy_rounded,
        ),
        _buildFeatureItem(
          "다이어트 식단 레시피",
          Icons.restaurant_menu_rounded,
        ),
        _buildFeatureItem(
          "몸무게, 칼로리 주간 리포트 제공",
          Icons.show_chart_rounded,
        ),
        _buildFeatureItem(
          "2주 동안 함께하는 다이어트",
          Icons.people_rounded,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Padding(
      padding: AppSpacing.edgeInsetsXs,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          AppSpacing.horizontalSizedBoxS,
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
