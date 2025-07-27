import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Define notification channels
  static const String _alarmChannelId = 'alarm_channel';
  static const String _alarmChannelName = 'Alarm Notifications';
  static const String _alarmChannelDescription =
      'Shows notifications for alarms';

  Function(String? payload)? _onNotificationTap;

  Future<void> initialize() async {
    try {
      // Define initialization settings for Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (_onNotificationTap != null) {
            _onNotificationTap!(response.payload);
          }
        },
      );

      // Create notification channels for Android
      await _createNotificationChannels();
      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing NotificationService: $e');
    }
  }

  void setOnNotificationTap(Function(String? payload) onTap) {
    _onNotificationTap = onTap;
  }

  Future<void> _createNotificationChannels() async {
    try {
      const AndroidNotificationChannel alarmChannel =
          AndroidNotificationChannel(
        _alarmChannelId,
        _alarmChannelName,
        description: _alarmChannelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
        enableLights: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(alarmChannel);

      print('Notification channels created');
    } catch (e) {
      print('Error creating notification channels: $e');
    }
  }

  // Show a notification for an alarm
  Future<void> showAlarmNotification({
    required String id,
    required String title,
    required String body,
  }) async {
    try {
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _alarmChannelId,
          _alarmChannelName,
          channelDescription: _alarmChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          ongoing: true,
        ),
      );

      final notificationId =
          id.hashCode.abs() % 2147483647; // Ensure positive int
      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: id,
      );

      print('Alarm notification shown for ID: $id');
    } catch (e) {
      print('Error showing alarm notification: $e');
    }
  }

  // Schedule a notification for an alarm
  Future<void> scheduleAlarmNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _alarmChannelId,
          _alarmChannelName,
          channelDescription: _alarmChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          ongoing: true,
        ),
      );

      final notificationId =
          id.hashCode.abs() % 2147483647; // Ensure positive int
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: id,
      );

      print('Alarm notification scheduled for: $scheduledTime');
    } catch (e) {
      print('Error scheduling alarm notification: $e');
    }
  }

  // Cancel a notification
  Future<void> cancelNotification(String id) async {
    try {
      final notificationId = id.hashCode.abs() % 2147483647;
      await _flutterLocalNotificationsPlugin.cancel(notificationId);
      print('Cancelled notification for ID: $id');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('All notifications cancelled');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }
}
