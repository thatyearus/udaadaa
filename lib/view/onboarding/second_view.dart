import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/form_cubit.dart' as form;
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/onboarding/third_view.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';

class SecondView extends StatelessWidget {
  const SecondView({super.key});

  @override
  Widget build(BuildContext context) {
    final foodTypeString = {
      FeedType.breakfast: '아침',
      FeedType.lunch: '점심',
      FeedType.dinner: '저녁',
      FeedType.snack: '간식',
    };
    final foodType = context.select<form.FormCubit, String>(
      (cubit) => foodTypeString[cubit.feedType]!,
    );
    final imageSelected = context.select<form.FormCubit, bool>(
      (cubit) => cubit.selectedImages['FOOD'] != null,
    );
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
              Text("오늘 먹은 $foodType\n올려볼까요?",
                  style: AppTextStyles.textTheme.displayMedium),
              AppSpacing.verticalSizedBoxL,
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.55,
                child: imagePickerWidget(context),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        width: double.infinity,
        child: FloatingActionButton.extended(
          heroTag: 'onboarding2',
          onPressed: () {
            if (imageSelected) {
              Analytics().logEvent(
                "기록_식단업로드",
                parameters: {
                  "다음": "사진 업로드 완료",
                  "온보딩_완료_여부":
                      PreferencesService().getBool('isOnboardingComplete') ==
                              null
                          ? "false"
                          : "true",
                },
              );
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ThirdView()),
              );
            }
          },
          label: Text(
            '다음',
            style: AppTextStyles.textTheme.titleMedium
                ?.copyWith(color: AppColors.white),
          ),
          backgroundColor: imageSelected
              ? Theme.of(context).primaryColor
              : AppColors.neutral[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget imagePickerWidget(BuildContext context) {
    final image = context.watch<form.FormCubit>().selectedImages['FOOD'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.45,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(File(image.path), fit: BoxFit.cover),
                )
              : Center(
                  child: Text(
                    "이미지를 업로드해주세요",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black45,
                        ),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () {
            Analytics().logEvent(
              "기록_식단업로드",
              parameters: {"업로드버튼": "클릭"},
            );
            context.read<form.FormCubit>().updateImage('FOOD');
          },
          child: Text(
            image != null ? '이미지 변경' : '이미지 업로드',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
      ],
    );
  }
}
