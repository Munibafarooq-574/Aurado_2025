import 'package:flutter/material.dart';
import 'account_screen.dart';
class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  String _theme = 'Light';
  String _language = 'Urdu';
  String _taskPriority = 'High';
  String _taskSorting = 'By Due Date';
  bool _notifications = false;
  bool _syncWithCloud = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Preferences',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
            letterSpacing: 1.1,
          ),
        ),
        backgroundColor: const Color(0xFFfbeee6),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Appearance"),
            _buildDropdownCard(
              label: "Theme",
              value: _theme,
              items: ['Light', 'Dark'],
              onChanged: (newValue) => setState(() => _theme = newValue!),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("Language Settings"),
            _buildDropdownCard(
              label: "Language",
              value: _language,
              items: ['English', 'Urdu'],
              onChanged: (newValue) => setState(() => _language = newValue!),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("Task Preferences"),
            _buildDropdownCard(
              label: "Task Priority",
              value: _taskPriority,
              items: ['Low', 'Medium', 'High', 'All'],
              onChanged: (newValue) => setState(() => _taskPriority = newValue!),
            ),
            const SizedBox(height: 10),
            _buildDropdownCard(
              label: "Task Sorting",
              value: _taskSorting,
              items: ['By Priority', 'By Due Date'],
              onChanged: (newValue) => setState(() => _taskSorting = newValue!),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("Other Settings"),
            SwitchListTile(
              title: const Text('Notifications'),
              value: _notifications,
              onChanged: (bool value) {
                setState(() => _notifications = value);
              },
            ),
            SwitchListTile(
              title: const Text('Sync with Cloud'),
              value: _syncWithCloud,
              onChanged: (bool value) {
                setState(() => _syncWithCloud = value);
              },
            ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff800000),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
      onPressed: () {
        // Confirmation dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Row(
              children: const [
                Icon(Icons.save, color: Color(0xff800000)),
                SizedBox(width: 8),
                Text('Confirm Save'),
              ],
            ),
            content: const Text('Do you want to save these changes?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Close confirmation dialog
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff800000),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close confirmation dialog

                  // Show success dialog (no auto-close)
                  showDialog(
                    context: context,
                    barrierDismissible: false, // prevent tap outside to close
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Saved Successfully'),
                        ],
                      ),
                      content: const Text('Your preferences have been updated.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close success dialog
                            // Navigate to AccountScreen after closing success dialog
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const AccountScreen()),
                            );
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Yes, Save'),
              ),
            ],
          ),
        );
      },

      child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // Card-styled dropdown
  Widget _buildDropdownCard({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
