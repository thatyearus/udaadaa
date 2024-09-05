import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/form_cubit.dart';
import 'package:udaadaa/utils/constant.dart';

class FoodRecordView extends StatelessWidget {
  FoodRecordView({super.key});

  final TextEditingController commentController = TextEditingController();
  final TextEditingController foodContentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          imagePickerWidget(context),

          AppSpacing.verticalSizedBoxM,
          // 먹은 음식 내용
          TextField(
            controller: foodContentController,
            decoration: const InputDecoration(labelText: '음식 내용'),
          ),
          AppSpacing.verticalSizedBoxM,
          // 한 줄 평 (공통)
          TextField(
            controller: commentController,
            decoration: const InputDecoration(labelText: '음식 한마디'),
          ),

          AppSpacing.verticalSizedBoxL,
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
              context.read<FormCubit>().submit(
                    type: 'FOOD',
                    review: commentController.text,
                    mealContent: foodContentController.text,
                  );
            },
            child: Text(
              '기록 추가',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget imagePickerWidget(BuildContext context) {
    final image = context.watch<FormCubit>().selectedImages['FOOD'];
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
            context.read<FormCubit>().updateImage('FOOD');
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
