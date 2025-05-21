import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  bool _isCalendarExpanded = false;

  void _toggleCalendar() {
    setState(() {
      _isCalendarExpanded = !_isCalendarExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime? selectedDate = context
        .select<ProfileCubit, DateTime?>((cubit) => cubit.getSelectedDate);
    DateTime focusedDate =
        context.select<ProfileCubit, DateTime>((cubit) => cubit.getFocusDate);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  final newDate = DateTime(
                    focusedDate.year,
                    focusedDate.month,
                    focusedDate.day - 1,
                  );
                  context.read<ProfileCubit>().selectFocusDate(newDate);
                  context.read<ProfileCubit>().selectDay(newDate);
                },
                icon: Icon(
                  Icons.chevron_left,
                  color: AppColors.neutral[400],
                  size: 28,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedDate != null
                            ? "${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일"
                            : "${focusedDate.year}년 ${focusedDate.month}월 ${focusedDate.day}일",
                        style: AppTextStyles.textTheme.titleMedium?.copyWith(
                          color: AppColors.neutral[800],
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleCalendar,
                        icon: Icon(
                          _isCalendarExpanded
                              ? Icons.calendar_month
                              : Icons.calendar_today,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  final newDate = DateTime(
                    focusedDate.year,
                    focusedDate.month,
                    focusedDate.day + 1,
                  );
                  context.read<ProfileCubit>().selectFocusDate(newDate);
                  context.read<ProfileCubit>().selectDay(newDate);
                },
                icon: Icon(
                  Icons.chevron_right,
                  color: AppColors.neutral[400],
                  size: 28,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        if (_isCalendarExpanded)
          TableCalendar(
            locale: 'ko_KR',
            focusedDay: focusedDate,
            firstDay: DateTime(1800),
            lastDay: DateTime(2050),
            headerVisible: false,
            calendarFormat: CalendarFormat.month,
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary[100],
                shape: BoxShape.circle,
              ),
            ),
            onPageChanged: (focusedDay) =>
                context.read<ProfileCubit>().selectFocusDate(focusedDay),
            onDaySelected: (DateTime selectedDay, DateTime focusDay) {
              Analytics().logEvent("리포트_날짜선택",
                  parameters: {"날짜": selectedDay.toString()});
              context.read<ProfileCubit>().selectDay(selectedDay);
              context.read<ProfileCubit>().selectFocusDate(selectedDay);
              setState(() {
                _isCalendarExpanded = false;
              });
            },
            selectedDayPredicate: (day) {
              if (selectedDate == null) {
                return false;
              }
              return isSameDay(selectedDate, day);
            },
          ),
      ],
    );
  }
}

class DayBanner extends StatelessWidget {
  const DayBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDate = context
        .select<ProfileCubit, DateTime?>((cubit) => cubit.getSelectedDate);
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
