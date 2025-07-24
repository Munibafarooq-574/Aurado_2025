import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';  // Ensure this path is correct

class WorkScreen extends StatefulWidget {
  final TaskModel? task; // Accept a task optionally

  WorkScreen({Key? key, this.task}) : super(key: key); // Constructor

  @override
  _WorkScreenState createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  // List to hold tasks dynamically
  List<TaskModel> _tasks = [];

  // Function to add a new task from another screen
  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _tasks.add(widget.task!);
    }
  }

  // Add this method to fix your error
  void addTask(TaskModel task) {
    setState(() {
      _tasks.add(task);
    });
  }

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
      appBar: AppBar(
        automaticallyImplyLeading: false, // back icon hatane ke liye
        title: const Center(
          child: Text(
            'Work Tasks',
            style: TextStyle(
              fontWeight: FontWeight.bold, // bold text
            ),
          ),
        ),
        backgroundColor: const Color(0xFFFFFBEEE6),
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
                child: _tasks.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
                    children: [
                      const Text(
                        'No tasks yet',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10), // Adds space between the two texts
                      const Text(
                        'Tap Create a Task from the Dashboard screen to add a task.',
                        textAlign: TextAlign.center, // Centers the text horizontally
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    return CustomTaskCard(
                      task: _tasks[index],
                      onDelete: () => _deleteTask(index),
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

class CustomTaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onDelete;

  const CustomTaskCard({
    required this.task,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Format date nicely
    final dueDateFormatted = DateFormat('MMM d, yyyy – hh:mm a').format(task.dueDateTime);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Description: ${task.description}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Priority: ${task.priority} | Category: ${task.category}',
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              'Due Date: $dueDateFormatted',
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              'Repeat: ${task.repeat}',
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              'Notification: ${task.notification ? "Yes" : "No"}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align right
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFF800000)),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
