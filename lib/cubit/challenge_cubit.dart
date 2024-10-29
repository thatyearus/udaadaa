import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/models/challenge.dart';
import 'package:udaadaa/service/shared_preferences.dart';
import 'package:udaadaa/utils/constant.dart';
import 'package:udaadaa/service/notifications/notification_service.dart';

part 'challenge_state.dart';

class ChallengeCubit extends Cubit<ChallengeState> {
  final AuthCubit authCubit;
  late final StreamSubscription authSubscription;
  Challenge? _challenge;
  DateTime? _selectedDate;
  DateTime _focusDate = DateTime.now();

  ChallengeCubit(this.authCubit) : super(ChallengeInitial()) {
    final authState = authCubit.state;
    if (authState is Authenticated) {
      isEntered();
      // 연속 참여 일 계산
    }

    authSubscription = authCubit.stream.listen((authState) {
      if (authState is Authenticated) {
        // 연속 참여 일 계산
        isEntered();
      } else {
        emit(ChallengeInitial());
      }
    });
  }

  @override
  Future<void> close() {
    authSubscription.cancel();
    return super.close();
  }

  Future<void> enterChallenge() async {
    try {
      final entered = await isEntered();
      if (!entered) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final Challenge challenge = Challenge(
          startDay: today,
          endDay: today.add(const Duration(days: 6)),
          userId: supabase.auth.currentUser!.id,
        );
        final challengeMap = challenge.toMap();
        _challenge = challenge;
        await supabase.from('challenge').insert(challengeMap).select().single();
        emit(ChallengeSuccess());
        authCubit.setIsChallenger(true);
      } else {
        emit(ChallengeError("이미 참여 중 입니다."));
      }
    } catch (e) {
      logger.e(e);
    }
  }

  Future<bool> isEntered() async {
    try {
      final r = await supabase
          .from('challenge')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id);

      if (r.isEmpty) {
        authCubit.setIsChallenger(false);
        return false;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final ret = await supabase
          .from('challenge')
          .select('*')
          .gte('end_day', today)
          .eq('user_id', supabase.auth.currentUser!.id);
      if (ret.isNotEmpty) {
        authCubit.setIsChallenger(true);
        _challenge = Challenge.fromMap(map: ret[0]);
        return true;
      }
    } catch (e) {
      logger.e(e);
    }
    authCubit.setIsChallenger(false);
    return false;
  }

  void selectFocusDate(DateTime date) {
    _focusDate = date;
    emit(ChallengeSuccess());
  }

  void selectDay(DateTime date) {
    _selectedDate = date;
    emit(ChallengeSuccess());
  }

  Future<void> scheduleNotifications(List<TimeOfDay> alarmTimes) async {
    PreferencesService().setAlarmTimes(alarmTimes);
    PreferencesService().setBool('isMissionPushOn', true);
    await isEntered();
    if (_challenge == null) {
      return;
    }

    final nickname = (authCubit.getCurProfile?.nickname.isNotEmpty ?? false)
        ? "${authCubit.getCurProfile!.nickname}님, "
        : "";

    NotificationService.cacnelNotification().then((_) {
      for (int i = 0; i < 7; i++) {
        final DateTime date = _challenge!.startDay.add(Duration(days: i));
        for (var j = 0; j < alarmTimes.length; j++) {
          final time = alarmTimes[j];
          NotificationService.scheduleNotification(
            i * alarmTimes.length + j,
            "오늘의 미션 인증 시간이에요 ⏰",
            "$nickname지금 바로 인증하여 다이어트 성공을 향해 한 발짝 더 나아가요 🚀",
            time.hour,
            time.minute,
            date,
          );
        }
      }
    });
  }

  Future<void> cancelNotifications() async {
    Future.wait([
      PreferencesService().setBool('isMissionPushOn', false),
      NotificationService.cacnelNotification(),
    ]);
  }

  Challenge? get challenge => _challenge;
  DateTime? get getSelectedDate => _selectedDate;
  DateTime get getFocusDate => _focusDate;
}
