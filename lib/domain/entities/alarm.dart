class Alarm {
  int? id;
  String label;
  DateTime time;
  bool isEnabled;
  List<int> repeatDays;
  int snoozeDuration;
  String sound;
  bool vibrate;

  Alarm({
    this.id,
    required this.label,
    required this.time,
    this.isEnabled = true,
    required this.repeatDays,
    this.snoozeDuration = 5,
    this.sound = 'default',
    this.vibrate = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'time': time.toIso8601String(),
      'isEnabled': isEnabled ? 1 : 0,
      'repeatDays': repeatDays.join(','),
      'snoozeDuration': snoozeDuration,
      'sound': sound,
      'vibrate': vibrate ? 1 : 0,
    };
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      label: map['label'],
      time: DateTime.parse(map['time']),
      isEnabled: map['isEnabled'] == 1,
      repeatDays: (map['repeatDays'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .map(int.parse)
          .toList(),
      snoozeDuration: map['snoozeDuration'],
      sound: map['sound'],
      vibrate: map['vibrate'] == 1,
    );
  }
}
