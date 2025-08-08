import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/task.dart' as task_model;
import '../task_manager.dart';

class CompletedScreen extends StatefulWidget {
  @override
  _CompletedScreenState createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {


  void _deleteTask(task_model.TaskModel task) {
    Provider.of<TaskManager>(context, listen: false).removeTask(task);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final day = DateFormat('EEEE').format(now);
    final date = DateFormat('MMMM d, y').format(now);
    final time = DateFormat('hh:mm a').format(now);

    final completedTasks = Provider.of<TaskManager>(context).getCompletedTasks();

    return Scaffold(
      backgroundColor: const Color(0xFFFBEEE6), // Light Peach background
      body: SafeArea(
        child: Padding(
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
                child:
                completedTasks.isEmpty
                    ? Center(
                  child: Text(
                    'No completed tasks yet!',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    final task = completedTasks[index];
                    return TaskCard(
                      title: task.title,
                      description: task.description,
                      time: DateFormat('hh:mm a').format(task.dueDateTime) + ' PKT',
                      color: _getColorForTask(task),
                      onDelete: () {
                        Provider.of<TaskManager>(context, listen: false).removeTask(task);
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

  Color _getColorForTask(TaskModel task) {
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

}

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final Color color;
  final VoidCallback onDelete;

  const TaskCard({
    required this.title,
    required this.description,
    required this.time,
    required this.color,
    required this.onDelete,
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
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Color(0xFF800000)),
          onPressed: onDelete,
        ),
      ),
    );
  }
}


void main() {
  runApp(MaterialApp(
    home: CompletedScreen(),
  ));
}
