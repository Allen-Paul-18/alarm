import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'alarm_create_page.dart';
import 'alarm_service.dart';
import 'alarm_model.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final box = Hive.box<AlarmModel>('alarms');

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: theme.colorScheme.primary,

      appBar: AppBar(
        title: const Text('Timely'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),

      /// 🔁 Reactive alarm list
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<AlarmModel> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                'No alarms yet',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final alarms = box.values.toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: alarms.length,
            itemBuilder: (context, index) {
              final alarm = alarms[index];

              final alarmKey = ValueKey(alarm.id);

              return Dismissible(
                key: alarmKey,
                direction: DismissDirection.endToStart,

                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete alarm?'),
                      content: Text('Delete "${alarm.label}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },

                onDismissed: (_) async {
                  final deletedAlarm = alarm;

                  await AlarmService.deleteAlarm(alarm.id);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 4),
                      content: Text('Deleted "${alarm.label}"'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () async {
                          await AlarmService.setAlarm(deletedAlarm);
                        },
                      ),
                    ),
                  );
                },

                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(alarm.label),
                    subtitle: Text(alarm.repeatDescription),
                    trailing: Switch(
                      value: alarm.enabled,
                      onChanged: (value) async {
                        final updated = AlarmModel(
                          id: alarm.id,
                          dateTime: alarm.dateTime,
                          label: alarm.label,
                          repeatType: alarm.repeatType,
                          repeatDays: alarm.repeatDays,
                          vibrate: alarm.vibrate,
                          snoozeEnabled: alarm.snoozeEnabled,
                          soundPath: alarm.soundPath,
                          enabled: value,
                        );

                        await AlarmService.updateAlarm(updated);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      /// ➕ Create Alarm Button at the Bottom
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final AlarmModel? alarm =
          await Navigator.push<AlarmModel>(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateAlarmPage(),
            ),
          );

          if (alarm != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Alarm "${alarm.label}" set for ${alarm.dateTime}',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}