import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class SimpleNotificationService {
  static const platform = MethodChannel('alarm_notifications');

  static Future<void> showAlarmNotification({
    required String title,
    required String body,
    required String alarmId,
  }) async {
    try {
      await platform.invokeMethod('showAlarmNotification', {
        'title': title,
        'body': body,
        'alarmId': alarmId,
      });
      developer.log('Alarm notification sent via platform channel');
    } on PlatformException catch (e) {
      developer.log('Failed to show notification: ${e.message}');
    }
  }

  static Future<void> cancelNotification(String alarmId) async {
    try {
      await platform.invokeMethod('cancelNotification', {
        'alarmId': alarmId,
      });
    } on PlatformException catch (e) {
      developer.log('Failed to cancel notification: ${e.message}');
    }
  }

  static Future<void> scheduleNativeAlarm({
    required String alarmId,
    required String label,
    required DateTime triggerTime,
  }) async {
    try {
      await platform.invokeMethod('scheduleNativeAlarm', {
        'alarmId': alarmId,
        'label': label,
        'triggerTime': triggerTime.millisecondsSinceEpoch,
      });
      developer.log('Native alarm scheduled for $alarmId at $triggerTime');
    } on PlatformException catch (e) {
      developer.log('Failed to schedule native alarm: ${e.message}');
    }
  }

  static Future<void> cancelNativeAlarm(String alarmId) async {
    try {
      await platform.invokeMethod('cancelNativeAlarm', {
        'alarmId': alarmId,
      });
      developer.log('Native alarm cancelled for $alarmId');
    } on PlatformException catch (e) {
      developer.log('Failed to cancel native alarm: ${e.message}');
    }
  }
}
