import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppTheme {
  static final _box = Hive.box('settings');

  static final ValueNotifier<Color> primaryColor =
  ValueNotifier<Color>(Colors.blue);

  static final ValueNotifier<Color> secondaryColor =
  ValueNotifier<Color>(Colors.orange);

  static final ValueNotifier<ThemeMode> themeMode =
  ValueNotifier<ThemeMode>(ThemeMode.light);

  /// 🔄 Load saved settings on app start
  static void load() {
    final primary = _box.get('primaryColor');
    final secondary = _box.get('secondaryColor');
    final mode = _box.get('themeMode');

    if (primary is int) {
      primaryColor.value = Color(primary);
    }
    if (secondary is int) {
      secondaryColor.value = Color(secondary);
    }
    if (mode is int) {
      themeMode.value = ThemeMode.values[mode];
    }
  }

  /// 💾 Persist changes
  static void save() {

    debugPrint('💾 Saving theme settings');

    _box.put('primaryColor', primaryColor.value.value);
    _box.put('secondaryColor', secondaryColor.value.value);
    _box.put('themeMode', themeMode.value.index);

    debugPrint('📦 Settings box: ${_box.toMap()}');

  }

  /// 🎨 Presets
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
    save();
  }
}

class _ColorPreset {
  final String name;
  final Color primary;
  final Color secondary;

  const _ColorPreset(this.name, this.primary, this.secondary);
}