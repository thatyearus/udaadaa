import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/cubit/challenge_cubit.dart';
import 'package:udaadaa/cubit/tutorial_cubit.dart';
import 'package:udaadaa/service/notifications/notification_service.dart';
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';

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

  void showTutorial(BuildContext context) {
    final onboardingCubit = context.read<TutorialCubit>();

    late TutorialCoachMark tutorialCoachMark;
    tutorialCoachMark = TutorialCoachMark(
      hideSkip: false,
      onSkip: () {
        logger.d("스킵 누름 - push_setting_view");
        Analytics().logEvent("튜토리얼_스킵", parameters: {
          "view": "push_setting_view", // 현재 튜토리얼이 실행된 뷰
        });
        PreferencesService().setBool('isTutorialFinished', true);
        return true; // 👈 튜토리얼 종료
      },
      alignSkip: Alignment.topLeft,
      skipWidget: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: const Text(
          "SKIP",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      targets: [
        TargetFocus(
          identify: "mission_push",
          keyTarget: onboardingCubit.missionPushSettingButtonKey,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: Text(
                "매일 인증을 까먹지 않게 미션 알림을 설정해보세요.",
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: Colors.white, // 흰색 글씨
                  fontWeight: FontWeight.bold, // 글씨 굵게 (Bold)
                  fontSize: 18, // 글씨 크기 증가
                ),
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: "add_mission_push",
          keyTarget: onboardingCubit.addMissionPushButtonKey,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: Text(
                "시간을 추가하면 미션 알림을 받을 수 있어요.",
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: Colors.white, // 흰색 글씨
                  fontWeight: FontWeight.bold, // 글씨 굵게 (Bold)
                  fontSize: 18, // 글씨 크기 증가
                ),
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: "setting_finish",
          keyTarget: onboardingCubit.pushSettingFinishButtonKey,
          shape: ShapeLightFocus.RRect,
          radius: 8,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: Text(
                "버튼을 눌러 설정을 완료해주세요.",
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: Colors.white, // 흰색 글씨
                  fontWeight: FontWeight.bold, // 글씨 굵게 (Bold)
                  fontSize: 18, // 글씨 크기 증가
                ),
              ),
            ),
          ],
        ),
      ],
      onClickTarget: (target) {
        Analytics().logEvent('튜토리얼_푸시설정',
            parameters: {'target': target.identify.toString()});
        logger.d("onClickTarget: ${target.identify}");
        if (target.identify == "mission_push") {
          setState(() {
            _isMissionPushOn = true;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              tutorialCoachMark.next();
            }
          });
        } else if (target.identify == "add_mission_push") {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              tutorialCoachMark.next();
            }
          });
        } else if (target.identify == "setting_finish") {
          if (_isMissionPushOn) {
            context.read<ChallengeCubit>().scheduleNotifications(alarmTimes);
          } else {
            context.read<ChallengeCubit>().cancelNotifications();
          }
          if (_isReactionPushOn != context.read<AuthCubit>().getPushOption) {
            context.read<AuthCubit>().togglePush();
          }
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      },
      onFinish: () {
        logger.d("finish tutorial push setting view");
        PreferencesService().setBool('isTutorialFinished', true);
      },
    );

    tutorialCoachMark.show(context: context);
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
                key: context.read<TutorialCubit>().addMissionPushButtonKey,
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
      body: BlocListener<TutorialCubit, TutorialState>(
        listener: (context, state) {
          if (state is TutorialPush) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (context.mounted &&
                    PreferencesService().getBool('isTutorialFinished') !=
                        true) {
                  showTutorial(context);
                }
              });
            });
          }
        },
        child: Padding(
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
                                      style:
                                          AppTextStyles.textTheme.titleSmall),
                                  AppSpacing.horizontalSizedBoxS,
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
                          key: context
                              .read<TutorialCubit>()
                              .missionPushSettingButtonKey,
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
                    (_isMissionPushOn
                        ? alarmTimeSetting(context)
                        : Container()),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.s),
                padding: AppSpacing.edgeInsetsM,
                decoration: BoxDecoration(
                  color: AppColors.neutral[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bug_report, color: AppColors.primary),
                        AppSpacing.horizontalSizedBoxS,
                        Text(
                          "알림 테스트",
                          style: AppTextStyles.textTheme.titleSmall,
                        ),
                      ],
                    ),
                    AppSpacing.verticalSizedBoxXs,
                    Text(
                      "버튼을 눌러 로컬 알림이 잘 오는지 테스트해보세요.",
                      style: AppTextStyles.textTheme.labelMedium,
                    ),
                    AppSpacing.verticalSizedBoxS,
                    ElevatedButton(
                      onPressed: () {
                        NotificationService.showNotification(
                          "🧪 테스트 알림",
                          "지금 이 알림이 오면 로컬 알림 성공!",
                        );
                      },
                      child: Text("알림 테스트 해보기"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        key: context.read<TutorialCubit>().pushSettingFinishButtonKey,
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
