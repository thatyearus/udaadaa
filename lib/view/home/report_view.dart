import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/models/report.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/calendar.dart';
import 'package:udaadaa/widgets/card_view.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    Report? report = context.watch<ProfileCubit>().getSelectedReport;
    final nickname = context.watch<AuthCubit>().getProfile?.nickname ?? "사용자";

    final totalCalorie = (report != null
        ? ((report.breakfast ?? 0) +
            (report.lunch ?? 0) +
            (report.dinner ?? 0) +
            (report.snack ?? 0))
        : 0);
    return Scaffold(
      appBar: AppBar(
        title: Text("$nickname 님의 리포트",
            style: AppTextStyles.textTheme.headlineMedium),
        centerTitle: true,
      ),
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
                const Calendar(),
                AppSpacing.verticalSizedBoxXs,
                const DayBanner(),
                /* Text("$nickname 님의 리포트",
                    style: AppTextStyles.textTheme.displaySmall),*/
                AppSpacing.verticalSizedBoxXxl,
                const SelectToggleButtons(),
                AppSpacing.verticalSizedBoxL,
                Row(
                  children: [
                    DayMiniReport(
                      title: "총칼로리",
                      content: '$totalCalorie',
                      unit: "kcal",
                    ),
                  ],
                ),
                AppSpacing.verticalSizedBoxL,
                Row(
                  children: [
                    DayMiniReport(
                        title: '아침',
                        content: '${report?.breakfast ?? 0}',
                        unit: 'kcal'),
                    AppSpacing.horizontalSizedBoxXs,
                    DayMiniReport(
                        title: '점심',
                        content: '${report?.lunch ?? 0}',
                        unit: 'kcal'),
                  ],
                ),
                AppSpacing.verticalSizedBoxXs,
                Row(
                  children: [
                    DayMiniReport(
                        title: '저녁',
                        content: '${report?.dinner ?? 0}',
                        unit: 'kcal'),
                    AppSpacing.horizontalSizedBoxXs,
                    DayMiniReport(
                        title: '간식',
                        content: '${report?.snack ?? 0}',
                        unit: 'kcal'),
                  ],
                ),
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
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
            ],
            onPressed: (int index) {
              Analytics().logEvent(
                "리포트_종류선택",
                parameters: {"종류": type[index]},
              );
              context.read<ProfileCubit>().updateTypeSelection(index);
            },
          );
        },
      ),
    );
  }
}

class DayMiniReport extends StatelessWidget {
  final String title;
  final String content;
  final String unit;

  const DayMiniReport({
    super.key,
    required this.title,
    required this.content,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return CardView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.textTheme.headlineMedium),
          AppSpacing.verticalSizedBoxXxs,
          Text("$content $unit", style: AppTextStyles.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
