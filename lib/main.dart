import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'home.dart';
import 'app_theme.dart';
import 'alarm_model.dart';
import 'alarm_service.dart';
import 'alarm_ring_page.dart';

final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Alarm.init();

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AlarmModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(RepeatTypeAdapter());
    }

    await Hive.openBox<AlarmModel>('alarms');
    await Hive.openBox('settings');
    AppTheme.load();

  } catch (e) {
    debugPrint('Startup error: $e');
  }

  runApp(const MyApp());

  // Restore alarms after UI starts
  await AlarmService.restoreAlarms();

  // 🔔 LISTEN FOR RINGING ALARMS
  Alarm.ringStream.stream.listen((settings) {
    final id = settings.id;

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AlarmRingPage(alarmId: id),
      ),
    );
  });
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
                  navigatorKey: navigatorKey, // ✅ CONNECTED
                  debugShowCheckedModeBanner: false,
                  themeMode: mode,

                  theme: ThemeData(
                    brightness: Brightness.light,
                    colorScheme: ColorScheme.light(
                      primary: primary,
                      secondary: secondary,
                    ),
                    useMaterial3: true,
                  ),

                  darkTheme: ThemeData(
                    brightness: Brightness.dark,
                    colorScheme: const ColorScheme.dark(
                      primary: Colors.black,
                      secondary: Colors.grey,
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