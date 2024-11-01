import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart';
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/view/onboarding/eighth_view.dart';

class PushSettingView extends StatefulWidget {
  const PushSettingView({super.key});

  @override
  State<PushSettingView> createState() => _PushSettingViewState();
}

class _PushSettingViewState extends State<PushSettingView> {
  bool _isMissionPushOn = false, _isReactionPushOn = false;
  List<TimeOfDay> alarmTimes = [];

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  void _loadNotificationPreference() {
    final initialAlarms = PreferencesService().getAlarmTimes();
    final missionPushOn = PreferencesService().getBool('isMissionPushOn');
    final reactionPushOn = context.read<AuthCubit>().getPushOption;

    if (initialAlarms.isEmpty && missionPushOn == null) {
      initialAlarms.add(const TimeOfDay(hour: 10, minute: 0));
    }

    setState(() {
      _isMissionPushOn = missionPushOn ?? false;
      alarmTimes = initialAlarms;
      _isReactionPushOn = reactionPushOn ?? false;
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
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.s),
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
            padding: EdgeInsets.zero,
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
        title: Text('알림 설정', style: AppTextStyles.textTheme.headlineLarge),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.neutral[50],
                borderRadius: BorderRadius.circular(16),
              ),
              padding: AppSpacing.edgeInsetsM,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('응원 알림',
                            style: AppTextStyles.textTheme.titleSmall),
                        AppSpacing.verticalSizedBoxXxs,
                        Text("다른 우다다 사용자가 응원을 남기면 활동 알림을 받아요.",
                            style: AppTextStyles.textTheme.labelMedium),
                      ],
                    ),
                  ),
                  AppSpacing.horizontalSizedBoxS,
                  Switch(
                    value: _isReactionPushOn,
                    onChanged: (bool newValue) {
                      setState(() {
                        _isReactionPushOn = newValue;
                      });
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
            ),
            AppSpacing.verticalSizedBoxS,
            Container(
              decoration: BoxDecoration(
                color: AppColors.neutral[50],
                borderRadius: BorderRadius.circular(16),
              ),
              padding: AppSpacing.edgeInsetsM,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('미션 알림',
                                    style: AppTextStyles.textTheme.titleSmall),
                                AppSpacing.horizontalSizedBoxS,
                                Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(AppSpacing.s),
                                    ),
                                  ),
                                  padding: AppSpacing.edgeInsetsXxs,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        //backgroundColor: AppColors.white,
                                        radius: 12,
                                        child: Text(
                                          "🏆",
                                          style: AppTextStyles.bodyMedium(
                                            const TextStyle(
                                              fontFamily: 'tossface',
                                            ),
                                          ),
                                        ),
                                      ),
                                      //AppSpacing.horizontalSizedBoxXxs,
                                      Text(
                                        "챌린지",
                                        style: AppTextStyles.bodySmall(
                                          const TextStyle(
                                              color: AppColors.white),
                                        ),
                                      ),
                                      AppSpacing.horizontalSizedBoxXxs,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.verticalSizedBoxXxs,
                            Text("오늘의 미션 인증을 까먹지 않게 알려드려요.",
                                style: AppTextStyles.textTheme.labelMedium),
                          ],
                        ),
                      ),
                      AppSpacing.horizontalSizedBoxS,
                      Switch(
                        value: _isMissionPushOn,
                        onChanged: (bool newValue) {
                          setState(() {
                            _isMissionPushOn = newValue;
                          });
                          Analytics().logEvent(
                            "푸시알션_토글",
                            parameters: {
                              "변경값": newValue.toString(),
                              "설정": "미션"
                            },
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
            if (context.read<AuthCubit>().getIsChallenger == false &&
                _isMissionPushOn) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  actionsOverflowDirection: VerticalDirection.down,
                  actions: [
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.s),
                              foregroundColor: Theme.of(context).primaryColor,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 0),
                            ),
                            onPressed: () {
                              setState(() {
                                _isMissionPushOn = false;
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text('취소',
                                style: AppTextStyles.textTheme.headlineSmall),
                          ),
                        ),
                        AppSpacing.verticalSizedBoxS,
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.s),
                              foregroundColor: AppColors.white,
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 0),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const EighthView(),
                                ),
                              );
                            },
                            child: Text(
                              '챌린지 참여하기',
                              style: AppTextStyles.textTheme.headlineSmall
                                  ?.copyWith(
                                color: AppColors.white, // 텍스트 색상 설정
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  title: Text('미션 알림 기능',
                      style: AppTextStyles.textTheme.headlineMedium),
                  content: Text('미션 알림은 챌린지에 참여하면 설정할 수 있어요!',
                      style: AppTextStyles.textTheme.bodyLarge),
                ),
              );
              return;
            }
            if (_isMissionPushOn) {
              context.read<ChallengeCubit>().scheduleNotifications(alarmTimes);
            } else {
              context.read<ChallengeCubit>().cancelNotifications();
            }
            if (_isReactionPushOn != context.read<AuthCubit>().getPushOption) {
              context.read<AuthCubit>().togglePush();
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
