// notification_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/preferences_provider.dart';
import '../constants/ color_utils.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _taskReminders = true;
  bool _dueDateAlerts = true;
  bool _missedTaskAlerts = true;
  bool _dailySummary = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _reminderTime = '15 minutes before';
  String _summaryTime = '9:00 AM';

  final List<String> _reminderOptions = [
    '5 minutes before',
    '10 minutes before',
    '15 minutes before',
    '30 minutes before',
    '1 hour before',
    '1 day before',
  ];

  final List<String> _summaryTimeOptions = [
    '7:00 AM',
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '12:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        backgroundColor: fromHex(prefs.themeColor),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Notifications
            _buildSectionTitle('General'),
            _buildCard([
              _buildSwitchTile(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                subtitle: 'Enable all notifications',
                value: _pushNotifications,
                onChanged: (val) => setState(() => _pushNotifications = val),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.volume_up,
                title: 'Sound',
                subtitle: 'Play sound for notifications',
                value: _soundEnabled,
                onChanged: _pushNotifications
                    ? (val) => setState(() => _soundEnabled = val)
                    : null,
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.vibration,
                title: 'Vibration',
                subtitle: 'Vibrate for notifications',
                value: _vibrationEnabled,
                onChanged: _pushNotifications
                    ? (val) => setState(() => _vibrationEnabled = val)
                    : null,
              ),
            ]),

            const SizedBox(height: 20),

            // Task Notifications
            _buildSectionTitle('Task Alerts'),
            _buildCard([
              _buildSwitchTile(
                icon: Icons.task_alt,
                title: 'Task Reminders',
                subtitle: 'Get reminded before task due time',
                value: _taskReminders,
                onChanged: _pushNotifications
                    ? (val) => setState(() => _taskReminders = val)
                    : null,
              ),
              _buildDivider(),
              if (_taskReminders && _pushNotifications)
                _buildDropdownTile(
                  icon: Icons.timer,
                  title: 'Reminder Time',
                  value: _reminderTime,
                  items: _reminderOptions,
                  onChanged: (val) => setState(() => _reminderTime = val!),
                ),
              if (_taskReminders && _pushNotifications) _buildDivider(),
              _buildSwitchTile(
                icon: Icons.calendar_today,
                title: 'Due Date Alerts',
                subtitle: 'Alert when task is due today',
                value: _dueDateAlerts,
                onChanged: _pushNotifications
                    ? (val) => setState(() => _dueDateAlerts = val)
                    : null,
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.warning_amber_rounded,
                title: 'Missed Task Alerts',
                subtitle: 'Notify when a task is missed',
                value: _missedTaskAlerts,
                onChanged: _pushNotifications
                    ? (val) => setState(() => _missedTaskAlerts = val)
                    : null,
              ),
            ]),

            const SizedBox(height: 20),

            // Daily Summary
            _buildSectionTitle('Daily Summary'),
            _buildCard([
              _buildSwitchTile(
                icon: Icons.summarize,
                title: 'Daily Summary',
                subtitle: 'Get a daily overview of your tasks',
                value: _dailySummary,
                onChanged: _pushNotifications
                    ? (val) => setState(() => _dailySummary = val)
                    : null,
              ),
              if (_dailySummary && _pushNotifications) _buildDivider(),
              if (_dailySummary && _pushNotifications)
                _buildDropdownTile(
                  icon: Icons.access_time,
                  title: 'Summary Time',
                  value: _summaryTime,
                  items: _summaryTimeOptions,
                  onChanged: (val) => setState(() => _summaryTime = val!),
                ),
            ]),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800000),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification settings saved!'),
                      backgroundColor: Color(0xFF800000),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Save Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF800000)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF800000),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF800000)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
}