import 'dart:io';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';

class AlarmButton extends StatefulWidget {
  const AlarmButton({super.key});

  @override
  State<AlarmButton> createState() => _AlarmButtonState();
}

class _AlarmButtonState extends State<AlarmButton> {
  int? _alarmId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🔔 SET ALARM BUTTON
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () async {
              final dateTime =
              DateTime.now().add(const Duration(seconds: 10));

              final alarmId =
                  DateTime.now().millisecondsSinceEpoch ~/ 1000;

              final alarmSettings = AlarmSettings(
                id: alarmId,
                dateTime: dateTime,
                assetAudioPath: 'assets/alarm.mp3',
                loopAudio: true,
                vibrate: true,
                androidFullScreenIntent: true,
                androidStopAlarmOnTermination: false,
                warningNotificationOnKill: Platform.isIOS,
                volumeSettings: VolumeSettings.fade(
                  volume: 1.0,
                  fadeDuration: const Duration(seconds: 10),
                  volumeEnforced: true,
                ),
                notificationSettings: const NotificationSettings(
                  title: 'Alarm!',
                  body: 'Your 10-second alarm is ringing ⏰',
                  stopButton: 'Stop',
                  icon: 'ic_alarm',
                ),
              );

              await Alarm.set(alarmSettings: alarmSettings);

              setState(() {
                _alarmId = alarmId;
              });

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alarm set for 10 seconds ⏳'),
                ),
              );
            },
            child: const Text('Set Alarm (10s)'),
          ),

          const SizedBox(height: 20),

          /// 🛑 KILL ALARM BUTTON
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              disabledBackgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.black,
            ),
            onPressed: _alarmId == null
                ? null
                : () async {
              await Alarm.stop(_alarmId!);

              setState(() {
                _alarmId = null;
              });

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alarm stopped 🛑'),
                ),
              );
            },
            child: const Text('Kill Alarm'),
          ),
        ],
      ),
    );
  }
}