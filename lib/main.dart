import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'services/alarm_service.dart';
import 'services/notification_service.dart';
import 'screens/alarm_list_screen.dart';
import 'screens/alarm_ring_screen.dart';
import 'models/alarm_model.dart';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
ReceivePort port = ReceivePort();

/// Global navigator key for navigation from background isolates
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data first
  tz.initializeTimeZones();

  // Register the UI isolate's SendPort to allow for communication from the
  // background isolate.
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );

  // Request notification permissions
  await _requestPermissions();

  // Initialize notification service first
  await NotificationService.instance.initialize();

  // Initialize alarm service
  await AlarmService.instance.initialize();

  runApp(const AlarmClockApp());
}

Future<void> _requestPermissions() async {
  try {
    // Request notification permission
    final notificationStatus = await Permission.notification.request();
    print('Notification permission: $notificationStatus');

    // Request exact alarm permission for Android 12+
    if (await Permission.scheduleExactAlarm.isDenied) {
      final alarmStatus = await Permission.scheduleExactAlarm.request();
      print('Exact alarm permission: $alarmStatus');

      if (alarmStatus.isPermanentlyDenied) {
        print('Exact alarm permission permanently denied, opening settings');
        await openAppSettings();
      }
    }
  } catch (e) {
    print('Error requesting permissions: $e');
  }
}

/// Example app for Alarm Clock.
class AlarmClockApp extends StatefulWidget {
  const AlarmClockApp({super.key});

  @override
  State<AlarmClockApp> createState() => _AlarmClockAppState();
}

class _AlarmClockAppState extends State<AlarmClockApp> {
  @override
  void initState() {
    super.initState();

    // Listen for messages from background isolate
    port.listen((dynamic data) {
      print('Received message from background isolate: $data');
      if (data is Map && data['type'] == 'alarm_fired') {
        print('Processing alarm_fired message for alarm: ${data['alarmId']}');
        _handleAlarmFired(data['alarmId'] as String);
      }
    });

    // Setup notification action handlers
    NotificationService.instance
        .setOnNotificationTap(_handleAlarmNotificationTap);
  }

  void _handleAlarmNotificationTap(String? payload) {
    if (payload != null) {
      _handleAlarmFired(payload);
    }
  }

  void _handleAlarmFired(String alarmId) {
    print('Handling alarm fired: $alarmId');

    // Find the alarm that fired
    final alarms = AlarmService.instance.alarms;
    AlarmModel? alarm;

    try {
      alarm = alarms.firstWhere((a) => a.id == alarmId);
    } catch (e) {
      // Create a default alarm if not found
      alarm = AlarmModel(
        id: alarmId,
        hour: DateTime.now().hour,
        minute: DateTime.now().minute,
        label: 'Alarm',
        isEnabled: true,
        repeatingDays: [],
      );
    }

    print(
        'Found alarm: ${alarm.hour}:${alarm.minute.toString().padLeft(2, '0')} - ${alarm.label}');

    // Navigate to alarm ring screen
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      print('Navigating to alarm ring screen');
      navigator.push(
        MaterialPageRoute(
          builder: (context) => AlarmRingScreen(alarm: alarm!),
          fullscreenDialog: true,
        ),
      );
    } else {
      print('ERROR: Navigator is null, cannot show alarm ring screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Alarm Clock',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6750A4),
      ),
      home: const AlarmListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
