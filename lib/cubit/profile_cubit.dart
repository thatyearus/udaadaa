import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:udaadaa/cubit/auth_cubit.dart';
import 'package:udaadaa/models/report.dart';
import 'package:udaadaa/utils/constant.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthCubit authCubit;
  late final StreamSubscription authSubscription;
  Report? _report;
  Report? _selectedReport;
  Report? _yesterdayReport;
  DateTime? _selectedDate;
  DateTime _focusDate = DateTime.now();
  List<bool> _typeSelection = [true, false];
  final List<Report?> _weeklyReport = [
    null,
    null,
    null,
    null,
    null,
    null,
    null
  ];

  ProfileCubit(this.authCubit) : super(ProfileInitial()) {
    final authState = authCubit.state;
    if (authState is Authenticated) {
      getMyTodayReport();
      selectDay(DateTime.now());
    }

    authSubscription = authCubit.stream.listen((authState) {
      if (authState is Authenticated) {
        getMyTodayReport();
        selectDay(DateTime.now());
      } else {
        emit(ProfileInitial());
      }
    });
  }

  void updateTypeSelection(int index) {
    _typeSelection = List.generate(_typeSelection.length, (i) => i == index);
    emit(ProfileLoaded("typeSelection"));
  }

  Future<void> getMyTodayReport() async {
    if (authCubit.state is! Authenticated) {
      return;
    }
    try {
      final reportMap = await supabase
          .from('report')
          .select()
          .eq('date', DateTime.now().toIso8601String());
      if (reportMap.isEmpty) {
        _report = null;
        emit(ProfileLoaded("report"));
        return;
      }
      _report = Report.fromMap(map: reportMap[0]);

      emit(ProfileLoaded("report"));
    } catch (e) {
      logger.e(e);
      _report = null;
    }
  }

  void selectFocusDate(DateTime date) {
    _focusDate = date;
    emit(ProfileLoaded("focusDate"));
  }

  void selectDay(DateTime date) {
    _selectedDate = date;
    fetchSelectedReport(date);
    fetchYesterdayReport(date);
    fetchWeeklyReport(date);
  }

  Future<void> fetchSelectedReport(DateTime date) async {
    if (authCubit.state is! Authenticated) {
      return;
    }
    try {
      final reportMap = await supabase
          .from('report')
          .select()
          .eq('date', date.toIso8601String());
      if (reportMap.isEmpty) {
        _selectedReport = null;
        emit(ProfileLoaded("selectedReport"));
        return;
      }
      _selectedReport = Report.fromMap(map: reportMap[0]);

      emit(ProfileLoaded("selectedReport"));
    } catch (e) {
      logger.e(e);
      _selectedReport = null;
    }
  }

  Future<void> fetchYesterdayReport(DateTime date) async {
    if (authCubit.state is! Authenticated) {
      return;
    }
    try {
      final reportMap = await supabase
          .from('report')
          .select()
          .eq('date', date.subtract(const Duration(days: 1)).toIso8601String());
      if (reportMap.isEmpty) {
        _yesterdayReport = null;
        emit(ProfileLoaded("selectedReport"));
        return;
      }
      _yesterdayReport = Report.fromMap(map: reportMap[0]);

      emit(ProfileLoaded("selectedReport"));
    } catch (e) {
      logger.e(e);
      _yesterdayReport = null;
    }
  }

  Future<void> fetchWeeklyReport(DateTime date) async {
    if (authCubit.state is! Authenticated) {
      return;
    }
    try {
      DateTime tmpDate = date.subtract(const Duration(days: 6));
      for (int i = 0; i < 7; i++) {
        final reportMap = await supabase
            .from('report')
            .select()
            .eq('date', tmpDate.toIso8601String());
        if (reportMap.isEmpty) {
          _weeklyReport[i] = null;
        } else {
          _weeklyReport[i] = Report.fromMap(map: reportMap[0]);
        }
        tmpDate = tmpDate.add(const Duration(days: 1));
      }
      logger.d(_weeklyReport);

      emit(ProfileLoaded("selectedReport"));
    } catch (e) {
      logger.e(e);
      _selectedReport = null;
    }
  }

  @override
  Future<void> close() {
    authSubscription.cancel();
    return super.close();
  }

  Report? get getReport => _report;
  Report? get getSelectedReport => _selectedReport;
  DateTime? get getSelectedDate => _selectedDate;
  DateTime get getFocusDate => _focusDate;
  List<bool> get getSelectedType => _typeSelection;
  List<Report?> get getWeeklyReport => _weeklyReport;
  bool get getIsChallenger => authCubit.getIsChallenger;
  Report? get getYesterdayReport => _yesterdayReport;
}
