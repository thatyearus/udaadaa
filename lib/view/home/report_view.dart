import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/calendar.dart';
import 'package:udaadaa/widgets/daily_report.dart';
import 'package:udaadaa/widgets/weekly_report.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final selection = context.select<ProfileCubit, List<bool>>(
      (cubit) => cubit.getSelectedType,
    );
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          return context.read<ProfileCubit>().getMyTodayReport();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                AppSpacing.verticalSizedBoxL,
                const Calendar(),
                AppSpacing.verticalSizedBoxXl,
                const SelectToggleButtons(),
                AppSpacing.verticalSizedBoxL,
                (selection[0] ? const DailyReport() : const WeeklyReport()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SelectToggleButtons extends StatelessWidget {
  const SelectToggleButtons({super.key});

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
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSelected ? Colors.white : Colors.black45,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selection = context.select<ProfileCubit, List<bool>>(
      (cubit) => cubit.getSelectedType,
    );
    final List<String> type = ['일일 리포트', '주간 리포트'];
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
          final buttonWidth = constraints.maxWidth / 2;
          return ToggleButtons(
            renderBorder: false,
            isSelected: selection,
            borderRadius: BorderRadius.circular(5),
            fillColor: Colors.white,
            constraints: BoxConstraints.tightFor(width: buttonWidth),
            children: <Widget>[
              button('일일 리포트', selection[0], context),
              button('주간 리포트', selection[1], context),
              // button("체중 변화", selection[2], context),
            ],
            onPressed: (int index) {
              Analytics().logEvent(
                "리포트_종류선택",
                parameters: {
                  "종류": type[index],
                  "챌린지상태": context.read<AuthCubit>().getChallengeStatus(),
                },
              );
              context.read<ProfileCubit>().updateTypeSelection(index);
            },
          );
        },
      ),
    );
  }
}
