import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/form_cubit.dart' as form;
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/onboarding/second_view.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';

class FirstView extends StatelessWidget {
  const FirstView({super.key});

  @override
  Widget build(BuildContext context) {
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
              Text("올릴 식단을\n선택해 볼까요?",
                  style: AppTextStyles.textTheme.displayMedium),
              AppSpacing.verticalSizedBoxL,
              const MealToggleButtons(),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        width: double.infinity,
        child: FloatingActionButton.extended(
          heroTag: 'onboarding1',
          onPressed: () {
            Analytics().logEvent(
              "기록_식단종류",
              parameters: {
                "다음": "클릭",
                "온보딩_완료_여부":
                    PreferencesService().getBool('isOnboardingComplete') == null
                        ? "false"
                        : "true",
              },
            );
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SecondView()),
            );
          },
          label: Text(
            '다음',
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
    final List<String> foodType = ['아침', '점심', '저녁', '간식'];
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
              Analytics().logEvent(
                "기록_식단종류",
                parameters: {"식단종류": foodType[index]},
              );
              context.read<form.FormCubit>().updateMealSelection(index);
            },
          );
        },
      ),
    );
  }
}
