import 'package:flutter/material.dart';

class AppTheme {
  /// Primary app color (used everywhere)
  static final ValueNotifier<Color> primaryColor =
  ValueNotifier<Color>(Colors.blue);

  /// Secondary app color (used for destructive / accent actions)
  static final ValueNotifier<Color> secondaryColor =
  ValueNotifier<Color>(Colors.orange);
}
