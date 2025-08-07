import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';
import '../models/task.dart';

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
      backgroundColor: const Color(0xFFFBEEE6), // Match TodayScreen background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('Task Title',
                              style: TextStyle(fontWeight: FontWeight.w600))
                        ],
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _titleController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your task'
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Enter your task title',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Text('Description',
                              style: TextStyle(fontWeight: FontWeight.w600))
                        ],
                      ),
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
                                content: Text(
                                    'You have reached the maximum character limit of 10000.'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter task description'
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Please enter task description',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Text('Category',
                              style: TextStyle(fontWeight: FontWeight.w600))
                        ],
                      ),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select task category',
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        value: _category,
                        items: ['Work', 'Personal', 'Shopping', 'Health', 'Habit']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: TextStyle(
                                    color: _category == value
                                        ? Colors.black
                                        : Colors.blue[900])),
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
                      const Row(
                        children: [
                          Text('Priority',
                              style: TextStyle(fontWeight: FontWeight.w600))
                        ],
                      ),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select task priority',
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        value: _priority,
                        items: ['High', 'Medium', 'Low'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: TextStyle(
                                    color: _priority == value
                                        ? Colors.black
                                        : Colors.blue[900])),
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
                      const Row(
                        children: [
                          Text('Due Date & Time',
                              style: TextStyle(fontWeight: FontWeight.w600))
                        ],
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _dueDateTimeController,
                        readOnly: true,
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: widget.task.dueDateTime,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime:
                              TimeOfDay.fromDateTime(widget.task.dueDateTime),
                            );
                            if (pickedTime != null) {
                              final combined = DateTime(pickedDate.year,
                                  pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                              String formatted =
                                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year} ${pickedTime.format(context)}";
                              _dueDateTimeController.text = formatted;
                              if (_notification) {
                                setState(() {
                                  _notificationText = 'Remind me on $formatted';
                                });
                              }
                            }
                          }
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter due date & time'
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Enter due date & time',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Text('Set Timer',
                              style: TextStyle(fontWeight: FontWeight.w600))
                        ],
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _timerController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => value == null || value.isEmpty
                            ? 'Set timer (minutes before due time)'
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Set timer (minutes before due time)',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Text('Repeat',
                              style: TextStyle(fontWeight: FontWeight.w600))
                        ],
                      ),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select repeat option',
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        value: _repeat,
                        items: ['Daily', 'Weekly', 'Monthly', 'None']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: TextStyle(
                                    color: _repeat == value
                                        ? Colors.black
                                        : Colors.blue[900])),
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
                      const Row(
                        children: [
                          Text('Notification',
                              style: TextStyle(fontWeight: FontWeight.w600))
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Checkbox(
                            value: _notification,
                            onChanged: (value) {
                              setState(() {
                                _notification = value ?? false;
                                _notificationText = _notification &&
                                    _dueDateTimeController.text.isNotEmpty
                                    ? 'Remind me on ${_dueDateTimeController.text}'
                                    : 'Remind me on due date & time';
                              });
                            },
                          ),
                          Text(_notificationText),
                        ],
                      ),
                      const SizedBox(height: 16), // Extra space to avoid clipping
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_titleController.text.isEmpty ||
                          _descriptionController.text.isEmpty ||
                          _dueDateTimeController.text.isEmpty ||
                          _timerController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill all required fields')),
                        );
                        return;
                      }

                      try {
                        final parts = _dueDateTimeController.text.split(' ');
                        final dateParts = parts[0].split('/');
                        final timeParts = parts[1].split(':');
                        final period = parts[2].trim(); // AM/PM

                        int day = int.parse(dateParts[0]);
                        int month = int.parse(dateParts[1]);
                        int year = int.parse(dateParts[2]);
                        int hour = int.parse(timeParts[0]);
                        int minute = int.parse(timeParts[1].split(' ')[0]);

                        // Adjust hour based on AM/PM
                        if (period.toUpperCase() == 'PM' && hour != 12) hour += 12;
                        if (period.toUpperCase() == 'AM' && hour == 12) hour = 0;

                        final dueDateTime =
                        DateTime(year, month, day, hour, minute);
                        final timerMinutes = int.tryParse(_timerController.text) ?? 0;

                        // Check if due date is in the future
                        if (dueDateTime.isBefore(DateTime.now())) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Due date must be in the future')),
                          );
                          Navigator.pop(context, widget.task); // Return original task if invalid
                          return;
                        }

                        if (_notification) {
                          scheduleNotification(
                            id: widget.task.id,
                            title: _titleController.text,
                            body: _descriptionController.text,
                            dueDateTime: dueDateTime,
                            minutesBefore: timerMinutes,
                          );
                        }

                        final updatedTask = TaskModel(
                          id: widget.task.id,
                          title: _titleController.text,
                          description: _descriptionController.text,
                          category: _category,
                          priority: _priority,
                          repeat: _repeat,
                          dueDateTime: dueDateTime,
                          minutesBefore: timerMinutes,
                          notification: _notification,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                              Text('Task updated and notification scheduled!')),
                        );

                        Navigator.pop(context, updatedTask);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Error: Invalid date/time format. Please try again. ($e)')),
                        );
                        Navigator.pop(context, widget.task); // Return original task on error
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800000),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 150, vertical: 15), // Match TodayScreen
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime dueDateTime,
    required int minutesBefore,
  }) async {
    final scheduledTime = tz.TZDateTime.from(dueDateTime, tz.local).subtract(Duration(minutes: minutesBefore));
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification time must be in the future')),
      );
      return;
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id.hashCode,
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule notification: $e')),
      );
    }
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