import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _openColorPicker(
      BuildContext context,
      String title,
      Color initialColor,
      ValueNotifier<Color> target,
      ) {
    Color tempColor = initialColor;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                target.value = tempColor;
                AppTheme.save(); // ✅ persist
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🌙 Dark mode
              ValueListenableBuilder<ThemeMode>(
                valueListenable: AppTheme.themeMode,
                builder: (context, mode, _) {
                  return SwitchListTile(
                    activeColor: Colors.white,
                    activeTrackColor: Colors.grey,
                    inactiveThumbColor: Colors.black,
                    inactiveTrackColor: Colors.grey,
                    title: const Text('Dark Mode'),
                    value: mode == ThemeMode.dark,
                    onChanged: (enabled) {
                      AppTheme.themeMode.value =
                      enabled ? ThemeMode.dark : ThemeMode.light;
                      AppTheme.save();
                    },
                  );
                },
              ),

              /// 🎨 Primary color
              ValueListenableBuilder<Color>(
                valueListenable: AppTheme.primaryColor,
                builder: (context, color, _) {
                  return ListTile(
                    title: const Text('Primary Color'),
                    trailing: CircleAvatar(backgroundColor: color),
                    onTap: () {
                      _openColorPicker(
                        context,
                        'Pick Primary Color',
                        color,
                        AppTheme.primaryColor,
                      );
                    },
                  );
                },
              ),

              /// 🎨 Secondary color
              ValueListenableBuilder<Color>(
                valueListenable: AppTheme.secondaryColor,
                builder: (context, color, _) {
                  return ListTile(
                    title: const Text('Secondary Color'),
                    trailing: CircleAvatar(backgroundColor: color),
                    onTap: () {
                      _openColorPicker(
                        context,
                        'Pick Secondary Color',
                        color,
                        AppTheme.secondaryColor,
                      );
                    },
                  );
                },
              ),

              /// 🎨 PRESETS
              const SizedBox(height: 16),
              const Text(
                'Color Presets',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppTheme.presets.map((preset) {
                  return GestureDetector(
                    onTap: () {
                      AppTheme.applyPreset(preset);
                      AppTheme.save(); // ✅ persist
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: preset.primary,
                            ),
                            const SizedBox(width: 4),
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: preset.secondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preset.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}