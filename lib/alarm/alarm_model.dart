import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'alarm_model.g.dart';

@HiveType(typeId: 1)
enum RepeatType {
  @HiveField(0)
  none,

  @HiveField(1)
  weekly,

  @HiveField(2)
  monthly,

  @HiveField(3)
  yearly,
}

@HiveType(typeId: 0)
class AlarmModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final DateTime dateTime;

  @HiveField(2)
  final String label;

  @HiveField(3)
  final RepeatType repeatType;

  /// Used only when repeatType == RepeatType.weekly
  /// 1 = Monday ... 7 = Sunday
  @HiveField(4)
  final List<int> repeatDays;

  @HiveField(5)
  final bool vibrate;

  @HiveField(6)
  final bool snoozeEnabled;

  @HiveField(7)
  final String soundPath;

  @HiveField(8)
  final bool enabled;

  @HiveField(9)
  final int? customSnoozeMinutes; // per-alarm default

  @HiveField(10)
  final bool useCustomSnooze;

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
    this.customSnoozeMinutes,
    this.useCustomSnooze = false,
  });

  String formatTime(BuildContext context, DateTime dateTime) {
    final time = TimeOfDay.fromDateTime(dateTime);
    return time.format(context); // ✅ respects AM/PM & locale
  }

  /// Derived helpers (NOT stored)
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
