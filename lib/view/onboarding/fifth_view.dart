import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/form_cubit.dart' as form;
import 'package:udaadaa/models/calorie.dart';
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/view/main_view.dart';
import 'package:udaadaa/view/onboarding/sixth_view.dart';

class FifthView extends StatelessWidget {
  const FifthView(
      {super.key,
      required this.foodContent,
      required this.foodComment,
      required this.calorie});

  final String foodContent, foodComment;
  final Calorie calorie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        minimum: AppSpacing.edgeInsetsL,
        child: BlocListener<form.FormCubit, form.FormState>(
          listener: (context, state) {
            if (state is form.FormSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('기록이 추가되었습니다')),
              );
              bool onboardingFinish =
                  PreferencesService().getBool('isOnboardingComplete') ?? false;
              logger.d("onboardingFinish: $onboardingFinish");
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) =>
                      onboardingFinish ? const MainView() : SixthView(),
                ),
                (Route<dynamic> route) => false,
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
                _formBody(context),
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
              parameters: {"올려서_공감받기": "클릭"},
            );
            FeedType cur = context.read<form.FormCubit>().feedType;
            context.read<form.FormCubit>().submit(
                  type: cur,
                  contentType: 'FOOD',
                  review: foodComment,
                  mealContent: foodContent,
                  calorie: calorie,
                );
          },
          label: Text(
            '올려서 공감받기',
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

  Widget _formBody(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
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
                  _buildCalorieText(context, calorie.totalCalories),
                  const SizedBox(height: 8),
                  _buildTags(context, calorie.items),
                  //_buildChips(context, state.items),
                  Divider(color: AppColors.neutral[300]),
                  const SizedBox(height: 8),
                  _buildAITextContainer(context, calorie.aiText),
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
    return Text(
      '칼로리: $calorie kcal',
      style: Theme.of(context).textTheme.headlineLarge,
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
    return Row(
      children: [
        Text(
          "칼로리는 여성 1인분 기준으로 측정하였습니다.",
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
