import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'home.dart';
import 'app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Color>(
          valueListenable: AppTheme.primaryColor,
          builder: (context, primary, _) {
            return ValueListenableBuilder<Color>(
              valueListenable: AppTheme.secondaryColor,
              builder: (context, secondary, _) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  themeMode: mode,

                  /// ☀️ LIGHT THEME → palette applies
                  theme: ThemeData(
                    brightness: Brightness.light,
                    colorScheme: ColorScheme.light(
                      primary: primary,
                      secondary: secondary,
                    ),
                    useMaterial3: true,
                  ),

                  /// 🌙 DARK THEME → palette IGNORED
                  darkTheme: ThemeData(
                    brightness: Brightness.dark,
                    colorScheme: const ColorScheme.dark(
                      primary: Colors.deepPurple,
                      secondary: Colors.tealAccent,
                    ),
                    useMaterial3: true,
                  ),

                  home: const HomePage(),
                );
              },
            );
          },
        );
      },
    );
  }
}