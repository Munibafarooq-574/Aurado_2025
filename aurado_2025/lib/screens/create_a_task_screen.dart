import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
//import 'work_screen.dart';
//import 'PersonalScreen.dart';
//import 'HealthScreen.dart';
//import 'ShoppingScreen.dart';
//import 'HabitScreen.dart';
import 'today_screen.dart';
import 'UpcomingScreen.dart';
import '../models/task.dart' as task_model;



class CreateTaskScreen extends StatefulWidget {
  final task_model.TaskModel? task;
  final Function(task_model.TaskModel) onTaskCreated; // <-- callback

  const CreateTaskScreen({
    Key? key,
    this.task,
    required this.onTaskCreated,  // make it required
  }) : super(key: key);

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}



class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timerController = TextEditingController();
  final TextEditingController _dueDateTimeController = TextEditingController();
  String? _category;
  String? _priority;
  String? _repeat;
  bool _notification = false;
  String _notificationText = 'Remind me on due date & time';

  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      final DateTime due = widget.task!.dueDateTime;

      // Format date and time in one string
      String formatted = "${due.day}/${due.month}/${due.year} "
          "${TimeOfDay.fromDateTime(due).format(context)}";

      _dueDateTimeController.text = formatted;

      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _category = widget.task!.category;
      _priority = widget.task!.priority;
      _repeat = widget.task!.repeat ?? 'None';
      _timerController.text = widget.task!.timer?.toString() ?? '';
      _notification = widget.task!.notification ?? false;
      _selectedDateTime = widget.task!.dueDateTime;
      _notificationText = _notification
          ? 'Remind me on $formatted'
          : 'Remind me on due date & time';
    }
  }

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
        automaticallyImplyLeading: true, // shows back button
      ),
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
                              final combinedDateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );

                              String formatted = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year} "
                                  "${pickedTime.format(context)}";

                              _dueDateTimeController.text = formatted;

                              // ✅ Add this line to fix the issue:
                              _selectedDateTime = combinedDateTime;
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
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {

                      if (_selectedDateTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please select a due date and time")),
                        );
                        return;
                      }

                      // Check if any field is empty first
                      if (_titleController.text.isEmpty ||
                          _descriptionController.text.isEmpty ||
                          _dueDateTimeController.text.isEmpty ||
                          _timerController.text.isEmpty ||
                          _category == null ||
                          _priority == null ||
                          _repeat == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all fields')),
                        );
                        return;
                      }

                      // Then validate timer
                      int? timerMinutes = int.tryParse(_timerController.text);
                      if (timerMinutes == null || timerMinutes < 0 || timerMinutes > 1440) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Invalid Timer'),
                            content: Text('Please enter a valid number between 0 and 1440 minutes.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      // Now continue with confirmation dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Save Task?'),
                          content: Text('Do you want to save this task?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            // Inside showDialog's 'Save' button onPressed:
                            TextButton(
                              onPressed: () {
                                final updatedTask = task_model.TaskModel(
                                  id: widget.task?.id ?? UniqueKey().toString(),
                                  title: _titleController.text,
                                  description: _descriptionController.text,
                                  dueDateTime: _selectedDateTime!,
                                  category: _category!,
                                  priority: _priority!,
                                  repeat: _repeat,
                                  notification: _notification,
                                  timer: int.tryParse(_timerController.text),
                                  minutesBefore: int.tryParse(_timerController.text) ?? 0,
                                );

                                Navigator.pop(context); // Close the dialog first

                                // Decide where to go based on due date:
                                final now = DateTime.now();
                                final dueDate = _selectedDateTime!;
                                final isToday = dueDate.year == now.year &&
                                    dueDate.month == now.month &&
                                    dueDate.day == now.day;

                                if (isToday) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TodayScreen(
                                        newTask: updatedTask,
                                        showSuccessMessage: true,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpcomingScreen(
                                        newTask: updatedTask,
                                        showSuccessMessage: true,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text('Save'),
                            ),

                          ],
                        ),
                      );
                    },

                    child: Text("Save Task"),
                  )

              ),

            ],
          ),
        ),
      ),
    );
  }



  DateTime _parseDueDateTime(String input) {
    final parts = input.split(' ');
    if (parts.length < 2) {
      throw FormatException('Invalid date format');
    }

    final dateParts = parts[0].split('/');
    final timeString = parts[1] + (parts.length > 2 ? ' ' + parts[2] : '');

    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);

    final time = parseTimeOfDay(timeString);  // ✅ USE THE NEW FUNCTION

    return DateTime(year, month, day, time.hour, time.minute);
  }

  TimeOfDay parseTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return TimeOfDay.now(); // fallback if null or empty
    }

    final parts = timeString.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);

    if (parts[1].toLowerCase() == 'pm' && hour != 12) {
      hour += 12;
    } else if (parts[1].toLowerCase() == 'am' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
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

extension on task_model.TaskModel {
  get timer => null;
}

void main() {
  runApp(MaterialApp(
    home: CreateTaskScreen(onTaskCreated: (TaskModel ) {  },),
  ));
}