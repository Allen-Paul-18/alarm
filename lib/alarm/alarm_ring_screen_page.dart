import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'alarm_model.dart';
import 'alarm_service.dart';

class AlarmRingPage extends StatelessWidget {
  final int alarmId;
  const AlarmRingPage({super.key, required this.alarmId});

  int _getDefaultSnoozeMinutes(AlarmModel alarm) {
    if (alarm.useCustomSnooze && alarm.customSnoozeMinutes != null) {
      return alarm.customSnoozeMinutes!;
    }
    return Hive.box('settings')
        .get('last_snooze_minutes', defaultValue: 10);
  }

  Future<int?> _showCustomSnoozePicker(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Custom Snooze (minutes)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'e.g. 37',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Snooze'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<AlarmModel>('alarms');

    final AlarmModel? alarm = box.values
        .cast<AlarmModel?>()
        .firstWhere(
          (a) => a?.id == alarmId,
      orElse: () => null,
    );

    if (alarm == null) {
      return const SizedBox.shrink();
    }

    final timeText =
    TimeOfDay.fromDateTime(alarm.dateTime).format(context);

    final defaultSnooze = _getDefaultSnoozeMinutes(alarm);

    Future<void> snooze(int minutes) async {
      await Alarm.stop(alarmId);
      await AlarmService.snoozeAlarm(alarm, minutes);
      if (context.mounted) Navigator.pop(context);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ⏰ TIME
              Text(
                timeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              /// 🏷 LABEL
              Text(
                alarm.label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 40),

              /// 💤 QUICK SNOOZE
              if (alarm.snoozeEnabled)
                Wrap(
                  spacing: 12,
                  children: [5, 10, 15].map((min) {
                    return ElevatedButton(
                      onPressed: () => snooze(min),
                      child: Text('$min min'),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 12),

              /// ⏱ CUSTOM SNOOZE
              if (alarm.snoozeEnabled)
                ElevatedButton(
                  onPressed: () async {
                    final minutes =
                    await _showCustomSnoozePicker(context);
                    if (minutes != null) {
                      snooze(minutes);
                    }
                  },
                  child: Text('Custom ($defaultSnooze min default)'),
                ),

              const SizedBox(height: 24),

              /// 🛑 STOP
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 20,
                  ),
                ),
                onPressed: () async {
                  await Alarm.stop(alarmId);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'STOP',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
