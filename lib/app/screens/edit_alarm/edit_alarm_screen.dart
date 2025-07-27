import 'package:alarm_app/app/providers/alarm_provider.dart';
import 'package:alarm_app/domain/entities/alarm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class EditAlarmScreen extends StatefulWidget {
  final AlarmEntity? alarm;

  const EditAlarmScreen({super.key, this.alarm});

  @override
  State<EditAlarmScreen> createState() => _EditAlarmScreenState();
}

class _EditAlarmScreenState extends State<EditAlarmScreen> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  late List<int> _selectedDays;
  late bool _vibrate;
  late String _sound;

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      _selectedTime = TimeOfDay.fromDateTime(widget.alarm!.time);
      _labelController = TextEditingController(text: widget.alarm!.label);
      _selectedDays = widget.alarm!.repeatDays;
      _vibrate = widget.alarm!.vibrate;
      _sound = widget.alarm!.sound;
    } else {
      _selectedTime = TimeOfDay.now();
      _labelController = TextEditingController();
      _selectedDays = [];
      _vibrate = true;
      _sound = 'default';
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
            ListTile(
              title: const Text('Sound'),
              trailing: Text(_sound),
              onTap: _pickSound,
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

  void _pickSound() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        _sound = result.files.single.path!;
      });
    }
  }

  void _saveAlarm() {
    final now = DateTime.now();
    final time = DateTime(
        now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);

    final alarm = AlarmEntity(
      id: widget.alarm?.id,
      label: _labelController.text,
      time: time,
      repeatDays: _selectedDays,
      vibrate: _vibrate,
      isEnabled: widget.alarm?.isEnabled ?? true,
      sound: _sound,
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
