class AlarmModel {
  final String id;
  final int hour;
  final int minute;
  final String label;
  final bool isEnabled;
  final List<int> repeatingDays; // 0 = Sunday, 1 = Monday, etc.
  final String soundPath;
  final bool vibrate;

  const AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    this.label = '',
    this.isEnabled = true,
    this.repeatingDays = const [],
    this.soundPath = '',
    this.vibrate = true,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'label': label,
      'isEnabled': isEnabled,
      'repeatingDays': repeatingDays,
      'soundPath': soundPath,
      'vibrate': vibrate,
    };
  }

  // Create from JSON
  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      label: json['label'] as String? ?? '',
      isEnabled: json['isEnabled'] as bool? ?? true,
      repeatingDays: List<int>.from(json['repeatingDays'] as List? ?? []),
      soundPath: json['soundPath'] as String? ?? '',
      vibrate: json['vibrate'] as bool? ?? true,
    );
  }

  // Copy with new values
  AlarmModel copyWith({
    String? id,
    int? hour,
    int? minute,
    String? label,
    bool? isEnabled,
    List<int>? repeatingDays,
    String? soundPath,
    bool? vibrate,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatingDays: repeatingDays ?? this.repeatingDays,
      soundPath: soundPath ?? this.soundPath,
      vibrate: vibrate ?? this.vibrate,
    );
  }

  // Format time as string
  String get timeString {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  String get formattedTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }

  // Check if alarm repeats
  bool get isRepeating => repeatingDays.isNotEmpty;

  // Get repeat days as formatted string
  String get repeatString {
    if (repeatingDays.isEmpty) return 'One time';

    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final activeDays = repeatingDays.map((day) => dayNames[day]).toList();

    // Check for special cases
    if (repeatingDays.length == 7) return 'Every day';
    if (repeatingDays.length == 5 &&
        repeatingDays.every((day) => day >= 1 && day <= 5)) return 'Weekdays';
    if (repeatingDays.length == 2 &&
        repeatingDays.contains(0) &&
        repeatingDays.contains(6)) return 'Weekends';

    return activeDays.join(', ');
  }

  @override
  String toString() {
    return 'AlarmModel(id: $id, time: $timeString, label: $label, isEnabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlarmModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
