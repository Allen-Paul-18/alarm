import 'package:flutter/material.dart';
import 'app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ValueListenableBuilder<Color>(
              valueListenable: AppTheme.primaryColor,
              builder: (context, color, _) {
                return ListTile(
                  title: const Text('Primary Color'),
                  trailing: CircleAvatar(
                    backgroundColor: color,
                  ),
                );
              },
            ),
            ValueListenableBuilder<Color>(
              valueListenable: AppTheme.secondaryColor,
              builder: (context, color, _) {
                return ListTile(
                  title: const Text('Secondary Color'),
                  trailing: CircleAvatar(
                    backgroundColor: color,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
