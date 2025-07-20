// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/progress_chart.dart';
import '../widgets/task_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String? userName = 'Muniba';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(Task task) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('task_channel', 'Task Reminders',
        importance: Importance.max, priority: Priority.high, channelDescription: 'Task reminders');
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Task Reminder',
      'Time for ${task.title}',
      platformChannelSpecifics,
      payload: task.title,
    );
  }

  void _showPlaceholderScreen(String screenName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigation to $screenName will be implemented later!')),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $userName! ✨", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/character.png'),
            radius: 20,
            onBackgroundImageError: (_, __) => const Icon(Icons.person),
          ),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: Color(0xFF800000)),
            onPressed: () => _showPlaceholderScreen('ChatbotScreen'),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Color(0xFF800000)),
            onPressed: () => _showPlaceholderScreen('SettingsScreen'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: "Today"), Tab(text: "Upcoming"), Tab(text: "Completed"), Tab(text: "Missed")],
          indicatorColor: Color(0xFF800000),
          labelColor: Color(0xFF800000),
          unselectedLabelColor: Colors.grey,
        ),
        flexibleSpace: Container(
          padding: EdgeInsets.only(top: 10),
          child: TextField(
            onChanged: (value) {
              final taskProvider = Provider.of<TaskProvider>(context, listen: false);
              taskProvider.filterTasks(value);
            },
            decoration: InputDecoration(
              hintText: "Search tasks...",
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              filled: true,
              // ignore: deprecated_member_use
              fillColor: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(taskProvider.filterTasks("").where((task) => task.deadline.day == DateTime.now().day).toList()),
                _buildTaskList(taskProvider.filterTasks("").where((task) => task.deadline.isAfter(DateTime.now())).toList()),
                _buildTaskList(taskProvider.filterTasks("").where((task) => task.isCompleted).toList()),
                _buildTaskList(taskProvider.filterTasks("").where((task) => task.deadline.isBefore(DateTime.now()) && !task.isCompleted).toList()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showPlaceholderScreen('CalendarScreen'),
                  icon: Icon(Icons.calendar_today),
                  label: Text("Calendar"),
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF800000)),
                ),
                ProgressChart(tasks: taskProvider.tasks),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ignore: unused_local_variable
          final task = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskForm(onSave: (newTask) {
              final taskProvider = Provider.of<TaskProvider>(context, listen: false);
              taskProvider.addTask(newTask);
              _scheduleNotification(newTask);
            })),
          );
        },
        backgroundColor: Color(0xFF800000),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onToggle: (value) {
            if (value != null) {
              Provider.of<TaskProvider>(context, listen: false).toggleTaskCompletion(index);
            }
          },
          onEdit: () async {
            final taskProvider = Provider.of<TaskProvider>(context, listen: false);
            if (index >= 0 && index < taskProvider.tasks.length) {
              // ignore: unused_local_variable
              final updatedTask = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskForm(
                  task: task,
                  onSave: (newTask) {
                    taskProvider.editTask(index, newTask);
                  },
                )),
              );
            }
          },
          onDelete: () {
            final taskProvider = Provider.of<TaskProvider>(context, listen: false);
            if (index >= 0 && index < taskProvider.tasks.length) {
              taskProvider.deleteTask(index);
            }
          },
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Scaffold(body: Center(child: Text("Task Details Screen Coming Soon!")))),
          ),
        );
      },
    );
  }
}