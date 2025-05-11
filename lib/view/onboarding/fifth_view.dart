import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:udaadaa/cubit/chat_cubit.dart';
import 'package:udaadaa/cubit/form_cubit.dart' as form;
import 'package:udaadaa/models/calorie.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';

class FifthView extends StatefulWidget {
  const FifthView(
      {super.key,
      required this.foodContent,
      required this.foodComment,
      required this.calorie});

  final String foodContent, foodComment;
  final Calorie calorie;

  @override
  State<FifthView> createState() => _FifthViewState();
}

class _FifthViewState extends State<FifthView> {
  late int currentCalorie;

  @override
  void initState() {
    super.initState();
    currentCalorie = widget.calorie.totalCalories;
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('기록이 추가되었습니다')),
              );
              /*
              bool onboardingFinish =
                  PreferencesService().getBool('isOnboardingComplete') ?? false;
              logger.d("onboardingFinish: $onboardingFinish");
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) =>
                      onboardingFinish ? const MainView() : SixthView(),
                ),
                (Route<dynamic> route) => false,
              );*/
              Navigator.of(context)
                  .popUntil((route) => route.settings.name == 'ChatView');
            } else if (state is form.FormError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("기록 추가에 실패했습니다")),
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
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("AI가 측정한 칼로리 결과를\n확인해 볼까요?",
                      style: AppTextStyles.textTheme.displayMedium),
                  AppSpacing.verticalSizedBoxL,
                  _formBody(context),
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
              heroTag: 'onboarding5',
              onPressed: () {
                if (state is form.FormLoading) return;
                Analytics().logEvent(
                  "기록_칼로리결과",
                  parameters: {
                    "응원받기": "클릭",
                    "온보딩_완료_여부":
                        PreferencesService().getBool('isOnboardingComplete') ==
                                null
                            ? "false"
                            : "true",
                  },
                );
                FeedType cur = context.read<form.FormCubit>().feedType;

                // Use the updated calorie value
                final updatedCalorie =
                    widget.calorie.copyWith(totalCalories: currentCalorie);

                context.read<ChatCubit>().missionComplete(
                      type: cur,
                      contentType: 'FOOD',
                      review: widget.foodComment,
                      mealContent: widget.foodContent,
                      calorie: updatedCalorie,
                    );
                /*context.read<form.FormCubit>().submit(
                      type: cur,
                      contentType: 'FOOD',
                      review: foodComment,
                      mealContent: foodContent,
                      calorie: calorie,
                    );*/
              },
              label: Text(
                '응원받기',
                style: AppTextStyles.textTheme.titleMedium
                    ?.copyWith(color: AppColors.white),
              ),
              backgroundColor: (state is form.FormLoading)
                  ? AppColors.neutral[300]
                  : AppColors.primary,
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

  Widget _formBody(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.5),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildImageContainer(context),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildCalorieText(context, currentCalorie),
                  const SizedBox(height: 8),
                  _buildTags(context, widget.calorie.items),
                  //_buildChips(context, state.items),
                  Divider(color: AppColors.neutral[300]),
                  const SizedBox(height: 8),
                  _buildAITextContainer(context, widget.calorie.aiText),
                  const SizedBox(height: 4),
                  _buildInfoText(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer(BuildContext context) {
    final image = context.watch<form.FormCubit>().selectedImages['FOOD'];
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Image.file(File(image!.path), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildCalorieText(BuildContext context, int calorie) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '칼로리: $calorie kcal',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.black, // Use black color for text
              ),
        ),
        const SizedBox(width: 2),
        GestureDetector(
          onTap: () {
            try {
              _showCalorieEditDialog(context, calorie);
              Analytics().logEvent("칼로리_수정_시도", parameters: {
                "initial_calorie": calorie.toString(),
              });
            } catch (e) {
              debugPrint("칼로리 수정 다이얼로그 오류: $e");
            }
          },
          child: Icon(
            Icons.edit_outlined, // 겉에만 그려진 연필 아이콘
            size: 22,
            color: AppColors.primary, // Primary color for the icon
          ),
        ),
      ],
    );
  }

  void _showCalorieEditDialog(BuildContext context, int initialCalorie) {
    final TextEditingController controller =
        TextEditingController(text: initialCalorie.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('칼로리 수정'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '칼로리',
              suffixText: 'kcal',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '취소',
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final newCalorie = int.tryParse(controller.text);
                if (newCalorie != null && newCalorie >= 0) {
                  setState(() {
                    currentCalorie = newCalorie;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('유효한 칼로리를 입력해주세요')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '저장',
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTags(BuildContext context, List<String> tags) {
    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.start,
      spacing: 12,
      runSpacing: 4,
      children: tags.map((tag) {
        return Text(
          '# $tag ',
          style: AppTextStyles.headlineSmall(
              TextStyle(color: AppColors.neutral[500])),
        );
      }).toList(),
    );
  }

  Widget _buildAITextContainer(BuildContext context, String aiText) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        aiText,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildInfoText(BuildContext context) {
    return Text(
      "AI가 대한민국 여성 평균 1인분을 기준으로 측정해 주고 있어요.\n음식 내용을 자세히 적고 알고 있는 칼로리를 함께 적어주면 더 정확한 칼로리를 얻을 수 있어요!",
      style:
          Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
    );
  }
}
