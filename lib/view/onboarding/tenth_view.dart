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
                  color: Colors.white,
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
                            const SizedBox(width: 10),
                            Text(
                              "알림 설정",
                              style: AppTextStyles.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _addAlarmTime,
                          icon: const Icon(Icons.add, color: AppColors.primary),
                          alignment: Alignment.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: alarmTimes.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 20),
                              const Icon(
                                Icons.alarm,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _formatTimeOfDay(alarmTimes[index]),
                                  style: AppTextStyles.textTheme.headlineMedium,
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    alarmTimes.removeAt(index);
                                  });
                                },
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(right: 0.0),
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
            //TODO: push 시간 설정 코드 넣기
            context.read<ChallengeCubit>().enterChallenge();
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
