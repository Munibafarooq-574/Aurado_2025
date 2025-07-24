import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';


class TaskModel {
  final String title;
  final String description;
  final String? category;
  final String? priority;
  final String? repeat;
  final DateTime dueDateTime;
  final int minutesBefore;
  final bool notification;

  TaskModel({
    required this.title,
    required this.description,
    this.category,
    this.priority,
    this.repeat,
    required this.dueDateTime,
    required this.minutesBefore,
    required this.notification,
  });
}

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;

  const EditTaskScreen({super.key, required this.task});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timerController = TextEditingController();
  final TextEditingController _dueDateTimeController = TextEditingController();
  String? _category;
  String? _priority;
  String? _repeat;
  bool _notification = false;
  String _notificationText = 'Remind me on due date & time';

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _category = task.category;
    _priority = task.priority;
    _repeat = task.repeat;
    _notification = task.notification;
    _timerController.text = task.minutesBefore.toString();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final task = widget.task;
    final date = task.dueDateTime;
    final time = TimeOfDay.fromDateTime(date);
    _dueDateTimeController.text = "${date.day}/${date.month}/${date.year} ${time.format(context)}";

    if (_notification) {
      _notificationText = 'Remind me on ${_dueDateTimeController.text}';
    }
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Edit Task',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),

        backgroundColor: const Color(0xFFFBEEE6),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [Text('Task Title', style: TextStyle(fontWeight: FontWeight.w600))]),
              const SizedBox(height: 5),
              TextFormField(
                controller: _titleController,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your task' : null,
                decoration: InputDecoration(
                  labelText: 'Enter your task title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 8),
              const Row(children: [Text('Description', style: TextStyle(fontWeight: FontWeight.w600))]),
              const SizedBox(height: 5),
              TextFormField(
                controller: _descriptionController,
                maxLines: null,
                minLines: 1,
                maxLength: 10000,
                onChanged: (value) {
                  if (value.length >= 10000) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You have reached the maximum character limit of 10000.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                validator: (value) => value == null || value.isEmpty ? 'Please enter task description' : null,
                decoration: InputDecoration(
                  labelText: 'Please enter task description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  counterText: '',
                ),
              ),
              const SizedBox(height: 8),
              const Row(children: [Text('Category', style: TextStyle(fontWeight: FontWeight.w600))]),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select task category',
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                value: _category,
                items: ['Work', 'Personal', 'Shopping', 'Health', 'Habit'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: _category == value ? Colors.black : Colors.blue[900])),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() => _category = newValue);
                },
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.black,
                style: TextStyle(
                  color: _category != null ? Colors.black : Colors.blue[900],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Row(children: [Text('Priority', style: TextStyle(fontWeight: FontWeight.w600))]),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select task priority',
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                value: _priority,
                items: ['High', 'Medium', 'Low'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: _priority == value ? Colors.black : Colors.blue[900])),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() => _priority = newValue);
                },
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.black,
                style: TextStyle(
                  color: _priority != null ? Colors.black : Colors.blue[900],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Row(children: [Text('Due Date & Time', style: TextStyle(fontWeight: FontWeight.w600))]),
              const SizedBox(height: 5),
              TextFormField(
                controller: _dueDateTimeController,
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      // ignore: unused_local_variable
                      final combined = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                      String formatted = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year} ${pickedTime.format(context)}";
                      _dueDateTimeController.text = formatted;
                    }
                  }
                },
                validator: (value) => value == null || value.isEmpty ? 'Please enter due date & time' : null,
                decoration: InputDecoration(
                  labelText: 'Enter due date & time',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 8),
              const Row(children: [Text('Set Timer', style: TextStyle(fontWeight: FontWeight.w600))]),
              const SizedBox(height: 5),
              TextFormField(
                controller: _timerController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value == null || value.isEmpty ? 'Set timer (minutes before due time)' : null,
                decoration: InputDecoration(
                  labelText: 'Set timer (minutes before due time)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 8),
              const Row(children: [Text('Repeat', style: TextStyle(fontWeight: FontWeight.w600))]),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select repeat option',
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                value: _repeat,
                items: ['Daily', 'Weekly', 'Monthly', 'None'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: _repeat == value ? Colors.black : Colors.blue[900])),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() => _repeat = newValue);
                },
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.black,
                style: TextStyle(
                  color: _repeat != null ? Colors.black : Colors.blue[900],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Row(children: [Text('Notification', style: TextStyle(fontWeight: FontWeight.w600))]),
              const SizedBox(height: 5),
              Row(
                children: [
                  Checkbox(
                    value: _notification,
                    onChanged: (value) {
                      setState(() {
                        _notification = value ?? false;
                        _notificationText = _notification && _dueDateTimeController.text.isNotEmpty
                            ? 'Remind me on ${_dueDateTimeController.text}'
                            : 'Remind me on due date & time';
                      });
                    },
                  ),
                  Text(_notificationText),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _dueDateTimeController.text.isEmpty || _timerController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
                      return;
                    }

                    try {
                      final parts = _dueDateTimeController.text.split(' ');
                      final dateParts = parts[0].split('/');
                      final timeString = parts[1] + ' ' + parts[2];

                      int day = int.parse(dateParts[0]);
                      int month = int.parse(dateParts[1]);
                      int year = int.parse(dateParts[2]);

                      TimeOfDay time = TimeOfDay(
                        hour: int.parse(timeString.split(':')[0]),
                        minute: int.parse(timeString.split(':')[1].split(' ')[0]),
                      );

                      if (timeString.endsWith("PM") && time.hour < 12) time = TimeOfDay(hour: time.hour + 12, minute: time.minute);
                      if (timeString.endsWith("AM") && time.hour == 12) time = const TimeOfDay(hour: 0, minute: 0);

                      final dueDateTime = DateTime(year, month, day, time.hour, time.minute);
                      final timerMinutes = int.tryParse(_timerController.text) ?? 0;

                      if (_notification) {
                        scheduleNotification(
                          title: _titleController.text,
                          body: _descriptionController.text,
                          dueDateTime: dueDateTime,
                          minutesBefore: timerMinutes,
                        );
                      }

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task updated and notification scheduled!')));
                      Navigator.pop(context, TaskModel(
                        title: _titleController.text,
                        description: _descriptionController.text,
                        category: _category,
                        priority: _priority,
                        repeat: _repeat,
                        dueDateTime: dueDateTime,
                        minutesBefore: timerMinutes,
                        notification: _notification,
                      ));

                    }
                    catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid due date & time format')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800000),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),

                  child: const Text('Edit', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime dueDateTime,
    required int minutesBefore,
  }) async {
    final scheduledTime = tz.TZDateTime.from(dueDateTime, tz.local).subtract(Duration(minutes: minutesBefore));
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      scheduledTime.millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Task Reminders',
          channelDescription: 'Reminds before the task is due',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateTimeController.dispose();
    _timerController.dispose();
    super.dispose();
  }
}
