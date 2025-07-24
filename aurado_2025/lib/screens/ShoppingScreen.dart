import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShoppingScreen extends StatefulWidget {
  @override
  _ShoppingScreenState createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Grocery Shopping',
      'description': 'Buy vegetables, fruits, and dairy products',
      'priority': 'High',
      'day': 'Sunday, Jul 20',
      'time': '10:00 AM',
      'timer': '1 hour',
      'repeat': 'Weekly',
    },
    {
      'title': 'Buy Clothes',
      'description': 'Purchase new shirts and jeans',
      'priority': 'Medium',
      'day': 'Saturday, Jul 19', // Fixed typo 'GJul' to 'Jul'
      'time': '03:00 PM',
      'timer': '2 hours',
      'repeat': 'No',
    },
  ];

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Shopping Tasks',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold), // Fixed syntax
              ),
              const SizedBox(height: 5),
              Text(
                'Date: $day, $date | Time: $time PKT',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
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
  final Map<String, dynamic> task;
  final VoidCallback onDelete;

  const CustomTaskCard({
    required this.task,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
              task['title'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Description: ${task['description']}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Priority: ${task['priority']} | Day: ${task['day']}',
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              'Time: ${task['time']} | Timer: ${task['timer']} | Repeat: ${task['repeat']}',
              style: const TextStyle(fontSize: 13),
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