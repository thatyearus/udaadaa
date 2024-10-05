import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/form_cubit.dart' as form;
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/onboarding/fifth_view.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';

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
        child: BlocListener<form.FormCubit, form.FormState>(
          listener: (context, state) {
            if (state is form.FormCalorie) {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => FifthView(
                          foodContent: foodContent,
                          foodComment: commentController.text,
                          calorie: state.calorie,
                        )),
              );
            } else if (state is form.FormError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("같이하는 친구들에게\n하고 싶은 말을 적어볼까요?",
                    style: AppTextStyles.textTheme.displayMedium),
                AppSpacing.verticalSizedBoxL,
                foodCommentText(context),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        width: double.infinity,
        child: FloatingActionButton.extended(
          heroTag: 'onboarding4',
          onPressed: () {
            Analytics().logEvent(
              "온보딩_음식한마디",
              parameters: {"다음": "클릭"},
            );
            context.read<form.FormCubit>().calculate(foodContent);
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
      onEditingComplete: () {
        Analytics().logEvent(
          "온보딩_음식한마디",
          parameters: {"사용자_입력": commentController.text},
        );
        FocusScope.of(context).unfocus();
      },
    );
  }
}
