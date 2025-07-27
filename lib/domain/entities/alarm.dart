import 'package:alarm_app/data/datasources/app_database.dart';
import 'package:drift/drift.dart';

class AlarmEntity {
  int? id;
  String label;
  DateTime time;
  bool isEnabled;
  List<int> repeatDays;
  int snoozeDuration;
  String sound;
  bool vibrate;

  AlarmEntity({
    this.id,
    required this.label,
    required this.time,
    this.isEnabled = true,
    required this.repeatDays,
    this.snoozeDuration = 5,
    this.sound = 'default',
    this.vibrate = true,
  });

  factory AlarmEntity.fromAlarm(Alarm alarm) {
    return AlarmEntity(
      id: alarm.id,
      label: alarm.label,
      time: alarm.time,
      isEnabled: alarm.isEnabled,
      repeatDays: alarm.repeatDays.split(',').where((s) => s.isNotEmpty).map(int.parse).toList(),
      snoozeDuration: alarm.snoozeDuration,
      sound: alarm.sound,
      vibrate: alarm.vibrate,
    );
  }

  AlarmsCompanion toCompanion() {
    return AlarmsCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      label: Value(label),
      time: Value(time),
      isEnabled: Value(isEnabled),
      repeatDays: Value(repeatDays.join(',')),
      snoozeDuration: Value(snoozeDuration),
      sound: Value(sound),
      vibrate: Value(vibrate),
    );
  }
}
