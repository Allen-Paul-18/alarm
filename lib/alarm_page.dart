import 'package:flutter/material.dart';
import 'alarm_model.dart';

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
  const CreateAlarmPage({super.key});

  @override
  State<CreateAlarmPage> createState() => _CreateAlarmPageState();
}

class _CreateAlarmPageState extends State<CreateAlarmPage> {
  final TextEditingController _labelController = TextEditingController();

  DateTime _selectedDateTime =
  DateTime.now().add(const Duration(minutes: 1));

  RepeatType _repeatType = RepeatType.none;
  final Set<int> _selectedDays = {};

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

  void _saveAlarm() {
    if (_labelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter alarm name')),
      );
      return;
    }

    final alarm = AlarmModel(
      id: DateTime.now().millisecondsSinceEpoch,
      dateTime: _selectedDateTime,
      label: _labelController.text.trim(),
      repeatType: _repeatType,
      repeatDays:
      _repeatType == RepeatType.weekly
          ? _selectedDays.toList()
          : [],
    );

    // For now we just return it
    Navigator.pop(context, alarm);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Alarm')),
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
                TimeOfDay.fromDateTime(_selectedDateTime).format(context),
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

            const SizedBox(height: 10),

            const SizedBox(height: 16),
            const Text(
              'Repeat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            /// ❌ No repeat
            RadioListTile<RepeatType>(
              title: const Text('No repeat'),
              value: RepeatType.none,
              groupValue: _repeatType,
              onChanged: (value) {
                setState(() {
                  _repeatType = value!;
                  _selectedDays.clear();
                });
              },
            ),

            /// 📅 Weekly
            RadioListTile<RepeatType>(
              title: const Text('Weekly'),
              value: RepeatType.weekly,
              groupValue: _repeatType,
              onChanged: (value) {
                setState(() => _repeatType = value!);
              },
            ),

            /// Weekly checklist
            if (_repeatType == RepeatType.weekly)
              Wrap(
                spacing: 8,
                children: weekDays.entries.map((entry) {
                  final selected = _selectedDays.contains(entry.key);
                  return FilterChip(
                    label: Text(entry.value),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        value
                            ? _selectedDays.add(entry.key)
                            : _selectedDays.remove(entry.key);
                      });
                    },
                  );
                }).toList(),
              ),

            /// 🗓️ Monthly
            RadioListTile<RepeatType>(
              title: const Text('Monthly'),
              subtitle: const Text('Repeats every month on this date'),
              value: RepeatType.monthly,
              groupValue: _repeatType,
              onChanged: (value) {
                setState(() {
                  _repeatType = value!;
                  _selectedDays.clear();
                });
              },
            ),

            /// 🎂 Yearly
            RadioListTile<RepeatType>(
              title: const Text('Yearly'),
              subtitle: const Text('Repeats every year on this date'),
              value: RepeatType.yearly,
              groupValue: _repeatType,
              onChanged: (value) {
                setState(() {
                  _repeatType = value!;
                  _selectedDays.clear();
                });
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