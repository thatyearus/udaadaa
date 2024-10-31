import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/form_cubit.dart' as form;
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/form/weight/weight_second_view.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';

class WeightFirstView extends StatelessWidget {
  const WeightFirstView({super.key});

  @override
  Widget build(BuildContext context) {
    final imageSelected = context.select<form.FormCubit, bool>(
      (cubit) => cubit.selectedImages['WEIGHT'] != null,
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
              Text("오늘의 몸무게 사진을\n올려볼까요?",
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
          heroTag: 'weight1',
          onPressed: () {
            if (imageSelected) {
              Analytics().logEvent(
                "기록_몸무게업로드",
                parameters: {
                  "다음": "사진 업로드 완료",
                },
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WeightSecondView(),
                ),
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
    final image = context.watch<form.FormCubit>().selectedImages['WEIGHT'];
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
              "기록_몸무게업로드",
              parameters: {"업로드버튼": "클릭"},
            );
            context.read<form.FormCubit>().updateImage('WEIGHT');
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
