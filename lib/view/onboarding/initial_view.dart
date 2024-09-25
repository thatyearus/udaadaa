import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/onboarding/first_view.dart';

class InitialView extends StatelessWidget {
  const InitialView({super.key});

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
              Column(
                children: [
                  Image.asset(
                    'assets/onboarding_initial.png',
                    width: double.infinity,
                  ),
                  Text(
                    "같이 다이어트하지 않을래요?\n서로 식단 응원하고 공감하면서\n같이 다이어트해요",
                    style: AppTextStyles.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const FirstView()),
                  );
                },
                child: Text(
                  '시작하기',
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
