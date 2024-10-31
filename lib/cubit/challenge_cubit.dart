import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  DateTime _selectedDate = DateTime.now();
  DateTime _focusDate = DateTime.now();
  int _consecutiveDays = 0;
  DateTime? _finalStartDate;
  final Map<String, int> _selectedMissionComplete = {
    "feed": 0,
    "reaction": 0,
    "weight": 0
  };
  final Map<String, int> _todayMissionComplete = {
    "feed": 0,
    "reaction": 0,
    "weight": 0
  };
  bool _todayChallengeComplete = false;
  bool _selectedDayChallenge = false;

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

    selectDay(DateTime.now());
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
        await getCurrentChallenges();
        getConsecutiveChallengeDays(
          supabase.auth.currentUser!.id,
          _finalStartDate!,
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
        );
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
    getSelectedDayMission();
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

  Future<void> getCurrentChallenges() async {
    try {
      DateTime? startDate;
      DateTime endDate = DateTime.now();

      final response = await supabase
          .from('challenge')
          .select('start_day, end_day')
          .eq('user_id', supabase.auth.currentUser!.id)
          .order('start_day', ascending: false);

      if (response.isEmpty) {
        return;
      }

      for (final challenge in response) {
        final challengeStart = DateTime.parse(challenge['start_day']);
        final challengeEnd = DateTime.parse(challenge['end_day']);

        if (endDate.isBefore(
          challengeStart.subtract(const Duration(days: 1)),
        )) {
          break;
        }

        startDate = challengeStart;
        endDate = challengeEnd.isAfter(endDate) ? challengeEnd : endDate;
      }
      _finalStartDate = startDate;
    } catch (error) {
      logger.e(error);
    }
  }

  Future<int> getConsecutiveChallengeDays(
      String userId, DateTime startDate, DateTime endDate) async {
    int consecutiveDays = 0;

    for (DateTime date = endDate.subtract(const Duration(days: 1));
        date.isAfter(startDate) || date.isAtSameMomentAs(startDate);
        date = date.subtract(const Duration(days: 1))) {
      DateTime dayStart = DateTime(date.year, date.month, date.day, -9);
      DateTime dayEnd = dayStart
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1));

      // 피드 수 조회
      final feedCount = await supabase
          .from('feed')
          .select('id')
          .eq('user_id', userId)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .count(CountOption.exact)
          .then((res) => res.count);

      // 몸묵게 조회
      final weightCount = await supabase
          .from('weight')
          .select('id')
          .eq('user_id', userId)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .count(CountOption.exact)
          .then((res) => res.count);

      // 리액션 수 조회
      final reactionCount = await supabase
          .from('reactions')
          .select('id')
          .eq('user_id', userId)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .count(CountOption.exact)
          .then((res) => res.count);

      if (feedCount >= 2 && reactionCount >= 3 && weightCount >= 1) {
        consecutiveDays++;
      } else {
        break;
      }
    }
    _consecutiveDays = consecutiveDays;
    emit(ChallengeSuccess());
    return consecutiveDays;
  }

  Future<void> getSelectedDayMission() async {
    try {
      final ret = await supabase
          .from('challenge')
          .select('*')
          .gte('end_day', _selectedDate)
          .lte('start_day', _selectedDate)
          .eq('user_id', supabase.auth.currentUser!.id);
      if (ret.isEmpty) {
        _selectedDayChallenge = false;
        return;
      }
      _selectedDayChallenge = true;

      DateTime dayStart = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day, -9);
      DateTime dayEnd = dayStart
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1));

      // 피드 수 조회
      final feedCount = await supabase
          .from('feed')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .count(CountOption.exact)
          .then((res) => res.count);
      _selectedMissionComplete['feed'] = feedCount;

      // 몸묵게 조회
      final weightCount = await supabase
          .from('weight')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .count(CountOption.exact)
          .then((res) => res.count);
      _selectedMissionComplete['weight'] = weightCount;

      // 리액션 수 조회
      final reactionCount = await supabase
          .from('reactions')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .count(CountOption.exact)
          .then((res) => res.count);
      _selectedMissionComplete['reaction'] = reactionCount;
      logger.d("missionComplete: $_selectedMissionComplete");
      emit(ChallengeSuccess());
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> getTodayMission() async {
    try {
      final DateTime now = DateTime.now();
      final DateTime dayStart = DateTime(now.year, now.month, now.day, -9);
      final DateTime dayEnd = dayStart
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1));

      // 피드 수 조회
      final feedCount = await supabase
          .from('feed')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .count(CountOption.exact)
          .then((res) => res.count);
      _todayMissionComplete['feed'] = feedCount;

      // 몸묵게 조회
      final weightCount = await supabase
          .from('weight')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .count(CountOption.exact)
          .then((res) => res.count);
      _todayMissionComplete['weight'] = weightCount;

      // 리액션 수 조회
      final reactionCount = await supabase
          .from('reactions')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .count(CountOption.exact)
          .then((res) => res.count);
      _todayMissionComplete['reaction'] = reactionCount;
      if (feedCount >= 2 && reactionCount >= 3 && weightCount >= 1) {
        _todayChallengeComplete = true;
      }
      emit(ChallengeSuccess());
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> updateMission() async {
    try {
      await getTodayMission();
      final now = DateTime.now();
      if (now.year == _selectedDate.year &&
          now.month == _selectedDate.month &&
          now.day == _selectedDate.day) {
        _selectedMissionComplete['feed'] = _todayMissionComplete['feed']!;
        _selectedMissionComplete['reaction'] =
            _todayMissionComplete['reaction']!;
        _selectedMissionComplete['weight'] = _todayMissionComplete['weight']!;
      }
      emit(ChallengeSuccess());
    } catch (e) {
      logger.e(e);
    }
  }

  Challenge? get challenge => _challenge;
  DateTime get getSelectedDate => _selectedDate;
  DateTime get getFocusDate => _focusDate;
  int get getConsecutiveDays => _consecutiveDays;
  Map<String, int> get getSelectedMission => _selectedMissionComplete;
  bool get getSelectedDayChallenge => _selectedDayChallenge;
  bool get getTodayChallengeComplete => _todayChallengeComplete;
}
