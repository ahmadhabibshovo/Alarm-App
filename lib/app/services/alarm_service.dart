import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:alarm_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:alarm_app/domain/entities/alarm.dart';
import 'package:alarm_app/app/screens/alarm/alarm_screen.dart';
import 'package:alarm_app/data/datasources/app_database.dart';

class AlarmService {
  final AppDatabase _db = AppDatabase();

  void scheduleAlarm(AlarmEntity alarm) async {
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(now.year, now.month, now.day,
        alarm.time.hour, alarm.time.minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      alarm.id!,
      _callback,
      exact: true,
      wakeup: true,
      alarmClock: true,
      params: {'sound': alarm.sound},
    );
  }

  void cancelAlarm(int id) async {
    await AndroidAlarmManager.cancel(id);
  }

  @pragma('vm:entry-point')
  static void _callback(int id, Map<String, dynamic> params) async {
    final sound = params['sound'];
    // This is where the alarm triggers.
    // We'll show a notification and a full-screen UI.
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Channel',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      fullScreenIntent: true,
      sound: sound == 'default'
          ? const RawResourceAndroidNotificationSound('default')
          : UriAndroidNotificationSound(sound),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id,
      'Alarm',
      'Time to wake up!',
      platformChannelSpecifics,
      payload: id.toString(),
    );

    runApp(AlarmScreen(alarmId: id));
  }
}
