import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import 'edit_task_screen.dart';

class MissedScreen extends StatefulWidget {
  @override
  _MissedScreenState createState() => _MissedScreenState();
}

class _MissedScreenState extends State<MissedScreen> {
  final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Submit Expense Report',
      'description': 'Missed deadline to upload monthly report.',
      'time': '09:00 AM PKT',
      'color': 0xffFFB6C1, // Light Pink
    },
    {
      'title': 'Client Call',
      'description': 'Follow-up call with client was missed.',
      'time': '11:00 AM PKT',
      'color': 0xffFFA07A, // Light Salmon
    },
    {
      'title': 'Assignment Submission',
      'description': 'Assignment was due yesterday.',
      'time': '04:30 PM PKT',
      'color': 0xffD3D3D3, // Light Gray
    },
  ];

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final day = DateFormat('EEEE').format(now);
    final date = DateFormat('MMMM d, y').format(now);
    final time = DateFormat('hh:mm a').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFFBEEE6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Missed Tasks',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                'Date: $day, $date | Time: $time PKT',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(
                      title: _tasks[index]['title']!,
                      description: _tasks[index]['description']!,
                      time: _tasks[index]['time']!,
                      color: Color(_tasks[index]['color'] as int),
                      onDelete: () => _deleteTask(index),
                      onEdit: () async {
                        final selectedTask = TaskModel(
                          title: _tasks[index]['title'],
                          description: _tasks[index]['description'],
                          category: null,
                          priority: null,
                          repeat: null,
                          dueDateTime: DateTime.now(),
                          minutesBefore: 10,
                          notification: false,
                        );

                        final updatedTask = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditTaskScreen(task: selectedTask),
                          ),
                        );

                        if (updatedTask != null && updatedTask is TaskModel) {
                          setState(() {
                            _tasks[index] = {
                              'title': updatedTask.title,
                              'description': updatedTask.description,
                              'time': DateFormat('hh:mm a').format(updatedTask.dueDateTime),
                              'color': _tasks[index]['color'],
                            };
                          });
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800000),
                    padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Back', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final Color color;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    required this.title,
    required this.description,
    required this.time,
    required this.color,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: color,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            Text('Due: $time', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF800000)),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFF800000)),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
