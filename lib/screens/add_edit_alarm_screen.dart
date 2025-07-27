import 'package:flutter/material.dart';

import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import '../services/alarm_sound_service.dart';

class AddEditAlarmScreen extends StatefulWidget {
  final AlarmModel? alarm;

  const AddEditAlarmScreen({super.key, this.alarm});

  @override
  State<AddEditAlarmScreen> createState() => _AddEditAlarmScreenState();
}

class _AddEditAlarmScreenState extends State<AddEditAlarmScreen> {
  final AlarmService _alarmService = AlarmService.instance;
  final _labelController = TextEditingController();

  late int _hour;
  late int _minute;
  late List<bool> _repeatDays;
  late bool _vibrate;
  late String _soundPath;

  @override
  void initState() {
    super.initState();

    if (widget.alarm != null) {
      _hour = widget.alarm!.hour;
      _minute = widget.alarm!.minute;
      _labelController.text = widget.alarm!.label;
      // Convert integer list of active days to boolean list
      _repeatDays = List.filled(7, false);
      for (int day in widget.alarm!.repeatingDays) {
        if (day >= 0 && day < 7) {
          _repeatDays[day] = true;
        }
      }
      _vibrate = widget.alarm!.vibrate;
      _soundPath = widget.alarm!.soundPath;
    } else {
      final now = DateTime.now();
      _hour = now.hour;
      _minute = now.minute;
      _repeatDays = List.filled(7, false);
      _vibrate = true;
      _soundPath = 'default';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm != null ? 'Edit Alarm' : 'Add Alarm'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveAlarm,
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimePicker(),
            const SizedBox(height: 24),
            _buildLabelSection(),
            const SizedBox(height: 24),
            _buildRepeatSection(),
            const SizedBox(height: 24),
            _buildSoundSection(),
            const SizedBox(height: 24),
            _buildVibrateSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              _formatTime(_hour, _minute),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectTime,
              child: const Text('Change Time'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Label',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                hintText: 'Alarm label',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatSection() {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Repeat',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                return _DayToggleButton(
                  day: dayNames[index],
                  isSelected: _repeatDays[index],
                  onTap: () {
                    setState(() {
                      _repeatDays[index] = !_repeatDays[index];
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _repeatDays = List.filled(7, false);
                    });
                  },
                  child: const Text('Never'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _repeatDays = [
                        true,
                        true,
                        true,
                        true,
                        true,
                        false,
                        false
                      ];
                    });
                  },
                  child: const Text('Weekdays'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _repeatDays = List.filled(7, true);
                    });
                  },
                  child: const Text('Every day'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundSection() {
    return Card(
      child: ListTile(
        title: const Text('Alarm Sound'),
        subtitle: Text(_getSoundDisplayName(_soundPath)),
        trailing: const Icon(Icons.chevron_right),
        onTap: _showSoundSelectionDialog,
      ),
    );
  }

  String _getSoundDisplayName(String soundPath) {
    if (soundPath == 'default' || soundPath.isEmpty) {
      return 'Default';
    }

    // Find the display name from available sounds
    for (final sound in AlarmSoundService.availableSounds) {
      if (sound['path'] == soundPath) {
        return sound['name']!;
      }
    }

    return 'Custom';
  }

  Future<void> _showSoundSelectionDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Alarm Sound'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AlarmSoundService.availableSounds.map((sound) {
                final isSelected = _soundPath == sound['path'];
                return ListTile(
                  title: Text(sound['name']!),
                  leading: Radio<String>(
                    value: sound['path']!,
                    groupValue: _soundPath,
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _soundPath = value;
                        });
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _testSound(sound['path']!),
                  ),
                  selected: isSelected,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _testSound(String soundPath) async {
    try {
      await AlarmSoundService.instance.testSound(soundPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not play sound: $e')),
        );
      }
    }
  }

  Widget _buildVibrateSection() {
    return Card(
      child: SwitchListTile(
        title: const Text('Vibrate'),
        subtitle: const Text('Vibrate when alarm rings'),
        value: _vibrate,
        onChanged: (value) {
          setState(() {
            _vibrate = value;
          });
        },
      ),
    );
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              hourMinuteTextColor: Theme.of(context).colorScheme.onSurface,
              dayPeriodTextColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _hour = time.hour;
        _minute = time.minute;
      });
    }
  }

  Future<void> _saveAlarm() async {
    // Convert boolean repeat days to list of active day indices
    final repeatingDays = <int>[];
    for (int i = 0; i < _repeatDays.length; i++) {
      if (_repeatDays[i]) {
        repeatingDays.add(i);
      }
    }

    final alarm = AlarmModel(
      id: widget.alarm?.id ?? _alarmService.generateAlarmId(),
      hour: _hour,
      minute: _minute,
      label: _labelController.text.trim(),
      isEnabled: widget.alarm?.isEnabled ?? true,
      repeatingDays: repeatingDays,
      soundPath: _soundPath,
      vibrate: _vibrate,
    );

    try {
      if (widget.alarm != null) {
        await _alarmService.updateAlarm(alarm);
      } else {
        await _alarmService.addAlarm(alarm);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving alarm: $e')),
        );
      }
    }
  }

  String _formatTime(int hour, int minute) {
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = hour < 12 ? 'AM' : 'PM';
    return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}

class _DayToggleButton extends StatelessWidget {
  final String day;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayToggleButton({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: Text(
            day[0], // First letter of day name
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
