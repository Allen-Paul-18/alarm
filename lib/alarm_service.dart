import 'package:alarm/alarm.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'alarm_model.dart';

class AlarmService {
  static final Box<AlarmModel> _box =
  Hive.box<AlarmModel>('alarms');

  /// 🔧 Single source of truth for AlarmSettings
  static AlarmSettings _settingsFromModel(AlarmModel model) {
    return AlarmSettings(
      id: model.id,
      dateTime: model.dateTime,
      assetAudioPath: model.soundPath,
      loopAudio: true,
      vibrate: model.vibrate,
      volumeSettings: VolumeSettings.fixed(volume: 1.0),
      notificationSettings: NotificationSettings(
        title: 'Alarm',
        body: model.label,
        stopButton: 'Stop',
        icon: 'notification_icon',
      ),
    );
  }

  /// ➕ Create alarm (ONLY ONCE PER ID)
  static Future<void> setAlarm(AlarmModel model) async {
    // ⛔ Kill any existing system alarm with same ID
    await Alarm.stop(model.id);

    // ✅ Update or insert SAME Hive entry
    await _box.put(model.id, model);

    if (model.enabled) {
      await Alarm.set(
        alarmSettings: _settingsFromModel(model),
      );
    }
  }

  /// 🔁 Enable / disable alarm (NO NEW ENTRIES)
  static Future<void> updateAlarm(AlarmModel model) async {
    // ⛔ Stop existing scheduled instance
    await Alarm.stop(model.id);

    // 🔁 Update SAME Hive row
    await _box.put(model.id, model);

    if (model.enabled) {
      await Alarm.set(
        alarmSettings: _settingsFromModel(model),
      );
    }
  }

  /// 🗑 Delete alarm completely
  static Future<void> deleteAlarm(int id) async {
    await Alarm.stop(id);
    await _box.delete(id);
  }

  /// 🔄 Restore alarms on app start / reboot
  static Future<void> restoreAlarms() async {
    for (final alarm in _box.values) {
      if (alarm.enabled) {
        await Alarm.set(
          alarmSettings: _settingsFromModel(alarm),
        );
      }
    }
  }
}