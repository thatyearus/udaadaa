import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
import 'package:udaadaa/utils/constant.dart';

class PushSettingView extends StatefulWidget {
  const PushSettingView({super.key});

  @override
  State<PushSettingView> createState() => _PushSettingViewState();
}

class _PushSettingViewState extends State<PushSettingView> {
  bool isMissionPushOn = false;

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
                  value: isMissionPushOn,
                  onChanged: (bool newValue) {
                    setState(() {
                      isMissionPushOn = newValue;
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
          ],
        ),
      ),
    );
  }
}
