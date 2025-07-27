import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import '../services/simple_notification_service.dart';
import 'add_edit_alarm_screen.dart';
import 'alarm_ring_screen.dart';
import 'alarm_setup_screen.dart';

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({super.key});

  @override
  State<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  final AlarmService _alarmService = AlarmService.instance;
  PermissionStatus _exactAlarmPermissionStatus = PermissionStatus.granted;

  @override
  void initState() {
    super.initState();
    _checkExactAlarmPermission();
  }

  void _checkExactAlarmPermission() async {
    final currentStatus = await _alarmService.checkExactAlarmPermission();
    setState(() {
      _exactAlarmPermissionStatus = currentStatus;
    });
  }

  Future<void> _requestPermission() async {
    final granted = await _alarmService.requestExactAlarmPermission();
    if (granted) {
      setState(() {
        _exactAlarmPermissionStatus = PermissionStatus.granted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarms'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: StreamBuilder<List<AlarmModel>>(
        stream: Stream.periodic(const Duration(seconds: 1))
            .map((_) => AlarmService.instance.alarms),
        builder: (context, snapshot) {
          final alarms = snapshot.data ?? AlarmService.instance.alarms;

          if (alarms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No alarms set',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: alarms.length,
            itemBuilder: (context, index) {
              final alarm = alarms[index];
              return _AlarmListTile(
                alarm: alarm,
                onToggle: (isEnabled) => _toggleAlarm(alarm.id, isEnabled),
                onTap: () => _navigateToEditAlarm(alarm),
                onDelete: () => _deleteAlarm(alarm.id),
              );
            },
          );
        },
      ),
      floatingActionButton: _exactAlarmPermissionStatus.isGranted
          ? _buildFAB()
          : FloatingActionButton(
              onPressed: null,
              backgroundColor: Theme.of(context).disabledColor,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          onPressed: _testNotification,
          heroTag: "notification",
          backgroundColor: Colors.purple,
          child: const Icon(Icons.notifications),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          onPressed: _testAlarmRingScreen,
          heroTag: "test",
          backgroundColor: Colors.orange,
          child: const Icon(Icons.play_arrow),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AlarmSetupScreen(),
              ),
            );
            if (result == true) {
              setState(() {});
            }
          },
          heroTag: "add",
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  void _testNotification() async {
    try {
      await SimpleNotificationService.showAlarmNotification(
        title: 'Test Alarm',
        body: 'This is a test notification for background alarm functionality',
        alarmId: 'test_notification',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _testAlarmRingScreen() {
    final testAlarm = AlarmModel(
      id: 'test',
      hour: DateTime.now().hour,
      minute: DateTime.now().minute,
      label: 'Test Alarm',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AlarmRingScreen(alarm: testAlarm),
        fullscreenDialog: true,
      ),
    );
  }

  void _navigateToEditAlarm(AlarmModel alarm) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditAlarmScreen(alarm: alarm),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _toggleAlarm(String alarmId, bool isEnabled) async {
    await _alarmService.toggleAlarm(alarmId, isEnabled);
    setState(() {});
  }

  Future<void> _deleteAlarm(String alarmId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alarm'),
        content: const Text('Are you sure you want to delete this alarm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _alarmService.deleteAlarm(alarmId);
      setState(() {});
    }
  }
}

class _AlarmListTile extends StatelessWidget {
  final AlarmModel alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AlarmListTile({
    required this.alarm,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          alarm.timeString,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: alarm.isEnabled
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (alarm.label.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                alarm.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: alarm.isEnabled
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              alarm.repeatString,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: alarm.isEnabled
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _testAlarm(context),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Test in 5s'),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            Switch(
              value: alarm.isEnabled,
              onChanged: onToggle,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _testAlarm(BuildContext context) async {
    try {
      await AlarmService.instance.testAlarmNow(alarm);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test alarm scheduled for 5 seconds from now'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error testing alarm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
