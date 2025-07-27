import 'package:flutter/material.dart';
import 'package:alarm_app/domain/entities/alarm.dart';
import 'package:alarm_app/data/datasources/alarm_helper.dart';
import 'package:alarm_app/app/services/alarm_service.dart';

class AlarmProvider with ChangeNotifier {
  final AlarmHelper _alarmHelper = AlarmHelper();
  List<Alarm> _alarms = [];
  final AlarmService _alarmService = AlarmService();


  List<Alarm> get alarms => _alarms;

  Future<void> loadAlarms() async {
    _alarms = await _alarmHelper.getAlarms();
    notifyListeners();
  }

  Future<void> addAlarm(Alarm alarm) async {
    await _alarmHelper.insertAlarm(alarm);
    await _alarmService.scheduleAlarm(alarm);
    await loadAlarms();
  }

  Future<void> updateAlarm(Alarm alarm) async {
    await _alarmHelper.updateAlarm(alarm);
    if (alarm.isEnabled) {
      await _alarmService.scheduleAlarm(alarm);
    } else {
      await _alarmService.cancelAlarm(alarm.id!);
    }
    await loadAlarms();
  }

  Future<void> deleteAlarm(int id) async {
    await _alarmHelper.deleteAlarm(id);
    await _alarmService.cancelAlarm(id);
    await loadAlarms();
  }
}
