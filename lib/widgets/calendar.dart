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
  CalendarFormat _calendarFormat = CalendarFormat.week;

  void _toggleCalendarFormat() {
    setState(() {
      _calendarFormat = _calendarFormat == CalendarFormat.week
          ? CalendarFormat.month
          : CalendarFormat.week;
    });

    Analytics().logEvent("캘린더_확장", parameters: {
      "형식": _calendarFormat == CalendarFormat.week ? "주간" : "월간"
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
        TableCalendar(
          locale: 'ko_KR',
          focusedDay: focusedDate,
          firstDay: DateTime(1800),
          lastDay: DateTime(2050),
          headerVisible: true,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: AppTextStyles.textTheme.headlineMedium!,
            headerPadding: const EdgeInsets.only(bottom: 8),
          ),
          calendarFormat: _calendarFormat,
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
          },
          selectedDayPredicate: (day) {
            if (selectedDate == null) {
              return false;
            }
            return isSameDay(selectedDate, day);
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: _toggleCalendarFormat,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _calendarFormat == CalendarFormat.week
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _calendarFormat == CalendarFormat.week ? '펼치기' : '접기',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
