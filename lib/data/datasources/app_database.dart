import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Alarms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text()();
  DateTimeColumn get time => dateTime()();
  BoolColumn get isEnabled => boolean()();
  TextColumn get repeatDays => text()();
  IntColumn get snoozeDuration => integer()();
  TextColumn get sound => text()();
  BoolColumn get vibrate => boolean()();
}

@DriftDatabase(tables: [Alarms])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Alarm>> get allAlarms => select(alarms).get();
  Future<int> insertAlarm(AlarmsCompanion alarm) => into(alarms).insert(alarm);
  Future<bool> updateAlarm(AlarmsCompanion alarm) => update(alarms).replace(alarm);
  Future<int> deleteAlarm(int id) => (delete(alarms)..where((t) => t.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
