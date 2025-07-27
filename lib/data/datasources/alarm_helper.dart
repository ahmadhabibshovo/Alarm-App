import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:alarm_app/domain/entities/alarm.dart';

class AlarmHelper {
  static final AlarmHelper _instance = AlarmHelper._internal();
  factory AlarmHelper() => _instance;
  AlarmHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'alarms.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE alarms(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            label TEXT,
            time TEXT,
            isEnabled INTEGER,
            repeatDays TEXT,
            snoozeDuration INTEGER,
            sound TEXT,
            vibrate INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertAlarm(Alarm alarm) async {
    final db = await database;
    return await db.insert('alarms', alarm.toMap());
  }

  Future<List<Alarm>> getAlarms() async {
    final db = await database;
    final maps = await db.query('alarms');
    return List.generate(maps.length, (i) {
      return Alarm.fromMap(maps[i]);
    });
  }

  Future<int> updateAlarm(Alarm alarm) async {
    final db = await database;
    return await db.update(
      'alarms',
      alarm.toMap(),
      where: 'id = ?',
      whereArgs: [alarm.id],
    );
  }

  Future<int> deleteAlarm(int id) async {
    final db = await database;
    return await db.delete(
      'alarms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
