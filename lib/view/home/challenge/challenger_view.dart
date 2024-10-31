import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:udaadaa/cubit/bottom_nav_cubit.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/form/weight/weight_first_view.dart';
import 'package:udaadaa/view/onboarding/first_view.dart';
import 'package:udaadaa/widgets/mission_card.dart';

class ChallengerView extends StatelessWidget {
  const ChallengerView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Calendar(),
        //DayBanner(),
        StreakCard(),
        MissionList(),
      ],
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

class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    final streak = context.select<ChallengeCubit, int>(
      (cubit) => cubit.getConsecutiveDays,
    );
    return Container(
      padding: AppSpacing.edgeInsetsS,
      child: Column(
        children: [
          const Divider(
            color: AppColors.primary,
          ),
          Text(
            "현재 연속 $streak일 인증 완료",
            style: AppTextStyles.textTheme.headlineLarge,
          ),
          Text(
            "오늘 인증하면 연속 $streak일 달성!",
            style: AppTextStyles.textTheme.bodyLarge,
          ),
          const Divider(
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class MissionList extends StatelessWidget {
  const MissionList({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDate = context
        .select<ChallengeCubit, DateTime?>((cubit) => cubit.getSelectedDate);
    const weekday = "월화수목금토일";
    final selectedDayChallenge = context
        .select<ChallengeCubit, bool>((cubit) => cubit.getSelectedDayChallenge);

    if (selectedDate == null) {
      return Container();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              (isSameDay(DateTime.now(), selectedDate)
                  ? "오늘"
                  : '${selectedDate.month}/${selectedDate.day}(${weekday[selectedDate.weekday - 1]})'),
              style: AppTextStyles.textTheme.headlineMedium),
          AppSpacing.verticalSizedBoxS,
          (selectedDayChallenge
              ? ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Analytics().logEvent("챌린지_미션선택",
                            parameters: {"미션": "미션 $index"});
                        if (index == 2) {
                          context
                              .read<BottomNavCubit>()
                              .selectTab(BottomNavState.feed);
                          return;
                        }
                        if (index == 0) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const FirstView()));
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WeightFirstView(),
                          ),
                        );
                      },
                      child: MissionCard(
                        index: index,
                      ),
                    );
                  },
                  shrinkWrap: true,
                )
              : Container()),
        ],
      ),
    );
  }
}
