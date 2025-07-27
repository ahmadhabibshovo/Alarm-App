import 'package:alarm_app/app/providers/alarm_provider.dart';
import 'package:alarm_app/domain/entities/alarm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EditAlarmScreen extends StatefulWidget {
  final Alarm? alarm;

  const EditAlarmScreen({super.key, this.alarm});

  @override
  State<EditAlarmScreen> createState() => _EditAlarmScreenState();
}

class _EditAlarmScreenState extends State<EditAlarmScreen> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  late List<int> _selectedDays;
  late bool _vibrate;

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      _selectedTime = TimeOfDay.fromDateTime(widget.alarm!.time);
      _labelController = TextEditingController(text: widget.alarm!.label);
      _selectedDays = widget.alarm!.repeatDays;
      _vibrate = widget.alarm!.vibrate;
    } else {
      _selectedTime = TimeOfDay.now();
      _labelController = TextEditingController();
      _selectedDays = [];
      _vibrate = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'Add Alarm' : 'Edit Alarm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAlarm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Time'),
              trailing: Text(
                _selectedTime.format(context),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              onTap: _pickTime,
            ),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
              ),
            ),
            const SizedBox(height: 20),
            _buildDaySelector(),
            SwitchListTile(
              title: const Text('Vibrate'),
              value: _vibrate,
              onChanged: (value) {
                setState(() {
                  _vibrate = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return ToggleButtons(
      isSelected: List.generate(7, (index) => _selectedDays.contains(index)),
      onPressed: (index) {
        setState(() {
          if (_selectedDays.contains(index)) {
            _selectedDays.remove(index);
          } else {
            _selectedDays.add(index);
          }
        });
      },
      children: List.generate(7, (index) => Text(days[index])),
    );
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _saveAlarm() {
    final now = DateTime.now();
    final time = DateTime(
        now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);

    final alarm = Alarm(
      id: widget.alarm?.id,
      label: _labelController.text,
      time: time,
      repeatDays: _selectedDays,
      vibrate: _vibrate,
      isEnabled: widget.alarm?.isEnabled ?? true,
    );

    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
    if (widget.alarm == null) {
      alarmProvider.addAlarm(alarm);
    } else {
      alarmProvider.updateAlarm(alarm);
    }

    Navigator.pop(context);
  }
}
