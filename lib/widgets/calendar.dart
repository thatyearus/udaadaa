import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:udaadaa/cubit/profile_cubit.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  bool isExpanded = false;

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
          headerVisible: false,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: AppTextStyles.textTheme.headlineMedium!,
          ),
          calendarFormat:
              isExpanded ? CalendarFormat.month : CalendarFormat.week,
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
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              final challenge = context.read<ChallengeCubit>().challenge;
              if (challenge == null) return null;

              final isStartDay = isSameDay(date, challenge.startDay);
              final isEndDay = isSameDay(date, challenge.endDay);

              if (isStartDay || isEndDay) {
                return Positioned(
                  bottom: 1,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primary[50],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      isStartDay ? '챌린지 시작' : '챌린지 종료',
                      style: AppTextStyles.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
          onPageChanged: (focusedDay) {
            context.read<ProfileCubit>().selectFocusDate(focusedDay);
            context.read<ChallengeCubit>().selectFocusDate(focusedDay);
          },
          onDaySelected: (DateTime selectedDay, DateTime focusDay) {
            Analytics().logEvent("리포트_날짜선택",
                parameters: {"날짜": selectedDay.toString()});
            context.read<ProfileCubit>().selectDay(selectedDay);
            context.read<ChallengeCubit>().selectDay(selectedDay);
          },
          selectedDayPredicate: (day) {
            if (selectedDate == null) {
              return false;
            }
            return isSameDay(selectedDate, day);
          },
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              Analytics().logEvent("켈린더_펼치기_클릭");
              isExpanded = !isExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isExpanded ? '접기' : '펼치기',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
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
