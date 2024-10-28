import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart';
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';

class PushSettingView extends StatefulWidget {
  const PushSettingView({super.key});

  @override
  State<PushSettingView> createState() => _PushSettingViewState();
}

class _PushSettingViewState extends State<PushSettingView> {
  bool _isMissionPushOn = false;
  List<TimeOfDay> alarmTimes = [];

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  void _loadNotificationPreference() {
    final initialAlarms = PreferencesService().getAlarmTimes();
    final missionPushOn = PreferencesService().getBool('isMissionPushOn');

    if (initialAlarms.isEmpty && missionPushOn == null) {
      initialAlarms.add(const TimeOfDay(hour: 10, minute: 0));
    }

    setState(() {
      _isMissionPushOn = missionPushOn ?? false;
      alarmTimes = initialAlarms;
    });
  }

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

  Widget alarmTimeSetting(BuildContext context) {
    return Container(
      padding: AppSpacing.edgeInsetsM,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral[300]!,
            blurRadius: 4,
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
                    "미션 알림 시간",
                    style: AppTextStyles.textTheme.titleSmall,
                  ),
                ],
              ),
              IconButton(
                onPressed: _addAlarmTime,
                icon: const Icon(Icons.add_rounded, color: AppColors.primary),
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
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('푸시알림 설정', style: AppTextStyles.textTheme.headlineLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('리액션 알림', style: AppTextStyles.textTheme.titleSmall),
                Switch(
                  value: context.watch<AuthCubit>().getPushOption ?? false,
                  onChanged: (bool newValue) {
                    context.read<AuthCubit>().togglePush();
                    Analytics().logEvent(
                      "푸시알림_토글",
                      parameters: {"변경값": newValue.toString(), "설정": "리액션"},
                    );
                  },
                  activeTrackColor: AppColors.primary,
                  activeColor: AppColors.white,
                  inactiveThumbColor: AppColors.neutral[0],
                  inactiveTrackColor: AppColors.neutral[200],
                ),
              ],
            ),
            AppSpacing.verticalSizedBoxS,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('미션 알림', style: AppTextStyles.textTheme.titleSmall),
                Switch(
                  value: _isMissionPushOn,
                  onChanged: (bool newValue) {
                    setState(() {
                      _isMissionPushOn = newValue;
                    });
                    Analytics().logEvent(
                      "푸시알션_토글",
                      parameters: {"변경값": newValue.toString(), "설정": "미션"},
                    );
                  },
                  activeTrackColor: AppColors.primary,
                  activeColor: AppColors.white,
                  inactiveThumbColor: AppColors.neutral[0],
                  inactiveTrackColor: AppColors.neutral[200],
                ),
              ],
            ),
            AppSpacing.verticalSizedBoxXxs,
            (_isMissionPushOn ? alarmTimeSetting(context) : Container()),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        width: double.infinity,
        child: FloatingActionButton.extended(
          heroTag: 'pushSetting',
          onPressed: () {
            Analytics().logEvent(
              "푸시설정_완료",
              parameters: {"버튼": "클릭"},
            );
            if (_isMissionPushOn) {
              context.read<ChallengeCubit>().scheduleNotifications(alarmTimes);
            } else {
              context.read<ChallengeCubit>().cancelNotifications();
            }
            Navigator.of(context).pop();
          },
          label: Text(
            '설정 완료',
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
