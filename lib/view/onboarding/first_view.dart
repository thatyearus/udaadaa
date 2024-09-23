import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/form_cubit.dart' as form;
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/onboarding/third_view.dart';

class FirstView extends StatelessWidget {
  const FirstView({super.key});

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
              Text("피드에 업로드할\n사진을 올려주세요",
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
                    MaterialPageRoute(builder: (context) => ThirdView()),
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
