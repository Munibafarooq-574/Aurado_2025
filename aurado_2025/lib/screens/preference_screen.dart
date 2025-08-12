import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/preferences_provider.dart';
import 'account_screen.dart';
import '../constants/ color_utils.dart';


class PreferenceScreen extends StatelessWidget {
  const PreferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesProvider>(context);

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
            _buildSectionTitle("Appearance"),
            _buildDropdownCard(
              label: "Theme Color",
              value: prefs.themeColorName,
              items: PreferencesProvider.colorThemes.keys.toList(),
              onChanged: (name) {
                if (name != null) {
                  String? selectedHex = PreferencesProvider.colorThemes[name];
                  if (selectedHex != null) {
                    prefs.updatePreferences(themeColor: selectedHex);
                  }
                }
              },
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Language Settings"),
            _buildDropdownCard(
              label: "Language",
              value: prefs.language,
              items: ['English', 'Urdu'],
              onChanged: (val) => prefs.updatePreferences(language: val),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("Task Preferences"),
            _buildDropdownCard(
              label: "Task Priority",
              value: prefs.taskPriority,
              items: ['Low', 'Medium', 'High', 'All'],
              onChanged: (val) => prefs.updatePreferences(taskPriority: val),
            ),
            const SizedBox(height: 10),
            _buildDropdownCard(
              label: "Task Sorting",
              value: prefs.taskSorting,
              items: ['By Priority', 'By Due Date'],
              onChanged: (val) => prefs.updatePreferences(taskSorting: val),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("Other Settings"),
            SwitchListTile(
              title: const Text('Notifications'),
              value: prefs.notifications,
              onChanged: (val) => prefs.updatePreferences(notifications: val),
            ),
            SwitchListTile(
              title: const Text('Sync with Cloud'),
              value: prefs.syncWithCloud,
              onChanged: (val) => prefs.updatePreferences(syncWithCloud: val),
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
                    _showSaveConfirmation(context, prefs); // Pass prefs here
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

  // Save confirmation dialog
  void _showSaveConfirmation(BuildContext context, PreferencesProvider prefs) {
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff800000),
            ),
            onPressed: () {
              prefs.updatePreferences(); // Save to SharedPreferences
              Navigator.pop(context); // Close confirmation dialog
              _showSuccessDialog(context);
            },
            child: const Text('Yes, Save'),
          ),
        ],
      ),
    );
  }


  // Success dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AccountScreen()),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
