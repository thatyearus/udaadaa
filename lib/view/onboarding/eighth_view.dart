import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/onboarding/ninth_view.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/view/main_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart' as challenge;

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
              AppSpacing.sizedBoxXl,
              Center( // 중앙 정렬을 위해 Center 위젯으로 감싸기
                child: Column(
                  children: [
                    Image.asset(
                        "assets/onboarding_lose.png",
                      width: 300,
                    ),
                    Text.rich(
                      TextSpan(children: [
                        const TextSpan(text: "챌린지 참여자\n"),
                        TextSpan(
                          text: "평균 2.7kg\n",
                          style: AppTextStyles.titleLarge(
                            const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,),
                          ),
                        ),
                        const TextSpan(text: "감량 성공\n"),
                      ]),
                      style: AppTextStyles.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
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
                context.read<challenge.ChallengeCubit>().enterChallenge();
                Analytics().logEvent(
                  "온보딩_챌린지참여",
                  parameters: {"버튼": "클릭"},
                );
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
          const SizedBox(height: 10), // 간격 추가
          GestureDetector(
            onTap: () {
              Analytics().logEvent(
                "온보딩_챌린지_미참여",
                parameters: {"다음에_할래요": "클릭"},
              );
              PreferencesService().setBool('isOnboardingComplete', true);
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                  const MainView(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0); // 아래에서 위로
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Text(
              '다음에 할래요',
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 20), // 아래 여백 추가
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
