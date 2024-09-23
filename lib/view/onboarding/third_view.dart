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
              Text("음식에 대한\n설명을 작성해주세요",
                  style: AppTextStyles.textTheme.displayMedium),
              AppSpacing.verticalSizedBoxL,
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.55,
                child: imagePickerWidget(context),
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => FourthView(
                              foodContent: foodContentController.text,
                            )),
                  );
                },
                child: Text(
                  '다음',
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

  Widget imagePickerWidget(BuildContext context) {
    return TextField(
      controller: foodContentController,
      decoration: const InputDecoration(labelText: '음식 내용', hintText: '연어 포케'),
    );
  }
}
