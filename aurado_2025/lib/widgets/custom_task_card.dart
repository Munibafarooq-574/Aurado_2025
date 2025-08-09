import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class CustomTaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onDelete;

  const CustomTaskCard({
    required this.task,
    required this.onDelete,
    super.key,
  });

  String getCompletedAgoText(DateTime completedTime) {
    final now = DateTime.now();
    final difference = now.difference(completedTime);

    if (difference.inSeconds < 60) {
      return 'Completed: Just now';
    } else if (difference.inMinutes < 60) {
      return 'Completed: ${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return 'Completed: ${difference.inHours} hours ago';
    } else {
      return 'Completed: ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'Priority: ${task.priority ?? 'None'} | Category: ${task.category ?? 'None'}',
              style: const TextStyle(fontSize: 13),
            ),

            Text(
              'Due Date: $dueDateFormatted',
              style: const TextStyle(fontSize: 13),
            ),


            Text(
              'Repeat: ${task.repeat ?? 'None'}',
              style: const TextStyle(fontSize: 13),
            ),

            Text(
              'Notification: ${task.notification ? "Yes" : "No"}',
              style: const TextStyle(fontSize: 13),
            ),

            // ✅ Show "Completed: x ago" only if task is completed
            if (task.isCompleted && task.completedDateTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  getCompletedAgoText(task.completedDateTime!),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
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