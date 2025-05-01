import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart';
import 'package:udaadaa/cubit/feed_cubit.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/detail/my_record_view.dart';
import 'package:udaadaa/widgets/last_record.dart';
import 'package:udaadaa/widgets/mission_card.dart';

class ChallengerView extends StatelessWidget {
  const ChallengerView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppSpacing.verticalSizedBoxL,
          Calendar(),
          //DayBanner(),
          StreakCard(),
          MissionList(),
        ],
      ),
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
      headerVisible: false,
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
          color: AppColors.primary[100],
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
    int streak = context.select<ChallengeCubit, int>(
      (cubit) => cubit.getConsecutiveDays,
    );
    int completedDays =
        context.select<ChallengeCubit, int>((cubit) => cubit.getCompleteDays);
    final todayComplete = context.select<ChallengeCubit, bool>(
      (cubit) => cubit.getTodayChallengeComplete,
    );
    if (todayComplete) {
      streak++;
    }
    return Container(
      padding: AppSpacing.edgeInsetsS,
      child: Column(
        children: [
          const Divider(
            color: AppColors.primary,
          ),
          Text(
            "이번 챌린지 $completedDays일 인증 완료!",
            style: AppTextStyles.textTheme.headlineLarge,
          ),
          Text(
            todayComplete
                ? "축하합니다! 오늘의 미션을 모두 완수했습니다🎉"
                : "오늘 인증하면 연속 ${streak + 1}일 달성!",
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
          ListView.builder(
            itemCount: 2,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Analytics()
                      .logEvent("챌린지_미션선택", parameters: {"미션": "미션 $index"});
                  /*
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
                        );*/
                },
                child: MissionCard(
                  index: index,
                ),
              );
            },
            shrinkWrap: true,
          ),
          AppSpacing.verticalSizedBoxL,
          LastRecordView(),
        ],
      ),
    );
  }
}

class LastRecordView extends StatefulWidget {
  const LastRecordView({super.key});

  @override
  State<LastRecordView> createState() => _LastRecordViewState();
}

class _LastRecordViewState extends State<LastRecordView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myFeedsLength =
        context.select<FeedCubit, int>((cubit) => cubit.getMyFeeds.length);
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: myFeedsLength != 0
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: min(3, myFeedsLength),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Analytics().logEvent(
                            "홈_최근기록",
                            parameters: {
                              "최근기록_페이지": (index + 1).toString(),
                              "챌린지상태": context
                                  .read<AuthCubit>()
                                  .getChallengeStatus(),
                            },
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MyRecordView(initialPage: index),
                            ),
                          );
                        },
                        child: LastRecord(page: index),
                      );
                    },
                  )
                : const LastRecord(page: 0),
          ),
        ],
      ),
    );
  }
}
