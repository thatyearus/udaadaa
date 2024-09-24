import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/onboarding/sixth_view.dart';

class FifthView extends StatelessWidget {
  FifthView({super.key});

  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        minimum: AppSpacing.edgeInsetsL,
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("이제 같이하는 친구들 식단을\n응원해 볼까요?",
                  style: AppTextStyles.textTheme.displayMedium),
              AppSpacing.verticalSizedBoxL,
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.55,
                child: const Placeholder(),
              ),
              AppSpacing.verticalSizedBoxXxl,
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
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const SixthView()),
                  );
                },
                child: Text(
                  '응원하러 가기',
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
