import 'package:alarm_app/data/datasources/app_database.dart';
import 'package:flutter/material.dart';
import 'package:alarm_app/domain/entities/alarm.dart';
import 'package:alarm_app/app/services/alarm_service.dart';

class AlarmProvider with ChangeNotifier {
  final AppDatabase _db = AppDatabase();
  List<AlarmEntity> _alarms = [];
  final AlarmService _alarmService = AlarmService();

  List<AlarmEntity> get alarms => _alarms;

  Future<void> loadAlarms() async {
    final alarmList = await _db.allAlarms;
    _alarms = alarmList.map((alarm) => AlarmEntity.fromAlarm(alarm)).toList();
    notifyListeners();
  }

  Future<void> addAlarm(AlarmEntity alarm) async {
    await _db.insertAlarm(alarm.toCompanion());
    await _alarmService.scheduleAlarm(alarm);
    await loadAlarms();
  }

  Future<void> updateAlarm(AlarmEntity alarm) async {
    await _db.updateAlarm(alarm.toCompanion());
    if (alarm.isEnabled) {
      await _alarmService.scheduleAlarm(alarm);
    } else {
      await _alarmService.cancelAlarm(alarm.id!);
    }
    await loadAlarms();
  }

  Future<void> deleteAlarm(int id) async {
    await _db.deleteAlarm(id);
    await _alarmService.cancelAlarm(id);
    await loadAlarms();
  }
}
