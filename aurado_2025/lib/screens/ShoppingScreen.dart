import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import 'package:aurado_2025/task_manager.dart';
import '../widgets/custom_task_card.dart';

class ShoppingScreen extends StatefulWidget {
  final TaskModel? task;

  const ShoppingScreen({Key? key, this.task}) : super(key: key);

  @override
  _ShoppingScreenState createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      Provider.of<TaskManager>(context, listen: false).addTask(widget.task!);
    }
  }

  void _deleteTask(TaskModel task) {
    Provider.of<TaskManager>(context, listen: false).removeTask(task);
  }

  @override
  Widget build(BuildContext context) {
    final taskManager = Provider.of<TaskManager>(context);
    final now = DateTime.now();
    final day = DateFormat('EEEE').format(now);
    final date = DateFormat('MMMM d, y').format(now);
    final time = DateFormat('hh:mm a').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFFBEEE6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Shopping Tasks',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color(0xFFFBEEE6),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Date: $day, $date | Time: $time PKT',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: taskManager.getTasksByCategory('Shopping').isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No tasks yet',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Tap Create a Task from the Dashboard screen to add a task.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: taskManager.getTasksByCategory('Shopping').length,
                  itemBuilder: (context, index) {
                    final task = taskManager.getTasksByCategory('Shopping')[index];
                    return CustomTaskCard(
                      task: task,
                      onDelete: () => _deleteTask(task),
                    );
                  },
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
}