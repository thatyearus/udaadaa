import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/onboarding/fourth_view.dart';

class ThirdView extends StatelessWidget {
  ThirdView({super.key});

  final TextEditingController foodContentController = TextEditingController();

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
              Text("어떤 음식을 먹었나요?",
                  style: AppTextStyles.textTheme.displayMedium),
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
        hintText: '연어 포케',
        hintStyle:
            AppTextStyles.bodyMedium(TextStyle(color: AppColors.neutral[500])),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
