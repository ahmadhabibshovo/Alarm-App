import 'package:alarm_app/app/providers/alarm_provider.dart';
import 'package:alarm_app/app/screens/edit_alarm/edit_alarm_screen.dart';
import 'package:alarm_app/app/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<AlarmProvider>(context, listen: false).loadAlarms();
  }

  @override
  Widget build(BuildContext context) {
    final alarmProvider = Provider.of<AlarmProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: alarmProvider.alarms.isEmpty
          ? const Center(
              child: Text('No alarms yet.'),
            )
          : ListView.builder(
              itemCount: alarmProvider.alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarmProvider.alarms[index];
                return ListTile(
                  title: Text(
                    DateFormat('h:mm a').format(alarm.time),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  subtitle: Text(alarm.label),
                  trailing: Switch(
                    value: alarm.isEnabled,
                    onChanged: (value) {
                      alarm.isEnabled = value;
                      alarmProvider.updateAlarm(alarm);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAlarmScreen(alarm: alarm),
                      ),
                    ).then((_) => alarmProvider.loadAlarms());
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditAlarmScreen(),
            ),
          ).then((_) => alarmProvider.loadAlarms());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
