import 'package:alarm_app/app/providers/alarm_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:alarm_app/main.dart';

class AlarmScreen extends StatefulWidget {
  final int alarmId;

  const AlarmScreen({super.key, required this.alarmId});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  @override
  void initState() {
    super.initState();
    _startVibration();
    _playSound();
  }

  void _startVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 10000, amplitude: 255);
    }
  }

  void _playSound() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Channel',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('default'),
      playSound: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      widget.alarmId,
      'Alarm',
      'Time to wake up!',
      platformChannelSpecifics,
      payload: widget.alarmId.toString(),
    );
  }

  void _snooze() {
    Vibration.cancel();
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    // Snooze logic here
    Navigator.pop(context);
  }

  void _dismiss() {
    Vibration.cancel();
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    // Dismiss logic here
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ALARM!',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _snooze,
                child: const Text('Snooze'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _dismiss,
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
