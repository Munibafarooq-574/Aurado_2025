import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';


class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
 // final _dueDateController = TextEditingController();
  final _timerController = TextEditingController();
  final TextEditingController _dueDateTimeController = TextEditingController();
  String? _category;
  String? _priority;
  String? _repeat;
  bool _notification = false;
  String _notificationText = 'Remind me on due date & time';



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Centers the title
        title: const Text(
          'Create a Task',
          style: TextStyle(
            fontWeight: FontWeight.w600, // Semi-bold
            fontSize: 20, // Optional: Adjust size as needed
            color: Colors.black, // Optional: Better visibility on light background
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
              Row(
                children: [
                  Text(
                    'Task Title',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _titleController,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your task' : null,
                decoration: InputDecoration(
                  labelText: 'Enter your task title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),

              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _descriptionController,
                maxLines: null, // allows the field to grow
                minLines: 1, // start with 1 line like task title
                maxLength: 10000, // limit to 5000 characters
                onChanged: (value) {
                  if (value.length >= 10000) {
                    // Show popup
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You have reached the maximum character limit of 10000.'),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  counterText: '', // hides default character counter
                ),
              ),

              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 5),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select task category',
                  labelStyle: TextStyle(fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                value: _category,
                items: ['Work', 'Personal', 'Shopping', 'Health', 'Habit'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: _category == value ? Colors.black : Colors.blue[900],
                        fontWeight: _category == value ? FontWeight.normal : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _category = newValue;
                  });
                },
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.black,
                style: TextStyle(
                  color: _category != null ? Colors.black : Colors.blue[900], // Selected value ka color blue
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Priority',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 5),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select task priority',
                  labelStyle: TextStyle(fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                value: _priority,
                items: ['High', 'Medium', 'Low'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: _priority == value ? Colors.black : Colors.blue[900],
                        fontWeight: _priority == value ? FontWeight.normal : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _priority = newValue;
                  });
                },
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.black,
                style: TextStyle(
                  color: _priority != null ? Colors.black : Colors.blue[900], // Selected value ka color blue
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),

              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Due Date & Time',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 5),

              TextFormField(
                controller: _dueDateTimeController,
                readOnly: true, // user can't type manually
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode()); // hide keyboard

                  // Select Date
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(), // no past dates
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    // Select Time
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      // Combine Date + Time
                      final DateTime _ = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );

                      // Format to readable string
                      String formatted = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year} "
                          "${pickedTime.format(context)}";

                      _dueDateTimeController.text = formatted;
                    }
                  }
                },
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter due date & time' : null,
                decoration: InputDecoration(
                  labelText: 'Enter due date & time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Set Timer',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _timerController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                value == null || value.isEmpty ? 'Set timer (minutes before due time)' : null,
                decoration: InputDecoration(
                  labelText: 'Set timer (minutes before due time)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Repeat',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 5),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select repeat option',
                  labelStyle: TextStyle(fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                value: _repeat,
                items: ['Daily', 'Weekly', 'Monthly', 'None'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: _repeat == value ? Colors.black : Colors.blue[900],
                        fontWeight: _repeat == value ? FontWeight.normal : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _repeat = newValue;
                  });
                },
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.black,
                style: TextStyle(
                  color: _repeat != null ? Colors.black : Colors.blue[900], // Selected value ka color blue
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Notification',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Checkbox(
                    value: _notification,
                    onChanged: (value) {
                      setState(() {
                        _notification = value ?? false;
                        if (_notification) {
                          _notificationText = _dueDateTimeController.text.isNotEmpty
                              ? 'Remind me on ${_dueDateTimeController.text}'
                              : 'Remind me on due date & time';
                        } else {
                          _notificationText = 'Remind me on due date & time';
                        }
                      });
                    },
                  ),
                  Text(_notificationText),
                ],
              ),
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      if (_titleController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter your task title')),
                        );
                        return;
                      }
                      if (_descriptionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter task description')),
                        );
                        return;
                      }
                      if (_dueDateTimeController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select due date & time')),
                        );
                        return;
                      }
                      if (_timerController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please set timer (minutes before)')),
                        );
                        return;
                      }

                      // Parse the date/time from the formatted string "dd/MM/yyyy hh:mm a"
                      try {
                        // Convert "dd/MM/yyyy hh:mm a" to DateTime:
                        final parts = _dueDateTimeController.text.split(' ');
                        final dateParts = parts[0].split('/');
                        final timeString = parts[1] + ' ' + parts[2]; // hh:mm AM/PM

                        int day = int.parse(dateParts[0]);
                        int month = int.parse(dateParts[1]);
                        int year = int.parse(dateParts[2]);

                        // Parse time
                        TimeOfDay time = TimeOfDay(
                          hour: int.parse(timeString.split(':')[0]),
                          minute: int.parse(timeString.split(':')[1].split(' ')[0]),
                        );
                        // Adjust for AM/PM
                        if (timeString.endsWith("PM") && time.hour < 12) {
                          time = TimeOfDay(hour: time.hour + 12, minute: time.minute);
                        } else if (timeString.endsWith("AM") && time.hour == 12) {
                          time = const TimeOfDay(hour: 0, minute: 0);
                        }

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

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Task saved and notification scheduled!')),
                        );
                        // Optionally clear or pop screen here
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid due date & time format')),
                        );
                      }
                    },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800000),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
    required String title,
    required String body,
    required DateTime dueDateTime,
    required int minutesBefore,
  }) async {
    final scheduledTime = tz.TZDateTime.from(dueDateTime, tz.local)
        .subtract(Duration(minutes: minutesBefore));

    // If scheduledTime is before now, don't schedule (optional safety)
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      scheduledTime.millisecondsSinceEpoch ~/ 1000, // Unique ID
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

void main() {
  runApp(MaterialApp(
    home: CreateTaskScreen(),
  ));
}