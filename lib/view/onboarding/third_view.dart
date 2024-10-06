import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/onboarding/fourth_view.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';

class ThirdView extends StatelessWidget {
  ThirdView({super.key});

  final TextEditingController foodContentController = TextEditingController();

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
              Text("어떤 음식을 먹었나요?",
                  style: AppTextStyles.textTheme.displayMedium),
              AppSpacing.verticalSizedBoxS,
              Text(
                "음식 내용을 자세히 입력해 주면, AI 칼로리 정확도가 올라가요",
                style: AppTextStyles.bodyMedium(
                  TextStyle(color: AppColors.neutral[500]),
                ),
              ),
              AppSpacing.verticalSizedBoxL,
              foodContentText(context),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        width: double.infinity,
        child: FloatingActionButton.extended(
          heroTag: 'onboarding3',
          onPressed: () {
            Analytics().logEvent(
              "온보딩_음식내용",
              parameters: {"다음": "클릭"},
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FourthView(
                  foodContent: foodContentController.text,
                ),
              ),
            );
          },
          label: Text(
            '다음',
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

  Widget foodContentText(BuildContext context) {
    return TextField(
      controller: foodContentController,
      decoration: InputDecoration(
        labelText: '음식 내용',
        hintText: '그릭요거트(110kcal), 복숭아 1개',
        hintStyle:
            AppTextStyles.bodyMedium(TextStyle(color: AppColors.neutral[500])),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.neutral[300]!),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      onEditingComplete: () {
        Analytics().logEvent(
          "온보딩_음식내용",
          parameters: {"사용자_입력": foodContentController.text},
        );
        FocusScope.of(context).unfocus();
      },
    );
  }
}
