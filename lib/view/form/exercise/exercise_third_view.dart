import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/cubit/form_cubit.dart' as form;
import 'package:udaadaa/models/calorie.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';

class ExerciseThirdView extends StatelessWidget {
  ExerciseThirdView({super.key, required this.foodContent});

  final String foodContent;
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        child: BlocConsumer<form.FormCubit, form.FormState>(
          listener: (context, state) {
            if (state is form.FormCalorie) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else if (state is form.FormError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("칼로리 측정에 실패했습니다")),
              );
            }
          },
          builder: (context, state) {
            if (state is form.FormLoading) {
              return Center(
                child: Lottie.asset('assets/loading_pink_animation.json',
                    width: 150),
              );
            }

            return SingleChildScrollView(
              reverse: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("같이하는 친구들에게\n하고 싶은 말을 적어볼까요?",
                      style: AppTextStyles.textTheme.displayMedium),
                  AppSpacing.verticalSizedBoxS,
                  Text(
                    "자유롭게 하고 싶은 말을 적어주세요! -입력 하지 않아도 괜찮아요",
                    style: AppTextStyles.bodyMedium(
                      TextStyle(color: AppColors.neutral[500]),
                    ),
                  ),
                  AppSpacing.verticalSizedBoxL,
                  foodCommentText(context),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        width: double.infinity,
        child: BlocBuilder<form.FormCubit, form.FormState>(
          builder: (context, state) {
            return FloatingActionButton.extended(
              heroTag: 'onboarding4',
              backgroundColor: (state is form.FormLoading)
                  ? AppColors.neutral[300]
                  : AppColors.primary,
              onPressed: () {
                if (state is form.FormLoading) return;
                context.read<ChatCubit>().missionComplete(
                      type: FeedType.exercise,
                      contentType: 'EXERCISE',
                      mealContent: '$foodContent 분',
                      calorie: Calorie(
                          totalCalories: int.parse(foodContent),
                          aiText: '',
                          items: []),
                      review: commentController.text,
                      exerciseTime: int.parse(foodContent),
                    );
              },
              label: Text(
                '인증하기',
                style: AppTextStyles.textTheme.titleMedium
                    ?.copyWith(color: AppColors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget foodCommentText(BuildContext context) {
    return TextField(
      controller: commentController,
      inputFormatters: [
        LengthLimitingTextInputFormatter(25),
      ],
      maxLength: 25,
      decoration: InputDecoration(
        labelText: '운동 한마디',
        hintText: '오늘 유산소 1시간 했어요!',
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
          "기록_운동한마디",
          parameters: {"사용자_입력": commentController.text},
        );
        FocusScope.of(context).unfocus();
      },
    );
  }
}
