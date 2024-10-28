import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();

  factory PreferencesService() {
    return _instance;
  }

  PreferencesService._internal();

  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // 값 저장
  Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  Future<void> setAlarmTimes(List<TimeOfDay> alarmTimes) async {
    List<String> timesAsString =
        alarmTimes.map((time) => "${time.hour}:${time.minute}").toList();
    await _preferences?.setStringList('alarmTimes', timesAsString);
  }

  // 값 읽기
  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  String? getString(String key) {
    return _preferences?.getString(key);
  }

  Future<List<TimeOfDay>> getAlarmTimes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? timesAsString = prefs.getStringList('alarmTimes');
    if (timesAsString == null) return [];

    return timesAsString.map((timeStr) {
      List<String> parts = timeStr.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    }).toList();
  }

  // 값 삭제
  Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }
}
