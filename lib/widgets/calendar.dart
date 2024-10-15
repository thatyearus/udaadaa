import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/constant.dart';

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime? selectedDate = context
        .select<ProfileCubit, DateTime?>((cubit) => cubit.getSelectedDate);
    DateTime focusedDate =
        context.select<ProfileCubit, DateTime>((cubit) => cubit.getFocusDate);

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
          context.read<ProfileCubit>().selectFocusDate(focusedDay),
      onDaySelected: (DateTime selectedDay, DateTime focusDay) {
        context.read<ProfileCubit>().selectDay(selectedDay);
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
