import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/main_view.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/service/shared_preferences.dart';

class TenthView extends StatefulWidget {
  const TenthView({super.key});

  @override
  State<TenthView> createState() => _TenthViewState();
}

class _TenthViewState extends State<TenthView> {
  List<TimeOfDay> alarmTimes = [const TimeOfDay(hour: 10, minute: 0)];

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    if (a.hour == b.hour) {
      return a.minute.compareTo(b.minute);
    }
    return a.hour.compareTo(b.hour);
  }

  void _addAlarmTime() async {
    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (pickedTime != null) {
      bool isDuplicate = alarmTimes.any((time) =>
          time.hour == pickedTime.hour && time.minute == pickedTime.minute);

      if (!isDuplicate) {
        setState(() {
          alarmTimes.add(pickedTime);
          alarmTimes.sort(_compareTimeOfDay);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "미션 알림 시간을\n설정해 볼까요?",
                style: AppTextStyles.textTheme.displayMedium,
              ),
              AppSpacing.verticalSizedBoxXxl,
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.primary,
                            ),
                            AppSpacing.horizontalSizedBoxS,
                            Text(
                              "알림 설정",
                              style: AppTextStyles.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _addAlarmTime,
                          icon: const Icon(Icons.add_rounded,
                              color: AppColors.primary),
                          alignment: Alignment.center,
                        ),
                      ],
                    ),
                    AppSpacing.verticalSizedBoxXs,
                    Divider(
                      color: AppColors.neutral[300],
                      thickness: 1.0,
                    ),
                    AppSpacing.verticalSizedBoxXs,
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: alarmTimes.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xxs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              AppSpacing.horizontalSizedBoxL,
                              const Icon(
                                Icons.alarm_rounded,
                                color: AppColors.primary,
                              ),
                              AppSpacing.horizontalSizedBoxS,
                              Expanded(
                                child: Text(
                                  _formatTimeOfDay(alarmTimes[index]),
                                  style: AppTextStyles.textTheme.headlineMedium,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close_rounded,
                                    color: AppColors.neutral[300]),
                                onPressed: () {
                                  setState(() {
                                    alarmTimes.removeAt(index);
                                  });
                                },
                                alignment: Alignment.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        width: double.infinity,
        child: FloatingActionButton.extended(
          heroTag: 'onboarding9',
          onPressed: () {
            Analytics().logEvent(
              "온보딩_완료",
              parameters: {"버튼": "클릭"},
            );
            context.read<ChallengeCubit>().enterChallenge();
            context.read<ChallengeCubit>().scheduleNotifications(alarmTimes);
            PreferencesService().setBool('isOnboardingComplete', true);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MainView(),
              ),
              (Route<dynamic> route) => false,
            );
          },
          label: Text(
            '시작하기',
            style: AppTextStyles.textTheme.titleMedium
                ?.copyWith(color: AppColors.white),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
