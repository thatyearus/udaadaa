import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';

class ChallengerView extends StatelessWidget {
  const ChallengerView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Calendar(),
    );
  }
}

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime? selectedDate = context
        .select<ChallengeCubit, DateTime?>((cubit) => cubit.getSelectedDate);
    DateTime focusedDate =
        context.select<ChallengeCubit, DateTime>((cubit) => cubit.getFocusDate);

    return TableCalendar(
      locale: 'ko_KR',
      focusedDay: focusedDate,
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
      onPageChanged: (focusedDay) =>
          context.read<ChallengeCubit>().selectFocusDate(focusedDay),
      onDaySelected: (DateTime selectedDay, DateTime focusDay) {
        Analytics()
            .logEvent("리포트_날짜선택", parameters: {"날짜": selectedDay.toString()});
        context.read<ChallengeCubit>().selectDay(selectedDay);
      },
      selectedDayPredicate: (day) {
        if (selectedDate == null) {
          return false;
        }
        return isSameDay(selectedDate, day);
      },
    );
  }
}

class DayBanner extends StatelessWidget {
  const DayBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDate = context
        .select<ChallengeCubit, DateTime?>((cubit) => cubit.getSelectedDate);
    return Column(
      children: [
        const Divider(
          color: AppColors.primary,
          thickness: 1,
        ),
        Text(
          selectedDate != null
              ? "${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일"
              : "날짜를 선택해주세요",
          style: AppTextStyles.textTheme.bodyLarge,
        ),
        const Divider(
          color: AppColors.primary,
          thickness: 1,
        ),
      ],
    );
  }
}
