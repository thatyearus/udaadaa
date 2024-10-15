import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/models/report.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/widgets/card_view.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    Report? report = context.watch<ProfileCubit>().getSelectedReport;
    final nickname = context.watch<AuthCubit>().getProfile?.nickname ?? "사용자";
    DateTime? selectedDate = context
        .select<ProfileCubit, DateTime?>((cubit) => cubit.getSelectedDate);

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
                TableCalendar(
                  locale: 'ko_KR',
                  focusedDay: DateTime.now(),
                  firstDay: DateTime(1800),
                  lastDay: DateTime(2050),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: AppTextStyles.textTheme.headlineMedium!,
                  ),
                  calendarFormat: CalendarFormat.week,
                  calendarStyle: CalendarStyle(
                    isTodayHighlighted: true,
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary[200],
                      shape: BoxShape.circle,
                    ),
                  ),
                  onDaySelected: (DateTime selectedDay, DateTime focusDay) {
                    context.read<ProfileCubit>().selectDay(selectedDay);
                  },
                  selectedDayPredicate: (day) {
                    if (selectedDate == null) {
                      return false;
                    }
                    return day.isAtSameMomentAs(selectedDate);
                  },
                ),
                /* Text("$nickname 님의 리포트",
                    style: AppTextStyles.textTheme.displaySmall),*/
                AppSpacing.verticalSizedBoxL,
                Row(
                  children: [
                    CardView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("총칼로리",
                              style: AppTextStyles.textTheme.headlineMedium),
                          Text("$totalCalorie kcal",
                              style: AppTextStyles.textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalSizedBoxL,
                Row(
                  children: [
                    CardView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("아침",
                                style: AppTextStyles.textTheme.headlineMedium),
                            AppSpacing.verticalSizedBoxXxs,
                            Text("${report?.breakfast ?? 0} kcal",
                                style: AppTextStyles.textTheme.bodyLarge),
                          ]),
                    ),
                    AppSpacing.horizontalSizedBoxXs,
                    CardView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("점심",
                                style: AppTextStyles.textTheme.headlineMedium),
                            AppSpacing.verticalSizedBoxXxs,
                            Text("${report?.lunch ?? 0} kcal",
                                style: AppTextStyles.textTheme.bodyLarge),
                          ]),
                    ),
                  ],
                ),
                AppSpacing.verticalSizedBoxXs,
                Row(
                  children: [
                    CardView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("저녁",
                                style: AppTextStyles.textTheme.headlineMedium),
                            AppSpacing.verticalSizedBoxXxs,
                            Text("${report?.dinner ?? 0} kcal",
                                style: AppTextStyles.textTheme.bodyLarge),
                          ]),
                    ),
                    AppSpacing.horizontalSizedBoxXs,
                    CardView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("간식",
                                style: AppTextStyles.textTheme.headlineMedium),
                            AppSpacing.verticalSizedBoxXxs,
                            Text("${report?.snack ?? 0} kcal",
                                style: AppTextStyles.textTheme.bodyLarge),
                          ]),
                    ),
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
