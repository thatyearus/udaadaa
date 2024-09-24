import 'package:flutter/material.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/onboarding/fifth_view.dart';

class FourthView extends StatelessWidget {
  FourthView({super.key, required this.foodContent});

  final String foodContent;
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
              Text("같이하는 친구들에게\n하고 싶은 말을 적어볼까요?",
                  style: AppTextStyles.textTheme.displayMedium),
              AppSpacing.verticalSizedBoxL,
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.55,
                child: foodCommentText(context),
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
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => FifthView()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text(
                  '올려서 공감받기',
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

  Widget foodCommentText(BuildContext context) {
    return TextField(
      controller: commentController,
      decoration: InputDecoration(
        labelText: '음식 한마디',
        hintText: '오늘 치팅데이니까 혼내지 말아 주세요ㅠ',
        hintStyle:
            AppTextStyles.bodyMedium(TextStyle(color: AppColors.neutral[500])),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
