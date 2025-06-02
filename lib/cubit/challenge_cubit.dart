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
  int _completeDays = 0;
  DateTime? _finalStartDate;

  double? _startWeight;
  double? _endWeight;

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
          isSuccess: false,
        );
        final challengeMap = challenge.toMap();
        _challenge = challenge;
        await supabase.from('challenge').insert(challengeMap).select().single();
        emit(ChallengeSuccess());
        authCubit.setIsChallenger(true);
        selectDay(DateTime.now());
      } else {
        emit(ChallengeError("이미 참여 중 입니다."));
      }
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> enterChallengeByDay(DateTime startDay, DateTime endDay) async {
    try {
      final Challenge challenge = Challenge(
        startDay: startDay,
        endDay: endDay,
        userId: supabase.auth.currentUser!.id,
        isSuccess: false,
      );
      final challengeMap = challenge.toMap();
      _challenge = challenge;
      await supabase.from('challenge').insert(challengeMap);
      emit(ChallengeSuccess());
      authCubit.setIsChallenger(true);
      selectDay(DateTime.now());
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

      authCubit.setWasChallenger(true);
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
        getTodayMission();
        getCurrentChallengeCompletedDays();
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

    final nickname = (authCubit.getCurProfile?.nickname.isNotEmpty ?? false)
        ? "${authCubit.getCurProfile!.nickname}님, "
        : "";

    logger.d("🔄 알림 초기화 중...");
    NotificationService.cancelNotification().then((_) {
      final now = DateTime.now();
      logger.d("📆 현재 시각: $now");
      logger.d("⏰ 설정된 알람 시간 개수: ${alarmTimes.length}");

      for (int i = 0; i < alarmTimes.length; i++) {
        final time = alarmTimes[i];

        final firstDate = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        logger.d(
            "🛠️ 알림 예약 준비 - ID: $i, 시간: ${time.hour}:${time.minute}, 시작일: $firstDate");

        NotificationService.scheduleNotification(
          i,
          "오늘의 미션 인증 시간이에요 ⏰",
          "지금 바로 인증하여 다이어트 성공을 향해 한 발짝 더 나아가요 🚀",
          time.hour,
          time.minute,
          firstDate,
        );
      }

      logger.d("✅ 알림 예약 처리 완료");
    });
  }

  Future<void> cancelNotifications() async {
    Future.wait([
      PreferencesService().setBool('isMissionPushOn', false),
      NotificationService.cancelNotification(),
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

  Future<int> getCurrentChallengeCompletedDays() async {
    if (_challenge == null) return 0;

    int completedDays = 0;
    DateTime startDate = _challenge!.startDay;
    DateTime today = DateTime.now();

    for (DateTime date = startDate;
        date.isBefore(today) ||
            (date.year == today.year &&
                date.month == today.month &&
                date.day == today.day);
        date = date.add(Duration(days: 1))) {
      if (challenge!.endDay.isBefore(date)) {
        break;
      }
      DateTime dayStart = DateTime(date.year, date.month, date.day, -9);
      DateTime dayEnd =
          dayStart.add(Duration(days: 1)).subtract(Duration(seconds: 1));

      final feedCount = await supabase
          .from('feed')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .neq('type', 'exercise')
          .count(CountOption.exact)
          .then((res) => res.count);

      final weightCount = await supabase
          .from('weight')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .count(CountOption.exact)
          .then((res) => res.count);

      if (feedCount >= 2 && weightCount >= 1) {
        completedDays++;
      }
    }

    _completeDays = completedDays;
    emit(ChallengeSuccess());
    return completedDays;
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
          .neq('type', 'exercise')
          .count(CountOption.exact)
          .then((res) => res.count);

      // 몸무게 조회
      final weightCount = await supabase
          .from('weight')
          .select('id')
          .eq('user_id', userId)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .count(CountOption.exact)
          .then((res) => res.count);

/*
      // 리액션 수 조회
      final reactionCount = await supabase
          .from('reactions')
          .select('id')
          .eq('user_id', userId)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .count(CountOption.exact)
          .then((res) => res.count);*/

      if (feedCount >= 2 && weightCount >= 1) {
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
      // final ret = await supabase
      //     .from('challenge')
      //     .select('*')
      //     .gte('end_day', _selectedDate)
      //     .lte('start_day', _selectedDate)
      //     .eq('user_id', supabase.auth.currentUser!.id);
      // if (ret.isEmpty) {
      //   _selectedDayChallenge = false;
      //   return;
      // }
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
          .neq('type', 'exercise')
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
      /*
      // 리액션 수 조회
      final reactionCount = await supabase
          .from('reactions')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .count(CountOption.exact)
          .then((res) => res.count);
      _selectedMissionComplete['reaction'] = reactionCount;*/
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
          .neq('type', 'exercise')
          .count(CountOption.exact)
          .then((res) => res.count);
      _todayMissionComplete['feed'] = feedCount;

      // 몸무게 조회
      final weightCount = await supabase
          .from('weight')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .count(CountOption.exact)
          .then((res) => res.count);
      _todayMissionComplete['weight'] = weightCount;
/*
      // 리액션 수 조회
      final reactionCount = await supabase
          .from('reactions')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .gte('created_at', dayStart.toIso8601String())
          .lte('created_at', dayEnd.toIso8601String())
          .count(CountOption.exact)
          .then((res) => res.count);
      _todayMissionComplete['reaction'] = reactionCount;*/

      if (feedCount >= 2 && weightCount >= 1) {
        _todayChallengeComplete = true;
        getCurrentChallengeCompletedDays();
      }
      emit(ChallengeSuccess());
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> updateMission() async {
    try {
      final now = DateTime.now();
      debugPrint("now: $now");
      debugPrint("endDay: ${_challenge!.endDay}");
      await getTodayMission();
      if (now.year == _selectedDate.year &&
          now.month == _selectedDate.month &&
          now.day == _selectedDate.day) {
        _selectedMissionComplete['feed'] = _todayMissionComplete['feed']!;
        _selectedMissionComplete['reaction'] =
            _todayMissionComplete['reaction']!;
        _selectedMissionComplete['weight'] = _todayMissionComplete['weight']!;
      }
      emit(ChallengeSuccess());
      if (_challenge != null && _challenge!.isSuccess == false) {
        if (_consecutiveDays < 13) return;
        final endDay = _challenge!.endDay;
        if (now.year == endDay.year &&
            now.month == endDay.month &&
            now.day == endDay.day) {
          if (_todayChallengeComplete) {
            _challenge = _challenge!.copyWith(isSuccess: true);
            await supabase
                .from('challenge')
                .update(_challenge!.toMap())
                .eq('id', _challenge!.id!);
            emit(ChallengeEnd(endDay));
          }
        }
      }
    } catch (e) {
      logger.e(e);
    }
  }

  // result_list_view에서밖에 안씀
  Future<void> fetchChallenge() async {
    try {
      emit(ChallengeLoading());
      final response = await supabase
          .from('challenge')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
          .lt('end_day', DateTime.now().toIso8601String())
          .order('start_day', ascending: true);

      final challengeList =
          response.map((e) => Challenge.fromMap(map: e)).toList();
      if (_challenge != null && _challenge!.isSuccess == true) {
        challengeList.add(_challenge!);
      }
      emit(ChallengeList(challengeList));
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> fetchStartAndEndWeights(
      DateTime startDate, DateTime endDate) async {
    try {
      if (authCubit.state is! Authenticated) {
        return;
      }

      final startReport = await supabase
          .from('report')
          .select('weight')
          .eq('date', startDate.toIso8601String())
          .maybeSingle();

      final endReport = await supabase
          .from('report')
          .select('weight')
          .eq('date', endDate.toIso8601String())
          .maybeSingle();

      final startWeight = startReport?['weight'];
      final endWeight = endReport?['weight'];

      if (startWeight == null || endWeight == null) {
        return;
      }
      _startWeight = startWeight.toDouble();
      _endWeight = endWeight.toDouble();
    } catch (e) {
      logger.e('Error fetching start/end weights: $e');
    }
  }

  Challenge? get challenge => _challenge;
  DateTime get getSelectedDate => _selectedDate;
  DateTime get getFocusDate => _focusDate;
  int get getConsecutiveDays => _consecutiveDays;
  Map<String, int> get getSelectedMission => _selectedMissionComplete;
  bool get getSelectedDayChallenge => _selectedDayChallenge;
  bool get getTodayChallengeComplete => _todayChallengeComplete;
  int get getCompleteDays => _completeDays;
  double? get getStartWeight => _startWeight;
  double? get getEndWeight => _endWeight;
}
