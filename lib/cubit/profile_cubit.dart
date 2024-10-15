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
  DateTime? _selectedDate;

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

  void selectDay(DateTime date) {
    _selectedDate = date;
    fetchSelectedReport(date);
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

  @override
  Future<void> close() {
    authSubscription.cancel();
    return super.close();
  }

  Report? get getReport => _report;
  Report? get getSelectedReport => _selectedReport;
  DateTime? get getSelectedDate => _selectedDate;
}
