import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'alarm_button.dart';
import 'alarm_page.dart';
import 'alarm_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

      /// ⏰ Existing alarm buttons (unchanged)
      body: const AlarmButton(),

      /// ➕ Create Alarm
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
                  'Alarm "${alarm.label}" set for '
                      '${alarm.dateTime}',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
