import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/form_cubit.dart' as form;
import 'package:udaadaa/utils/constant.dart';

class WeightFormView extends StatelessWidget {
  WeightFormView({super.key});

  final TextEditingController commentController = TextEditingController();
  final TextEditingController weightContentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
        child: Column(
          children: [
            imagePickerWidget(context),
            AppSpacing.verticalSizedBoxM,
            // 먹은 음식 내용
            TextField(
              controller: weightContentController,
              decoration: const InputDecoration(labelText: '몸무게'),
            ),
            AppSpacing.verticalSizedBoxM,
            // 한 줄 평 (공통)
            TextField(
              controller: commentController,
              decoration: const InputDecoration(labelText: '몸무게 한마디'),
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
                context.read<form.FormCubit>().submit(
                      type: 'WEIGHT',
                      review: commentController.text,
                      weight: weightContentController.text,
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
      ),
    );
  }

  Widget imagePickerWidget(BuildContext context) {
    final image = context.watch<form.FormCubit>().selectedImages['WEIGHT'];
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
