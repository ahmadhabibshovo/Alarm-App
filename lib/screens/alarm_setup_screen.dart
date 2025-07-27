import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';

class AlarmSetupScreen extends StatefulWidget {
  final AlarmModel? alarm;

  const AlarmSetupScreen({super.key, this.alarm});

  @override
  State<AlarmSetupScreen> createState() => _AlarmSetupScreenState();
}

class _AlarmSetupScreenState extends State<AlarmSetupScreen> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  late bool _isEnabled;
  late List<int> _repeatingDays;

  @override
  void initState() {
    super.initState();

    if (widget.alarm != null) {
      _selectedTime = TimeOfDay(
        hour: widget.alarm!.hour,
        minute: widget.alarm!.minute,
      );
      _labelController = TextEditingController(text: widget.alarm!.label);
      _isEnabled = widget.alarm!.isEnabled;
      _repeatingDays = List.from(widget.alarm!.repeatingDays);
    } else {
      final now = DateTime.now();
      _selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
      _labelController = TextEditingController();
      _isEnabled = true;
      _repeatingDays = [];
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _saveAlarm() async {
    final alarm = AlarmModel(
      id: widget.alarm?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      label: _labelController.text,
      isEnabled: _isEnabled,
      repeatingDays: _repeatingDays,
    );

    if (widget.alarm != null) {
      await AlarmService.instance.updateAlarm(alarm);
    } else {
      await AlarmService.instance.addAlarm(alarm);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm != null ? 'Edit Alarm' : 'Add Alarm'),
        actions: [
          TextButton(
            onPressed: _saveAlarm,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time picker
            Card(
              child: ListTile(
                title: const Text('Time'),
                subtitle: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = time;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Label input
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Alarm Label',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Enable/Disable switch
            SwitchListTile(
              title: const Text('Enabled'),
              value: _isEnabled,
              onChanged: (value) {
                setState(() {
                  _isEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
