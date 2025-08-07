import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'edit_task_screen.dart';
import '../models/task.dart' as task_model;
import 'package:aurado_2025/task_manager.dart'; // Import TaskManager
import 'package:provider/provider.dart'; // Add provider for state management

class UpcomingScreen extends StatefulWidget {
  final task_model.TaskModel? newTask;
  final bool showSuccessMessage;

  const UpcomingScreen({
    Key? key,
    this.newTask,
    this.showSuccessMessage = false,
  }) : super(key: key);

  @override
  _UpcomingScreenState createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  @override
  void initState() {
    super.initState();
    // Add new task if provided
    if (widget.newTask != null) {
      Provider.of<TaskManager>(context, listen: false).addTask(widget.newTask!);
    }

    // Show snackbar if flag is true
    if (widget.showSuccessMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Task saved successfully")),
        );
      });
    }
  }

  void _deleteTask(task_model.TaskModel task) {
    Provider.of<TaskManager>(context, listen: false).removeTask(task as task_model.TaskModel);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final day = DateFormat('EEEE').format(now);
    final date = DateFormat('MMMM d, y').format(now);
    final time = DateFormat('hh:mm a').format(now);
    final taskManager = Provider.of<TaskManager>(context);
    final upcomingTasks = taskManager.getUpcomingTasks();

    return Scaffold(
      backgroundColor: const Color(0xFFFBEEE6), // Light Peach background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Upcoming Tasks',
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
                child: upcomingTasks.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        "No upcoming tasks!",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
                    : ListView(
                  children: _buildGroupedTasks(upcomingTasks, context),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800000), // Maroon
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

  Color _getColorForTask(task_model.TaskModel task) {
    switch (task.category) {
      case 'Work':
        return const Color(0xff6495ED);
      case 'Personal':
        return const Color(0xffD3D3D3);
      case 'Shopping':
        return const Color(0xffEC9D41);
      case 'Health':
        return const Color(0xff90EE90);
      case 'Habit':
        return const Color(0xffFFD700);
      default:
        return const Color(0xffD3D3D3);
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Work':
        return Icons.work;
      case 'Personal':
        return Icons.person;
      case 'Health':
        return Icons.health_and_safety;
      case 'Shopping':
        return Icons.shopping_cart;
      case 'Habit':
        return Icons.loop;
      default:
        return Icons.task;
    }
  }

  List<Widget> _buildGroupedTasks(List<task_model.TaskModel> tasks, BuildContext context) {
    final Map<String, List<task_model.TaskModel>> groupedTasks = {};

    for (var task in tasks) {
      final category = task.category ?? 'Other';
      groupedTasks.putIfAbsent(category, () => []).add(task);
    }

    List<Widget> widgets = [];
    groupedTasks.forEach((category, taskList) {
      taskList.sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(_getIconForCategory(category)),
              const SizedBox(width: 8),
              Text(
                category,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

      widgets.addAll(taskList.map((task) {
        return TaskCard(
          title: task.title,
          description: task.description,
          time: 'Due: ${DateFormat('MMMM d, y – hh:mm a').format(task.dueDateTime)} PKT',
          color: _getColorForTask(task),
          onDelete: () {
            Provider.of<TaskManager>(context, listen: false).removeTask(task);
          },
          onEdit: () async {
            final updatedTask = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
            );

            if (updatedTask != null && updatedTask is task_model.TaskModel) {
              Provider.of<TaskManager>(context, listen: false).updateTask(task, updatedTask);
              // Show dialog box for task update
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Success'),
                  content: const Text('Task has been updated'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
        );
      }));
    });

    return widgets;
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