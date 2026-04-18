import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/ color_utils.dart';
import '../providers/preferences_provider.dart';
import '../services/notification_service.dart';
import 'package:aurado_2025/task_manager.dart';
import '../models/task.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Real notification history list
  final List<Map<String, dynamic>> _notificationHistory = [];

  @override
  void initState() {
    super.initState();
    _buildNotificationHistory();
  }

  void _buildNotificationHistory() {
    final taskManager = Provider.of<TaskManager>(context, listen: false);
    final tasks = taskManager.tasks;
    final now = DateTime.now();

    _notificationHistory.clear();

    for (var task in tasks) {
      // Missed tasks
      if (!task.isCompleted && task.dueDateTime.isBefore(now)) {
        _notificationHistory.add({
          'title': 'Missed Task: ${task.title}',
          'time': DateFormat('hh:mm a, MMM d, y').format(task.dueDateTime),
          'type': 'missed',
          'task': task,
        });
      }
      // Due today
      else if (!task.isCompleted &&
          task.dueDateTime.day == now.day &&
          task.dueDateTime.month == now.month &&
          task.dueDateTime.year == now.year) {
        _notificationHistory.add({
          'title': 'Due Today: ${task.title}',
          'time': DateFormat('hh:mm a, MMM d, y').format(task.dueDateTime),
          'type': 'due',
          'task': task,
        });
      }
      // Upcoming tasks
      else if (!task.isCompleted && task.dueDateTime.isAfter(now)) {
        _notificationHistory.add({
          'title': 'Upcoming: ${task.title}',
          'time': DateFormat('hh:mm a, MMM d, y').format(task.dueDateTime),
          'type': 'upcoming',
          'task': task,
        });
      }
      // Completed tasks
      else if (task.isCompleted) {
        _notificationHistory.add({
          'title': 'Completed: ${task.title}',
          'time': task.completedDateTime != null
              ? DateFormat('hh:mm a, MMM d, y').format(task.completedDateTime!)
              : 'N/A',
          'type': 'completed',
          'task': task,
        });
      }
    }

    // Sort by time descending
    _notificationHistory.sort((a, b) {
      final aTask = a['task'] as TaskModel;
      final bTask = b['task'] as TaskModel;
      return bTask.dueDateTime.compareTo(aTask.dueDateTime);
    });
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'missed': return Icons.warning_amber_rounded;
      case 'due': return Icons.today;
      case 'upcoming': return Icons.upcoming;
      case 'completed': return Icons.check_circle;
      default: return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'missed': return Colors.red;
      case 'due': return Colors.orange;
      case 'upcoming': return Colors.blue;
      case 'completed': return Colors.green;
      default: return const Color(0xFF800000);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesProvider>(context);
    final now = DateTime.now();
    final day = DateFormat('EEEE').format(now);
    final date = DateFormat('MMMM d, y').format(now);
    final time = DateFormat('hh:mm a').format(now);

    return Scaffold(
      backgroundColor: fromHex(prefs.themeColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: $day, $date | Time: $time PKT',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Real task notifications
            if (_notificationHistory.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text(
                    'No notifications yet.\nCreate tasks to see reminders here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              ..._notificationHistory.map((notif) => _NotificationCard(
                title: notif['title'],
                time: notif['time'],
                type: notif['type'],
                icon: _getIcon(notif['type']),
                color: _getColor(notif['type']),
                onMarkDone: () {
                  final task = notif['task'] as TaskModel;
                  Provider.of<TaskManager>(context, listen: false)
                      .markTaskAsCompleted(task);
                  setState(() => _buildNotificationHistory());
                },
                onDismiss: () {
                  setState(() => _notificationHistory.remove(notif));
                },
              )),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await NotificationService.cancelAllNotifications();
                  setState(() => _notificationHistory.clear());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All notifications cleared.'),
                      backgroundColor: Color(0xFF800000),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800000),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Clear All',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String time;
  final String type;
  final IconData icon;
  final Color color;
  final VoidCallback onMarkDone;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.title,
    required this.time,
    required this.type,
    required this.icon,
    required this.color,
    required this.onMarkDone,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(time, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 12),
            Row(
              children: [
                if (type != 'completed')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onMarkDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF800000),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Mark Done', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                if (type != 'completed') const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF800000)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Dismiss',
                        style: TextStyle(fontSize: 13, color: Color(0xFF800000))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}