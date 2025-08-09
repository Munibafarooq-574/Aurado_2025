import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../task_manager.dart';
import 'dart:async';

class CompletedScreen extends StatefulWidget {
  const CompletedScreen({Key? key}) : super(key: key);

  @override
  _CompletedScreenState createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  Timer? _timer;
  bool selectAll = false;
  final Set<TaskModel> selectedTasks = {};

  @override
  void initState() {
    super.initState();
    // Timer fires every second to update completion time dynamically
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final day = DateFormat('EEEE').format(now);
    final date = DateFormat('MMMM d, y').format(now);
    final time = DateFormat('hh:mm a').format(now);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Completed Tasks',
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
                    child: Consumer<TaskManager>(
                      builder: (context, taskManager, _) {
                        final completedTasks = taskManager.getCompletedTasks();
                        if (completedTasks.isEmpty) {
                          return Center(
                            child: Text(
                              'No completed tasks yet!',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          );
                        }

                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children:[
                          // Select All checkbox row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: selectAll,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            selectAll = value ?? false;
                                            selectedTasks.clear();
                                            if (selectAll) {
                                              selectedTasks.addAll(completedTasks);
                                            }
                                          });
                                        },
                                      ),
                                      const Text('Select All'),
                                    ],
                                  ),

                                  ElevatedButton(
                                    onPressed: selectedTasks.isNotEmpty
                                        ? () {
                                      _showDeleteConfirmationDialog();
                                    }
                                        : null,
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                                        if (states.contains(MaterialState.disabled)) {
                                          return Colors.grey;
                                        }
                                        return const Color(0xFF800000);
                                      }),
                                      padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      ),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),




                              // List of tasks with checkboxes
                           ...completedTasks.map((task) {
                            final isSelected = selectedTasks.contains(task);
                              // Debug print to verify completedDateTime value
                              print('Task: ${task.title}, completed at: ${task.completedDateTime}');

                              return TaskCardWithCheckbox(
                                title: task.title,
                                description: task.description,
                                category: task.category!,
                                priority: task.priority!,
                                dueDateFormatted: DateFormat('EEEE, MMM d, yyyy - hh:mm a').format(task.dueDateTime) + ' PKT',
                                repeat: task.repeat?.toString() ?? 'None',
                                notification: task.notification == true ? 'Yes' : 'No',
                                color: _getColorForTask(task).withOpacity(0.2),
                                completionText: _getCompletionTimeText(task),
                                  task: task,
                                 isSelected: isSelected,
                                 onCheckboxChanged: (bool? selected) {
                                  setState(() {
                                  if (selected == true) {
                                    selectedTasks.add(task);
                                      if (selectedTasks.length == completedTasks.length) {
                                 selectAll = true;
                                      }
                                  } else {
                                      selectedTasks.remove(task);
                                       selectAll = false;
                                       }
                                     });
                                     },
                                onDelete: () {
                                  Provider.of<TaskManager>(context, listen: false).removeTask(task);
                                },
                              );
                            }).toList(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 70), // Space for the back button
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
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
            ),
          ],
        ),
      ),
    );
  }


  // Confirmation dialog to delete selected tasks
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Confirmation'),
        content: const Text('Do you want to delete the selected tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              final taskManager = Provider.of<TaskManager>(context, listen: false);
              for (var task in selectedTasks) {
                taskManager.removeTask(task);
              }
              selectedTasks.clear();
              selectAll = false;
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
  /// 🔷 Helper to show how long ago the task was completed
  String _getCompletionTimeText(TaskModel task) {
    final completedTime = task.completedDateTime ?? DateTime.now();
    final difference = DateTime.now().difference(completedTime);

    if (difference.inMinutes < 1) return 'Completed just now';
    if (difference.inMinutes < 60) return 'Completed ${difference.inMinutes} mins ago';
    if (difference.inHours < 24) return 'Completed ${difference.inHours} hrs ago';
    return 'Completed ${difference.inDays} days ago';
  }

  /// 🔷 Helper to get task card color based on category
  Color _getColorForTask(TaskModel task) {
    switch (task.category) {
      case 'Work':
        return const Color(0xff6495ED); // Cornflower blue
      case 'Personal':
        return const Color(0xffD3D3D3); // Light gray
      case 'Shopping':
        return const Color(0xffEC9D41); // Orange
      case 'Health':
        return const Color(0xff90EE90); // Light green
      case 'Habit':
        return const Color(0xffFFD700); // Gold
      default:
        return const Color(0xffD3D3D3);
    }
  }


class TaskCardWithCheckbox  extends StatelessWidget {
  final TaskModel task;
  final bool isSelected;
  final ValueChanged<bool?> onCheckboxChanged;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String dueDateFormatted;
  final String repeat;
  final String notification;
  final Color color;
  final String completionText;
  final VoidCallback onDelete;

  const TaskCardWithCheckbox({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.dueDateFormatted,
    required this.repeat,
    required this.notification,
    required this.color,
    required this.onDelete,
    required this.completionText,
    Key? key,
    required this.task,
    required this.isSelected,
    required this.onCheckboxChanged,
  }) : super(key: key);

  Color _getBorderColorForCategory(String? category) {
    switch (category) {
      case 'Work':
        return const Color(0xff6495ED); // blue
      case 'Personal':
        return const Color(0xFFCC3366); // pink
      case 'Shopping':
        return const Color(0xffEC9D41); // orange
      case 'Health':
        return const Color(0xff90EE90); // green
      case 'Habit':
        return const Color(0xffFFD700); // yellow
      default:
        return const Color(0xffA9A9A9); // dark gray for others
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _getBorderColorForCategory(task.category),
          width: 2,
        ),

        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Card(
        color: Colors.white,
        elevation: 0, // remove double shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Checkbox(
            value: isSelected,
            onChanged: onCheckboxChanged,
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: $description'),
              Text('Category: $category'),
              Text('Priority: $priority'),
              Text('Due: $dueDateFormatted'),
              Text('Repeat: $repeat'),
              Text('Notification: $notification'),
              const SizedBox(height: 4),
              Text(
                completionText,
                style: const TextStyle(color: Color(0xFF4CAF50)),
              ),
            ],
          ),

        ),
      ),
    );

  }
}
