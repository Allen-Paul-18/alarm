enum RepeatType {
  none,
  weekly,
  monthly,
  yearly,
}

class AlarmModel {
  final int id;
  final DateTime dateTime;
  final String label;

  /// Repeat configuration
  final RepeatType repeatType;

  /// Used only when repeatType == RepeatType.weekly
  /// 1 = Monday ... 7 = Sunday
  final List<int> repeatDays;

  /// Alarm behavior
  final bool vibrate;
  final bool snoozeEnabled;
  final String soundPath;
  final bool enabled;

  const AlarmModel({
    required this.id,
    required this.dateTime,
    required this.label,

    this.repeatType = RepeatType.none,
    this.repeatDays = const [],

    this.vibrate = true,
    this.snoozeEnabled = true,
    this.soundPath = 'assets/alarm.mp3',
    this.enabled = true,
  });

  /// Derived helpers (DO NOT store these as fields)
  bool get isRepeating => repeatType != RepeatType.none;

  bool get isOneTime => repeatType == RepeatType.none;

  String get repeatDescription {
    switch (repeatType) {
      case RepeatType.none:
        return 'One-time';
      case RepeatType.weekly:
        return 'Weekly (${repeatDays.join(', ')})';
      case RepeatType.monthly:
        return 'Monthly';
      case RepeatType.yearly:
        return 'Yearly';
    }
  }
}