import 'package:flutter/material.dart';
import 'package:alarm_app/alarm/alarm_model.dart';
import 'package:alarm_app/alarm/alarm_service.dart';

const Map<int, String> weekDays = {
  1: 'Mon',
  2: 'Tue',
  3: 'Wed',
  4: 'Thu',
  5: 'Fri',
  6: 'Sat',
  7: 'Sun',
};

class CreateAlarmPage extends StatefulWidget {
  final AlarmModel? alarm; // null = create, non-null = edit

  const CreateAlarmPage({
    super.key,
    this.alarm,
  });

  @override
  State<CreateAlarmPage> createState() => _CreateAlarmPageState();
}

class _CreateAlarmPageState extends State<CreateAlarmPage> {
  /// Controllers
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _snoozeController = TextEditingController();

  /// Alarm state
  DateTime _selectedDateTime =
  DateTime.now().add(const Duration(minutes: 1));

  RepeatType _repeatType = RepeatType.none;
  final Set<int> _selectedDays = {};

  /// Snooze state (PER PAGE, NOT GLOBAL)
  bool _useCustomSnooze = false;
  int? _customSnoozeMinutes;

  @override
  void initState() {
    super.initState();

    final alarm = widget.alarm;
    if (alarm != null) {
      _labelController.text = alarm.label;
      _selectedDateTime = alarm.dateTime;
      _repeatType = alarm.repeatType;
      _selectedDays.addAll(alarm.repeatDays);

      _useCustomSnooze = alarm.useCustomSnooze;
      _customSnoozeMinutes = alarm.customSnoozeMinutes;
      _snoozeController.text =
          alarm.customSnoozeMinutes?.toString() ?? '';
    }
  }

  /// Pick time
  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        time.hour,
        time.minute,
      );
    });
  }

  /// Pick date
  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
    });
  }

  /// Save alarm
  Future<void> _saveAlarm() async {
    if (_labelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter alarm name')),
      );
      return;
    }

    if (_selectedDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alarm time must be in the future')),
      );
      return;
    }

    final isEdit = widget.alarm != null;

    final alarm = AlarmModel(
      id: isEdit
          ? widget.alarm!.id
          : DateTime.now().millisecondsSinceEpoch % 0xFFFFFFFF,
      dateTime: _selectedDateTime,
      label: _labelController.text.trim(),
      repeatType: _repeatType,
      repeatDays:
      _repeatType == RepeatType.weekly ? _selectedDays.toList() : [],
      vibrate: isEdit ? widget.alarm!.vibrate : true,
      snoozeEnabled: isEdit ? widget.alarm!.snoozeEnabled : true,
      soundPath: isEdit ? widget.alarm!.soundPath : 'assets/alarm.mp3',
      enabled: isEdit ? widget.alarm!.enabled : true,

      // 💤 Custom snooze
      useCustomSnooze: _useCustomSnooze,
      customSnoozeMinutes:
      _useCustomSnooze ? _customSnoozeMinutes : null,
    );

    if (isEdit) {
      await AlarmService.updateAlarm(alarm);
    } else {
      await AlarmService.setAlarm(alarm);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _snoozeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'Create Alarm' : 'Edit Alarm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🏷 Alarm name
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Alarm Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// ⏰ Time picker
            ListTile(
              title: const Text('Time'),
              subtitle: Text(
                TimeOfDay.fromDateTime(_selectedDateTime)
                    .format(context),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),

            /// 📅 Date picker
            ListTile(
              title: const Text('Date'),
              subtitle: Text(
                '${_selectedDateTime.day}/'
                    '${_selectedDateTime.month}/'
                    '${_selectedDateTime.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),

            const SizedBox(height: 16),
            const Text('Repeat',
                style: TextStyle(fontWeight: FontWeight.bold)),

            RadioListTile<RepeatType>(
              title: const Text('No repeat'),
              value: RepeatType.none,
              groupValue: _repeatType,
              onChanged: (v) {
                setState(() {
                  _repeatType = v!;
                  _selectedDays.clear();
                });
              },
            ),

            RadioListTile<RepeatType>(
              title: const Text('Weekly'),
              value: RepeatType.weekly,
              groupValue: _repeatType,
              onChanged: (v) {
                setState(() {
                  _repeatType = v!;
                  _selectedDays.clear();
                });
              },
            ),

            if (_repeatType == RepeatType.weekly)
              Wrap(
                spacing: 8,
                children: weekDays.entries.map((entry) {
                  final selected =
                  _selectedDays.contains(entry.key);
                  return FilterChip(
                    label: Text(entry.value),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        v
                            ? _selectedDays.add(entry.key)
                            : _selectedDays.remove(entry.key);
                      });
                    },
                  );
                }).toList(),
              ),

            const SizedBox(height: 16),
            const Text('Snooze',
                style: TextStyle(fontWeight: FontWeight.bold)),

            SwitchListTile(
              title: const Text('Use custom snooze duration'),
              value: _useCustomSnooze,
              onChanged: (v) {
                setState(() {
                  _useCustomSnooze = v;
                });
              },
            ),

            if (_useCustomSnooze)
              TextField(
                controller: _snoozeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Snooze minutes (e.g. 37)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  _customSnoozeMinutes = int.tryParse(v);
                },
              ),

            const Spacer(),

            /// 💾 Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAlarm,
                child: const Text('Save Alarm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
