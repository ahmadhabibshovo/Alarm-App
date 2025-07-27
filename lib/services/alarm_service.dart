import 'dart:isolate';
import 'dart:ui';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/alarm_model.dart';
import 'notification_service.dart';

class AlarmService {
  AlarmService._();
  static final AlarmService instance = AlarmService._();

  List<AlarmModel> _alarms = [];
  List<AlarmModel> get alarms => List.unmodifiable(_alarms);

  Future<void> initialize() async {
    try {
      await AndroidAlarmManager.initialize();
      await _loadAlarms();
      print('AlarmService initialized successfully');
    } catch (e) {
      print('Error initializing AlarmService: $e');
    }
  }

  Future<void> _loadAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmsJson = prefs.getStringList('alarms') ?? [];
      _alarms = alarmsJson
          .map((json) => AlarmModel.fromJson(jsonDecode(json)))
          .toList();
      print('Loaded ${_alarms.length} alarms');
    } catch (e) {
      print('Error loading alarms: $e');
      _alarms = [];
    }
  }

  Future<void> _saveAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmsJson =
          _alarms.map((alarm) => jsonEncode(alarm.toJson())).toList();
      await prefs.setStringList('alarms', alarmsJson);
      print('Saved ${_alarms.length} alarms');
    } catch (e) {
      print('Error saving alarms: $e');
    }
  }

  Future<void> addAlarm(AlarmModel alarm) async {
    _alarms.add(alarm);
    await _saveAlarms();
    await _scheduleAlarm(alarm);
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    final index = _alarms.indexWhere((a) => a.id == alarm.id);
    if (index != -1) {
      _alarms[index] = alarm;
      await _saveAlarms();
      await _cancelAlarm(alarm.id);

      if (alarm.isEnabled) {
        await _scheduleAlarm(alarm);
      }
    }
  }

  Future<void> deleteAlarm(String id) async {
    _alarms.removeWhere((alarm) => alarm.id == id);
    await _saveAlarms();
    await _cancelAlarm(id);
  }

  Future<void> toggleAlarm(String id, bool isEnabled) async {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      final alarm = _alarms[index].copyWith(isEnabled: isEnabled);
      _alarms[index] = alarm;
      await _saveAlarms();

      if (isEnabled) {
        await _scheduleAlarm(alarm);
      } else {
        await _cancelAlarm(id);
      }
    }
  }

  Future<void> _scheduleAlarm(AlarmModel alarm) async {
    if (!alarm.isEnabled) return;

    try {
      final now = DateTime.now();
      final alarmDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        alarm.hour,
        alarm.minute,
      );

      // If alarm time is in the past, schedule for next day
      final scheduledDateTime = alarmDateTime.isBefore(now)
          ? alarmDateTime.add(const Duration(days: 1))
          : alarmDateTime;

      // Schedule the alarm using AndroidAlarmManager
      final alarmId =
          alarm.id.hashCode.abs() % 2147483647; // Ensure positive int
      await AndroidAlarmManager.oneShotAt(
        scheduledDateTime,
        alarmId,
        _alarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        alarmClock: true,
        allowWhileIdle: true,
        params: {
          'alarmId': alarm.id,
          'hour': alarm.hour,
          'minute': alarm.minute,
          'label': alarm.label,
          'isRepeating': alarm.repeatingDays.isNotEmpty,
          'repeatingDays': alarm.repeatingDays,
        },
      );

      // Also schedule a notification as a backup
      await NotificationService.instance.scheduleAlarmNotification(
        id: alarm.id,
        title: 'Alarm',
        body: alarm.label.isEmpty ? 'Time to wake up!' : alarm.label,
        scheduledTime: scheduledDateTime,
      );

      print('Alarm scheduled for ${scheduledDateTime.toString()}');
    } catch (e) {
      print('Error scheduling alarm: $e');
    }
  }

  Future<void> _cancelAlarm(String id) async {
    try {
      final alarmId = id.hashCode.abs() % 2147483647;
      await AndroidAlarmManager.cancel(alarmId);
      await NotificationService.instance.cancelNotification(id);
      print('Cancelled alarm: $id');
    } catch (e) {
      print('Error cancelling alarm: $e');
    }
  }

  // This static method will be called in a separate isolate when the alarm fires
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback(
      int id, Map<String, dynamic> params) async {
    print(
        'Alarm ${params['alarmId']} fired: ${params['label']} Time: ${params['hour']}:${params['minute']}');

    try {
      // Show notification - this works in background isolate
      await _showAlarmNotificationInBackground(params);

      // Reschedule if repeating
      if (params['isRepeating'] == true) {
        await _rescheduleRepeatingAlarmCallback(id, params);
      }

      // Send message to UI isolate
      await _sendMessageToUiIsolate(params['alarmId']);

      print('Alarm ${params['alarmId']} processed successfully');
    } catch (e) {
      print('Error in alarm callback: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _showAlarmNotificationInBackground(
      Map<String, dynamic> params) async {
    try {
      // Use platform channel directly since NotificationService might not be available in background
      const MethodChannel channel = MethodChannel('alarm_notifications');
      await channel.invokeMethod('showAlarmNotification', {
        'id': params['alarmId'],
        'title': 'Alarm',
        'body': params['label'] ?? 'Time to wake up!',
      });
      print('Background notification shown');
    } catch (e) {
      print('Platform channel not available in background isolate: $e');
      // Fallback: try to send notification request to UI isolate
      final SendPort? sendPort =
          IsolateNameServer.lookupPortByName('notification_isolate');
      if (sendPort != null) {
        sendPort.send({
          'type': 'show_notification',
          'id': params['alarmId'],
          'title': 'Alarm',
          'body': params['label'] ?? 'Time to wake up!',
        });
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _rescheduleRepeatingAlarmCallback(
      int id, Map<String, dynamic> params) async {
    if (params['isRepeating'] == true) {
      final List<int> repeatingDays = List<int>.from(params['repeatingDays']);

      if (repeatingDays.isNotEmpty) {
        final now = DateTime.now();
        final nextAlarmDate = _getNextAlarmDate(
            now, repeatingDays, params['hour'], params['minute']);

        // Reschedule for next occurrence
        await AndroidAlarmManager.oneShotAt(
          nextAlarmDate,
          id,
          _alarmCallback,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
          alarmClock: true,
          allowWhileIdle: true,
          params: params,
        );

        print(
            'Successfully rescheduled alarm ${params['alarmId']} for $nextAlarmDate (background)');
        print('Repeating alarm ${params['alarmId']} rescheduled');
      }
    }
  }

  static DateTime _getNextAlarmDate(
    DateTime now,
    List<int> repeatingDays,
    int hour,
    int minute,
  ) {
    // Convert to 0-6 format where 0 is Monday, 6 is Sunday
    final currentWeekday = (now.weekday % 7);

    // Sort the repeating days
    repeatingDays.sort();

    // Find the next day to schedule
    int daysToAdd = 1; // Default to tomorrow

    for (final day in repeatingDays) {
      final normalizedDay =
          (day + 1) % 7; // Convert from Sunday=0 to Monday=0 format
      if (normalizedDay > currentWeekday ||
          (normalizedDay == currentWeekday &&
              (hour > now.hour || (hour == now.hour && minute > now.minute)))) {
        daysToAdd = (normalizedDay - currentWeekday);
        break;
      }
    }

    // If we've gone through all days and none is greater than current,
    // take the first day from the list and add days until we reach it
    if (daysToAdd == 1 && repeatingDays.isNotEmpty) {
      final normalizedFirstDay = (repeatingDays[0] + 1) % 7;
      daysToAdd = (normalizedFirstDay - currentWeekday + 7) % 7;
      if (daysToAdd == 0) daysToAdd = 7; // Full week cycle
    }

    return DateTime(
      now.year,
      now.month,
      now.day + daysToAdd,
      hour,
      minute,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _sendMessageToUiIsolate(String alarmId) async {
    final SendPort? sendPort = IsolateNameServer.lookupPortByName('isolate');
    if (sendPort != null) {
      sendPort.send({
        'type': 'alarm_fired',
        'alarmId': alarmId,
      });
      print('Sent alarm_fired message to UI isolate for alarm $alarmId');
    } else {
      print('No send port available');
    }
  }

  String generateAlarmId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Method to test alarm immediately (for debugging)
  Future<void> testAlarmNow(AlarmModel alarm) async {
    final testTime = DateTime.now().add(const Duration(seconds: 5));
    final alarmId = alarm.id.hashCode;

    try {
      await AndroidAlarmManager.oneShotAt(
        testTime,
        alarmId,
        _alarmCallback,
        alarmClock: true,
        allowWhileIdle: true,
        exact: true,
        wakeup: true,
        params: {'alarmId': alarm.id},
      );

      developer.log(
          'Test alarm ${alarm.id} scheduled for $testTime (5 seconds from now)');
    } catch (e) {
      developer.log('Error scheduling test alarm: $e');
      rethrow;
    }
  }

  // Request exact alarm permission
  Future<bool> requestExactAlarmPermission() async {
    try {
      if (await Permission.scheduleExactAlarm.isDenied) {
        final status = await Permission.scheduleExactAlarm.request();
        return status == PermissionStatus.granted;
      }
      return true; // Already granted
    } catch (e) {
      developer.log('Error requesting exact alarm permission: $e');
      return false;
    }
  }

  // Check exact alarm permission status
  Future<PermissionStatus> checkExactAlarmPermission() async {
    try {
      return await Permission.scheduleExactAlarm.status;
    } catch (e) {
      developer.log('Error checking exact alarm permission: $e');
      return PermissionStatus.denied;
    }
  }
}
