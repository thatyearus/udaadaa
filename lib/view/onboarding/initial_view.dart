import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/onboarding/first_view.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';

class InitialView extends StatefulWidget {
  const InitialView({super.key});

  @override
  InitialViewState createState() => InitialViewState();
}

class InitialViewState extends State<InitialView> {
  final PageController _pageController = PageController();
  int _index = 0;

  final List<Map<String, dynamic>> onboardingPages = [
    {
      "image": "assets/onboarding_initial.png",
      "description": Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "우다다",
              style: AppTextStyles.headlineLarge(
                const TextStyle(color: AppColors.primary),
              ),
            ),
            const TextSpan(
              text:
                  "에서 다이어트 챌린지 해보세요\n내 식단을 올리면 친구들이 응원해주고\nAI가 자동으로 식단 칼로리도 측정해요",
            ),
          ],
        ),
        style: AppTextStyles.textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    },
    {
      "image": "assets/onboarding_fact.png",
      "description": Text.rich(
        TextSpan(children: [
          const TextSpan(text: "논문으로 밝혀진\n"),
          TextSpan(
            text: "같이",
            style: AppTextStyles.headlineLarge(
              const TextStyle(color: AppColors.primary),
            ),
          ),
          const TextSpan(text: "하는 다이어트 효과\n"),
        ]),
        style: AppTextStyles.textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    },
    {
      "image": "assets/onboarding_review.png",
      "description": Text(
        "",
        style: AppTextStyles.textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    },
  ];

  void _onPageChanged(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: AppSpacing.edgeInsetsL,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("우다다", style: AppTextStyles.textTheme.displayLarge),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: onboardingPages.length,
                  itemBuilder: (context, index) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          (index == 2
                              ? AppSpacing.verticalSizedBoxXxl
                              : Container()),
                          Image.asset(
                            onboardingPages[index]["image"]!,
                            width: double.infinity,
                            fit: BoxFit.scaleDown,
                          ),
                          AppSpacing.verticalSizedBoxL,
                          onboardingPages[index]["description"]!,
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     for (int i = 0; i < onboardingPages.length; i++)
              //       Container(
              //         margin: const EdgeInsets.symmetric(horizontal: 4),
              //         width: 8,
              //         height: 8,
              //         decoration: BoxDecoration(
              //           shape: BoxShape.circle,
              //           color: i == _index
              //               ? Theme.of(context).primaryColor
              //               : AppColors.neutral[300],
              //         ),
              //       ),
              //   ],
              // ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Analytics().logEvent("온보딩_시작하기", parameters: {"페이지": _index});
                  if (_index == 2) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const FirstView()),
                    );
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                child: Text(
                  _index == onboardingPages.length - 1 ? '시작하기' : '다음',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
