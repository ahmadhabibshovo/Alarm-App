// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// DriftDatabaseGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Alarm extends DataClass implements Insertable<Alarm> {
  final int id;
  final String label;
  final DateTime time;
  final bool isEnabled;
  final String repeatDays;
  final int snoozeDuration;
  final String sound;
  final bool vibrate;
  const Alarm(
      {required this.id,
      required this.label,
      required this.time,
      required this.isEnabled,
      required this.repeatDays,
      required this.snoozeDuration,
      required this.sound,
      required this.vibrate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['time'] = Variable<DateTime>(time);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['repeat_days'] = Variable<String>(repeatDays);
    map['snooze_duration'] = Variable<int>(snoozeDuration);
    map['sound'] = Variable<String>(sound);
    map['vibrate'] = Variable<bool>(vibrate);
    return map;
  }

  AlarmsCompanion toCompanion(bool nullToAbsent) {
    return AlarmsCompanion(
      id: Value(id),
      label: Value(label),
      time: Value(time),
      isEnabled: Value(isEnabled),
      repeatDays: Value(repeatDays),
      snoozeDuration: Value(snoozeDuration),
      sound: Value(sound),
      vibrate: Value(vibrate),
    );
  }

  factory Alarm.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Alarm(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      time: serializer.fromJson<DateTime>(json['time']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      repeatDays: serializer.fromJson<String>(json['repeatDays']),
      snoozeDuration: serializer.fromJson<int>(json['snoozeDuration']),
      sound: serializer.fromJson<String>(json['sound']),
      vibrate: serializer.fromJson<bool>(json['vibrate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'time': serializer.toJson<DateTime>(time),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'repeatDays': serializer.toJson<String>(repeatDays),
      'snoozeDuration': serializer.toJson<int>(snoozeDuration),
      'sound': serializer.toJson<String>(sound),
      'vibrate': serializer.toJson<bool>(vibrate),
    };
  }

  Alarm copyWith(
          {int? id,
          String? label,
          DateTime? time,
          bool? isEnabled,
          String? repeatDays,
          int? snoozeDuration,
          String? sound,
          bool? vibrate}) =>
      Alarm(
        id: id ?? this.id,
        label: label ?? this.label,
        time: time ?? this.time,
        isEnabled: isEnabled ?? this.isEnabled,
        repeatDays: repeatDays ?? this.repeatDays,
        snoozeDuration: snoozeDuration ?? this.snoozeDuration,
        sound: sound ?? this.sound,
        vibrate: vibrate ?? this.vibrate,
      );
  @override
  String toString() {
    return (StringBuffer('Alarm(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('time: $time, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('snoozeDuration: $snoozeDuration, ')
          ..write('sound: $sound, ')
          ..write('vibrate: $vibrate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, label, time, isEnabled, repeatDays, snoozeDuration, sound, vibrate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Alarm &&
          other.id == this.id &&
          other.label == this.label &&
          other.time == this.time &&
          other.isEnabled == this.isEnabled &&
          other.repeatDays == this.repeatDays &&
          other.snoozeDuration == this.snoozeDuration &&
          other.sound == this.sound &&
          other.vibrate == this.vibrate);
}

class AlarmsCompanion extends UpdateCompanion<Alarm> {
  final Value<int> id;
  final Value<String> label;
  final Value<DateTime> time;
  final Value<bool> isEnabled;
  final Value<String> repeatDays;
  final Value<int> snoozeDuration;
  final Value<String> sound;
  final Value<bool> vibrate;
  const AlarmsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.time = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.repeatDays = const Value.absent(),
    this.snoozeDuration = const Value.absent(),
    this.sound = const Value.absent(),
    this.vibrate = const Value.absent(),
  });
  AlarmsCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required DateTime time,
    required bool isEnabled,
    required String repeatDays,
    required int snoozeDuration,
    required String sound,
    required bool vibrate,
  })  : label = Value(label),
        time = Value(time),
        isEnabled = Value(isEnabled),
        repeatDays = Value(repeatDays),
        snoozeDuration = Value(snoozeDuration),
        sound = Value(sound),
        vibrate = Value(vibrate);
  static Insertable<Alarm> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<DateTime>? time,
    Expression<bool>? isEnabled,
    Expression<String>? repeatDays,
    Expression<int>? snoozeDuration,
    Expression<String>? sound,
    Expression<bool>? vibrate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (time != null) 'time': time,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (repeatDays != null) 'repeat_days': repeatDays,
      if (snoozeDuration != null) 'snooze_duration': snoozeDuration,
      if (sound != null) 'sound': sound,
      if (vibrate != null) 'vibrate': vibrate,
    });
  }

  AlarmsCompanion copyWith(
      {Value<int>? id,
      Value<String>? label,
      Value<DateTime>? time,
      Value<bool>? isEnabled,
      Value<String>? repeatDays,
      Value<int>? snoozeDuration,
      Value<String>? sound,
      Value<bool>? vibrate}) {
    return AlarmsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      sound: sound ?? this.sound,
      vibrate: vibrate ?? this.vibrate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (repeatDays.present) {
      map['repeat_days'] = Variable<String>(repeatDays.value);
    }
    if (snoozeDuration.present) {
      map['snooze_duration'] = Variable<int>(snoozeDuration.value);
    }
    if (sound.present) {
      map['sound'] = Variable<String>(sound.value);
    }
    if (vibrate.present) {
      map['vibrate'] = Variable<bool>(vibrate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlarmsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('time: $time, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('snoozeDuration: $snoozeDuration, ')
          ..write('sound: $sound, ')
          ..write('vibrate: $vibrate')
          ..write(')'))
        .toString();
  }
}

class $AlarmsTable extends Alarms with TableInfo<$AlarmsTable, Alarm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlarmsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  final VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
      'time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  final VerificationMeta _isEnabledMeta = const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: 'CHECK (is_enabled IN (0, 1))');
  final VerificationMeta _repeatDaysMeta = const VerificationMeta('repeatDays');
  @override
  late final GeneratedColumn<String> repeatDays = GeneratedColumn<String>(
      'repeat_days', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _snoozeDurationMeta =
      const VerificationMeta('snoozeDuration');
  @override
  late final GeneratedColumn<int> snoozeDuration = GeneratedColumn<int>(
      'snooze_duration', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  final VerificationMeta _soundMeta = const VerificationMeta('sound');
  @override
  late final GeneratedColumn<String> sound = GeneratedColumn<String>(
      'sound', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _vibrateMeta = const VerificationMeta('vibrate');
  @override
  late final GeneratedColumn<bool> vibrate = GeneratedColumn<bool>(
      'vibrate', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: 'CHECK (vibrate IN (0, 1))');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        label,
        time,
        isEnabled,
        repeatDays,
        snoozeDuration,
        sound,
        vibrate
      ];
  @override
  String get aliasedName => _alias ?? 'alarms';
  @override
  String get actualTableName => 'alarms';
  @override
  VerificationContext validateIntegrity(Insertable<Alarm> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    } else if (isInserting) {
      context.missing(_isEnabledMeta);
    }
    if (data.containsKey('repeat_days')) {
      context.handle(
          _repeatDaysMeta,
          repeatDays.isAcceptableOrUnknown(
              data['repeat_days']!, _repeatDaysMeta));
    } else if (isInserting) {
      context.missing(_repeatDaysMeta);
    }
    if (data.containsKey('snooze_duration')) {
      context.handle(
          _snoozeDurationMeta,
          snoozeDuration.isAcceptableOrUnknown(
              data['snooze_duration']!, _snoozeDurationMeta));
    } else if (isInserting) {
      context.missing(_snoozeDurationMeta);
    }
    if (data.containsKey('sound')) {
      context.handle(
          _soundMeta, sound.isAcceptableOrUnknown(data['sound']!, _soundMeta));
    } else if (isInserting) {
      context.missing(_soundMeta);
    }
    if (data.containsKey('vibrate')) {
      context.handle(_vibrateMeta,
          vibrate.isAcceptableOrUnknown(data['vibrate']!, _vibrateMeta));
    } else if (isInserting) {
      context.missing(_vibrateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Alarm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Alarm(
      id: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      label: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      time: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time'])!,
      isEnabled: attachedDatabase.options.types
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      repeatDays: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}repeat_days'])!,
      snoozeDuration: attachedDatabase.options.types.read(
          DriftSqlType.int, data['${effectivePrefix}snooze_duration'])!,
      sound: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}sound'])!,
      vibrate: attachedDatabase.options.types
          .read(DriftSqlType.bool, data['${effectivePrefix}vibrate'])!,
    );
  }

  @override
  $AlarmsTable createAlias(String alias) {
    return $AlarmsTable(attachedDatabase, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $AlarmsTable alarms = $AlarmsTable(this);
  @override
  Iterable<TableInfo<Table, dynamic>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, dynamic>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [alarms];
}
