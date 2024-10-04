import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/form_cubit.dart' as form;
import 'package:udaadaa/models/feed.dart';
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/view/main_view.dart';
import 'package:udaadaa/view/onboarding/sixth_view.dart';

class FifthView extends StatelessWidget {
  const FifthView(
      {super.key, required this.foodContent, required this.foodComment});

  final String foodContent, foodComment;

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
}
