import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import 'package:aurado_2025/task_manager.dart';
import '../widgets/custom_task_card.dart';

class HealthScreen extends StatefulWidget {
  final TaskModel? task;

  const HealthScreen({Key? key, this.task}) : super(key: key);

  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {

  String selectedFilter = 'All Tasks';
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

    // 🔽 Filter tasks based on dropdown
    List<TaskModel> workTasks = taskManager.getTasksByCategory('Health');

    List<TaskModel> filteredTasks;
    if (selectedFilter == 'Completed Tasks') {
      filteredTasks = workTasks.where((task) => task.isCompleted).toList();
    } else if (selectedFilter == 'Missed Tasks') {
      filteredTasks = workTasks.where((task) =>
      !task.isCompleted && task.dueDateTime.isBefore(DateTime.now())
      ).toList();
    } else {
      // All Tasks (excluding missed and completed)
      filteredTasks = workTasks.where((task) =>
      !task.isCompleted && task.dueDateTime.isAfter(DateTime.now())
      ).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBEEE6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFBEEE6),
        title: const Text(
          'Health Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          DropdownButton<String>(
            value: selectedFilter,
            underline: const SizedBox(),
            icon: const Icon(Icons.filter_list, color: Colors.black),
            dropdownColor: Colors.white.withOpacity(0.9), // Slight transparency
            elevation: 8, // Increased elevation for 3D effect
            style: const TextStyle(color: Colors.black, fontSize: 16),
            items: <String>['All Tasks', 'Completed Tasks', 'Missed Tasks'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(value, style: const TextStyle(color: Colors.black)),
                ),
              );
            }).toList(),
            selectedItemBuilder: (BuildContext context) {
              return <String>['All Tasks', 'Completed Tasks', 'Missed Tasks'].map<Widget>((String item) {
                return Opacity(
                  opacity: 0,
                  child: Text(item, style: const TextStyle(color: Colors.black)),
                );
              }).toList();
            },
            onChanged: (String? newValue) {
              setState(() {
                selectedFilter = newValue!;
              });
            },
            borderRadius: BorderRadius.circular(12), // Rounded corners for dropdown
          ),

          const SizedBox(width: 12),
        ],
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
              // <-- Add this Text widget here -->
              Text(
                selectedFilter,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),
              Expanded(
                child: filteredTasks.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedFilter == 'Completed Tasks'
                            ? 'No completed tasks'
                            : selectedFilter == 'Missed Tasks'
                            ? 'No missed tasks'
                            : 'No pending tasks',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        selectedFilter == 'Completed Tasks'
                            ? 'You have not completed any tasks yet.'
                            : selectedFilter == 'Missed Tasks'
                            ? 'No tasks have been missed yet.'
                            : 'Try adding tasks to get started.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
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