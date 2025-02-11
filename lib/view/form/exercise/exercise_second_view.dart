import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/cubit/form_cubit.dart' as form;
import 'package:udaadaa/models/calorie.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/form/exercise/exercise_third_view.dart';
import 'package:udaadaa/view/main_view.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';

class ExerciseSecondView extends StatefulWidget {
  const ExerciseSecondView({super.key});

  @override
  State<ExerciseSecondView> createState() => _ExerciseSecondViewState();
}

class _ExerciseSecondViewState extends State<ExerciseSecondView> {
  final TextEditingController commentController = TextEditingController();
  bool isCommentEmpty = true;

  @override
  void initState() {
    super.initState();
    commentController.addListener(() {
      setState(() {
        isCommentEmpty = commentController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        child: BlocConsumer<form.FormCubit, form.FormState>(
          listener: (context, state) {
            if (state is form.FormSuccess) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MainView(),
                ),
                (Route<dynamic> route) => false,
              );
            } else if (state is form.FormError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("운동 인증에 실패했습니다")),
              );
            }
          },
          builder: (context, state) {
            if (state is form.FormLoading) {
              return Center(
                child:
                    Lottie.asset('assets/loading_animation.json', width: 150),
              );
            }

            return SingleChildScrollView(
              reverse: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("오늘의 운동\n몇 분했는지 적어볼까요?",
                      style: AppTextStyles.textTheme.displayMedium),
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
              heroTag: 'exercise2',
              backgroundColor: (state is form.FormLoading || isCommentEmpty)
                  ? AppColors.neutral[300]
                  : AppColors.primary,
              onPressed: () {
                if (state is form.FormLoading || isCommentEmpty) {
                  return;
                }
                Analytics().logEvent(
                  "기록_운동기록",
                  parameters: {
                    "인증하기": "클릭",
                  },
                );
                /*context.read<form.FormCubit>().submitWeight(
                    weight: commentController.text, contentType: "WEIGHT");*/
                /*context.read<ChatCubit>().missionComplete(
                      type: FeedType.exercise,
                      contentType: 'EXERCISE',
                      mealContent: '${commentController.text} 분',
                      calorie: Calorie(
                          totalCalories: int.parse(commentController.text),
                          aiText: '',
                          items: []),
                      review: commentController.text,
                      exerciseTime: int.parse(commentController.text),
                    );*/
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExerciseThirdView(
                      foodContent: commentController.text,
                    ),
                  ),
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
      ],
      decoration: InputDecoration(
        labelText: '운동 시간(분)',
        hintText: '55',
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
          "기록_체중기록",
          parameters: {"사용자_입력": commentController.text},
        );
        FocusScope.of(context).unfocus();
      },
    );
  }
}
