import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

class AlarmRingPage extends StatelessWidget {
  final int alarmId;
  const AlarmRingPage({super.key, required this.alarmId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ElevatedButton(
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
      ),
    );
  }
}