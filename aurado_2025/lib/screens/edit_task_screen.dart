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
  String _initialFormattedDate = '';
  DateTime? _selectedDueDateTime;


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
    // Initialize due date and time
    final date = task.dueDateTime;
    _initialFormattedDate = ''; // Will be set in didChangeDependencies
    _selectedDueDateTime = widget.task.dueDateTime;

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Safe to use context here
    final date = _selectedDueDateTime!;
    final time = TimeOfDay.fromDateTime(date);
    _initialFormattedDate = "${date.day}/${date.month}/${date.year} ${time.format(context)}";
    _dueDateTimeController.text = _initialFormattedDate;

    if (_notification) {
      _notificationText = 'Remind me on $_initialFormattedDate';
    }

    // No need for setState here unless these values are being rebuilt after widgets already built
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
      backgroundColor: const Color(0xFFFBEEE6),
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
                            initialDate: _selectedDueDateTime ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );

                          if (pickedDate != null) {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_selectedDueDateTime ?? DateTime.now()),
                            );

                            if (pickedTime != null) {
                              final combined = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );

                              final formatted = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year} ${pickedTime.format(context)}";

                              setState(() {
                                _dueDateTimeController.text = formatted;
                                _selectedDueDateTime = combined;

                                if (_notification) {
                                  _notificationText = 'Remind me on $formatted';
                                }
                              });
                            }
                          }
                        },

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
                      const SizedBox(height: 16),
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

                      final dueDateTime = _selectedDueDateTime;
                      if (dueDateTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select due date and time')),
                        );
                        return;
                      }

                      final timerMinutes = int.tryParse(_timerController.text) ?? 0;
                      final now = DateTime.now();
                      if (dueDateTime.isBefore(now)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Due date must be in the future')),
                        );
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

                      Navigator.pop(context, updatedTask);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800000),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 150, vertical: 15),
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
    final scheduledTime =
    tz.TZDateTime.from(dueDateTime, tz.local).subtract(Duration(minutes: minutesBefore));
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
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
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