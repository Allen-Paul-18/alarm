import 'package:flutter/material.dart';

class AppTheme {
  static final ValueNotifier<Color> primaryColor =
  ValueNotifier<Color>(Colors.blue);

  static final ValueNotifier<Color> secondaryColor =
  ValueNotifier<Color>(Colors.orange);

  static final ValueNotifier<ThemeMode> themeMode =
  ValueNotifier<ThemeMode>(ThemeMode.light);

  /// Preset color pairs
  static const List<_ColorPreset> presets = [
    _ColorPreset('Ocean', Colors.blue, Colors.teal),
    _ColorPreset('Sunset', Colors.deepOrange, Colors.red),
    _ColorPreset('Forest', Colors.green, Colors.brown),
    _ColorPreset('Purple Night', Colors.purple, Colors.deepPurple),
    _ColorPreset('Mono', Colors.black, Colors.grey),
  ];

  static void applyPreset(_ColorPreset preset) {
    primaryColor.value = preset.primary;
    secondaryColor.value = preset.secondary;
  }
}

class _ColorPreset {
  final String name;
  final Color primary;
  final Color secondary;

  const _ColorPreset(this.name, this.primary, this.secondary);
}