import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../task_manager.dart';
import 'edit_task_screen.dart';

class MissedScreen extends StatefulWidget {
  @override
  _MissedScreenState createState() => _MissedScreenState();
}

class _MissedScreenState extends State<MissedScreen> {
  Timer? _timer;
  bool selectAll = false;
  final Set<TaskModel> selectedTasks = {};

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(minutes: 1), (_) => setState(() {}));
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

    final missedTasks = Provider.of<TaskManager>(context).getMissedTasks();

    return Scaffold(
      backgroundColor: const Color(0xFFFBEEE6),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
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
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: missedTasks.isEmpty
                        ? Center(
                      child: Text(
                        'No missed tasks!',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                        : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          // Select All checkbox row
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
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
                                          selectedTasks.addAll(missedTasks);
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
                                  backgroundColor:
                                  MaterialStateProperty.resolveWith<
                                      Color>((states) {
                                    if (states
                                        .contains(MaterialState.disabled)) {
                                      return Colors.grey;
                                    }
                                    return const Color(0xFF800000);
                                  }),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                  ),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                  ),
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                          ...missedTasks.asMap().entries.map((entry) {
                            final index = entry.key;
                            final task = entry.value;
                            final isSelected = selectedTasks.contains(task);

                            return MissedTaskCard(
                              task: task,
                              index: index, // 👈 Pass index here
                              onEdit: () async {
                                final updatedTask = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditTaskScreen(task: task),
                                  ),
                                );
                                if (updatedTask != null && updatedTask is TaskModel) {
                                  Provider.of<TaskManager>(context, listen: false).updateTask(task, updatedTask);
                                  _showTaskUpdatedDialog(context);
                                }

                              },
                              onDelete: () {
                                Provider.of<TaskManager>(context, listen: false).removeTask(task);
                              },
                              isSelected: isSelected,
                              onCheckboxChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedTasks.add(task);
                                  } else {
                                    selectedTasks.remove(task);
                                  }
                                  selectAll = selectedTasks.length == missedTasks.length;
                                });
                              },
                            );
                          }).toList(),

                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
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
                    padding:
                    const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                  const Text('Back', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Confirmation'),
        content: Text('Do you want to delete ${selectedTasks.length} selected task(s)?'),
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

  void _showTaskUpdatedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Task Updated Successfully'),
        content: const Text('The missed task has been updated successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

}

class MissedTaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isSelected;
  final ValueChanged<bool?> onCheckboxChanged;
  final int index;

  const MissedTaskCard({
    required this.task,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    Key? key,
    required this.isSelected,
    required this.onCheckboxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dueFormatted = DateFormat('EEEE, MMM d, yyyy - hh:mm a').format(task.dueDateTime);
    final overdueBy = DateTime.now().difference(task.dueDateTime);
    final overdueText = overdueBy.inMinutes < 60
        ? 'Missed ${overdueBy.inMinutes} mins ago'
        : overdueBy.inHours < 24
        ? 'Missed ${overdueBy.inHours} hrs ago'
        : 'Missed ${overdueBy.inDays} days ago';

    final borderColor = _getBorderColor(index); // 👉 This sets a cycling color
    final cardColor = Colors.white; // 👉 Background remains white

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: cardColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: onCheckboxChanged,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Description: ${task.description}'),
                          Text('Category: ${task.category ?? 'N/A'}'),
                          Text('Priority: ${task.priority ?? 'N/A'}'),
                          Text('Due: $dueFormatted'),
                          Text('Repeat: ${task.repeat ?? 'None'}'),
                          Text('Notification: ${task.notification == true ? 'Yes' : 'No'}'),
                          const SizedBox(height: 4),
                          Text(
                            overdueText,
                            style: const TextStyle(color: Color(0xFF800000)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF800000)),
                    onPressed: onEdit,
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // 🎨 Color cycle function
  Color _getBorderColor(int index) {
    final colors = [
      Colors.pink.shade400,
      Colors.red.shade400,
      Colors.purple.shade400,
      Colors.blue.shade400,
      Colors.orange.shade400,
      Colors.green.shade400,
    ];
    return colors[index % colors.length]; // cycle
  }
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
}