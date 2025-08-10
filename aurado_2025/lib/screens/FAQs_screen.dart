import 'package:flutter/material.dart';

class FAQsScreen extends StatefulWidget {
  @override
  _FAQsScreenState createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen> {
  bool _whatIsThisAbout = false;
  bool _howToAddTask = false;
  bool _canSetNotifications = false;
  bool _howToDeleteTask = false;
  bool _canSyncDevices = false;
  bool _howToMarkComplete = false;
  bool _howToEditTask = false;
  bool _canCategorizeTasks = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFfbeee6),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'FAQs / Help Center',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
            letterSpacing: 1.1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.black,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFAQItem(
            'What is this app about?',
            _whatIsThisAbout,
            'This app, Aurado, helps you manage tasks, set reminders, and stay organized with a simple interface.',
                (value) => setState(() => _whatIsThisAbout = value),
          ),
          _buildFAQItem(
            'How do I add a task?',
            _howToAddTask,
            'Go to the \'Dashboard\' section, click the \'create a task\' button, and fill in the task details like title and due date.',
                (value) => setState(() => _howToAddTask = value),
          ),
          _buildFAQItem(
            'Can I set notifications?',
            _canSetNotifications,
            'Yes, navigate to \'Account\', enable notifications, and set your preferred time for alerts.',
                (value) => setState(() => _canSetNotifications = value),
          ),
          _buildFAQItem(
            'How do I delete a task?',
            _howToDeleteTask,
            'Open the task in the \'Dashboard\', click the delete icon, and confirm to remove it from your task list.',
                (value) => setState(() => _howToDeleteTask = value),
          ),
          _buildFAQItem(
            'Can I sync with other devices?',
            _canSyncDevices,
            'Yes, log in with your Aurado account to sync tasks across all your devices seamlessly.',
                (value) => setState(() => _canSyncDevices = value),
          ),
          _buildFAQItem(
            'How do I mark a task as complete?',
            _howToMarkComplete,
            'Open the task in the \'Dashboard\' and toggle the completion checkbox to mark it as done.',
                (value) => setState(() => _howToMarkComplete = value),
          ),
          _buildFAQItem(
            'How do I edit a task?',
            _howToEditTask,
            'Go to the \'Dashboard\', select the task, click the edit icon, and update the details like title or due date.',
                (value) => setState(() => _howToEditTask = value),
          ),
          _buildFAQItem(
            'Can I categorize my tasks?',
            _canCategorizeTasks,
            'Yes, in Aurado, add categories like Work, Personal, or Shopping while creating or editing a task.',
                (value) => setState(() => _canCategorizeTasks = value),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, bool isExpanded, String answer, Function(bool) onChanged) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(Icons.help_outline, color: Color(0xFF800000)),
              title: Text(
                question,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              trailing: Transform.scale(
                scale: 0.8, // scale down switch to 80% size
                child: Switch(
                  activeColor: const Color(0xFF800000),
                  value: isExpanded,
                  onChanged: onChanged,
                ),
              ),
            ),
            if (isExpanded)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                alignment: Alignment.centerLeft,
                child: Text(
                  answer,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                    height: 1.3,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}
