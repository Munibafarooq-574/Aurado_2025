import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'edit_task_screen.dart';
import '../models/task.dart' as task_model;
import 'package:aurado_2025/task_manager.dart';
import 'dart:async';


final Set<String> globalShownMissedTaskIds = {};

class TodayScreen extends StatefulWidget {
  final task_model.TaskModel? newTask;
  final bool showSuccessMessage;

  const TodayScreen({
    Key? key,
    this.newTask,
    this.showSuccessMessage = false,
  }) : super(key: key);

  @override
  _TodayScreenState createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {

  Timer? _timer;
  bool _dialogShown = false;
  String _currentTime = '';
  List<String> previouslyVisibleTaskIds = [];


  @override
  void initState() {
    super.initState();

    // Initial time set
    _currentTime = DateFormat('hh:mm a').format(DateTime.now());

    // Timer to update time every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateFormat('hh:mm a').format(DateTime.now());
      });
    });


    // 🔥🔥 ADD THIS BLOCK to insert the new task
    if (widget.newTask != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final taskManager = Provider.of<TaskManager>(context, listen: false);
        if (!taskManager.tasks.contains(widget.newTask)) {
          taskManager.addTask(widget.newTask!);
        }
      });
    }
    // Show missed task dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 100), () {
        final taskManager = Provider.of<TaskManager>(context, listen: false);
        final todayTasks = taskManager.getTodayTasks();
        final now = DateTime.now();

        final missedTasks = todayTasks.where((task) {
          final isToday = task.dueDateTime.year == now.year &&
              task.dueDateTime.month == now.month &&
              task.dueDateTime.day == now.day;
          final isPast = task.dueDateTime.isBefore(now);
          return isToday && isPast && !task.isCompleted;
        }).toList();

        if (missedTasks.isNotEmpty && !_dialogShown) {
          _dialogShown = true;
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Missed Tasks"),
              content: Text("Missed tasks:\n${missedTasks.map((e) => "• ${e.title}").join("\n")}"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      });
    });

  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }





  void _deleteTask(task_model.TaskModel task) {
    Provider.of<TaskManager>(context, listen: false).removeTask(task);
    globalShownMissedTaskIds.remove(task.id);
  }

  @override
  Widget build(BuildContext context) {
    final taskManager = Provider.of<TaskManager>(context); // Listen to changes
    final now = DateTime.now(); // Current time: 01:48 PM PKT, August 07, 2025
    final day = DateFormat('EEEE').format(now); // "Thursday"
    final date = DateFormat('MMMM d, y').format(now); // "August 7, 2025"
    final time = DateFormat('hh:mm a').format(now); // "01:48 PM"
    final todayTasks = taskManager.getTodayTasks();

    return Scaffold(
      backgroundColor: const Color(0xFFFBEEE6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Today Tasks',
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
                child: todayTasks.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        "No tasks for today!",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
                    : ListView(
                  children: _buildGroupedTasks(todayTasks, context),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );

      widgets.addAll(taskList.map((task) {
        return TaskCard(
          key: ValueKey(task.id),
          task: task,
          title: task.title,
          description: task.description,
          time: 'Due: ${DateFormat('MMMM d, y – hh:mm a').format(task.dueDateTime)} PKT',
          color: _getColorForTask(task),
          onDelete: () => _deleteTask(task),
          onEdit: () async {
            try {
              final updatedTask = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditTaskScreen(task: task),
                ),
              );
              if (updatedTask != null && updatedTask is task_model.TaskModel) {
                Provider.of<TaskManager>(context, listen: false).updateTask(task, updatedTask);
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
                setState(() {});  // <-- Optional but good to have to refresh UI immediately
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error opening Edit screen: $e')),
              );
            }
          },
        );
      }));
    });

    return widgets;
  }
}

class TaskCard extends StatefulWidget {
  final Key key;
  final String title;
  final String description;
  final String time;
  final Color color;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final task_model.TaskModel task;

  const TaskCard({
    required this.key,
    required this.title,
    required this.description,
    required this.time,
    required this.color,
    required this.onDelete,
    required this.onEdit,
    required this.task,
  }) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}
class _TaskCardState extends State<TaskCard> {
  bool tempCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: widget.task.isCompleted ? Colors.grey.shade300 : Colors.white,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatefulBuilder(
              builder: (context, setLocalState) {
                return Checkbox(
                  value: tempCompleted || widget.task.isCompleted,
                  onChanged: (bool? value) async {
                    if (value == true) {
                      setLocalState(() {
                        tempCompleted = true;
                      });

                      bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm'),
                          content: const Text('Do you want to mark this task as completed?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        setState(() {
                          widget.task.isCompleted = true;
                        });
                        Provider.of<TaskManager>(context, listen: false)
                            .markTaskAsCompleted(widget.task);
                      } else {
                        setLocalState(() {
                          tempCompleted = false;
                        });
                      }
                    } else {
                      setState(() {
                        widget.task.isCompleted = false;
                      });
                      Provider.of<TaskManager>(context, listen: false)
                          .markTaskAsIncomplete(widget.task);
                    }
                  },
                );
              },
            ),
          ],
        ),

        title: Text(
          widget.task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: (tempCompleted || widget.task.isCompleted)
                ? TextDecoration.lineThrough
                : null,
          ),
        ),

        // ✅ Subtitle showing description and due time
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.task.description.isNotEmpty)
              Text(widget.task.description),
            Text(
              'Due: ${widget.task.dueDateTime.month}/${widget.task.dueDateTime.day}/${widget.task.dueDateTime.year} – '
                  '${TimeOfDay.fromDateTime(widget.task.dueDateTime).format(context)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),

        // ✅ Trailing Edit and Delete buttons
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF800000)),
              onPressed: widget.onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFF800000)),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
