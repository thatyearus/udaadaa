import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:udaadaa/cubit/form_cubit.dart' as form;
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';

class FoodFormView extends StatelessWidget {
  FoodFormView({super.key});

  final TextEditingController commentController = TextEditingController();
  final TextEditingController foodContentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: AppColors.white,
      ),
      body: BlocListener<form.FormCubit, form.FormState>(
        listener: (context, state) {
          if (state is form.FormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('기록이 추가되었습니다')),
            );
            Navigator.pop(context);
          } else if (state is form.FormError) {
            // 오류가 발생하면 에러 메시지 표시
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: SingleChildScrollView(
          reverse: true,
          padding: AppSpacing.edgeInsetsL,
          child: Column(
            children: [
              const MealToggleButtons(),
              AppSpacing.verticalSizedBoxM,
              imagePickerWidget(context),
              AppSpacing.verticalSizedBoxM,
              // 먹은 음식 내용
              TextField(
                controller: foodContentController,
                decoration: InputDecoration(
                  labelText: '음식 내용',
                  hintText: '연어 포케',
                  hintStyle: AppTextStyles.bodyMedium(
                      TextStyle(color: AppColors.neutral[500])),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onEditingComplete: () {
                  Analytics().logEvent(
                    "업로드_음식내용",
                    parameters: {"사용자_입력": foodContentController.text},
                  );
                  FocusScope.of(context).unfocus();
                },
              ),
              AppSpacing.verticalSizedBoxM,
              // 한 줄 평 (공통)
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: '음식 한마디',
                  hintText: '오늘 치팅데이니까 혼내지 말아 주세요ㅠ',
                  hintStyle: AppTextStyles.bodyMedium(
                      TextStyle(color: AppColors.neutral[500])),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onEditingComplete: () {
                  Analytics().logEvent(
                    "업로드_음식한마디",
                    parameters: {"사용자_입력": foodContentController.text},
                  );
                  FocusScope.of(context).unfocus();
                },
              ),
              AppSpacing.verticalSizedBoxL,
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Analytics().logEvent(
                    "업로드_기록추가",
                  );
                  FeedType cur = context.read<form.FormCubit>().feedType;
                  context.read<form.FormCubit>().submit(
                        type: cur,
                        contentType: 'FOOD',
                        review: commentController.text,
                        mealContent: foodContentController.text,
                      );
                  commentController.clear();
                  foodContentController.clear();
                },
                child: Text(
                  '기록 추가',
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
    final image = context.watch<form.FormCubit>().selectedImages['FOOD'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.35,
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
            context
                .read<form.FormCubit>()
                .updateImage('FOOD', ImageSource.gallery);
            Analytics().logEvent(
              "업로드_이미지업로드",
            );
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

class MealToggleButtons extends StatelessWidget {
  const MealToggleButtons({super.key});

  Widget button(String text, bool isSelected, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: isSelected ? Theme.of(context).primaryColor : Colors.white,
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                ),
              ]
            : null,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isSelected ? Colors.white : Colors.black45,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selection = context.select<form.FormCubit, List<bool>>(
      (cubit) => cubit.mealSelection,
    );
    final List<String> type = ['아침', '점심', '저녁', '간식'];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonWidth = constraints.maxWidth / 4;
          return ToggleButtons(
            renderBorder: false,
            isSelected: selection,
            borderRadius: BorderRadius.circular(5),
            fillColor: Colors.white,
            constraints: BoxConstraints.tightFor(width: buttonWidth),
            children: <Widget>[
              button('아침', selection[0], context),
              button('점심', selection[1], context),
              button('저녁', selection[2], context),
              button('간식', selection[3], context),
            ],
            onPressed: (int index) {
              context.read<form.FormCubit>().updateMealSelection(index);
              Analytics().logEvent(
                "업로드_식단종류",
                parameters: {"식단종류": type[index]},
              );
            },
          );
        },
      ),
    );
  }
}
