import 'package:flutter/material.dart';
import 'terms_of_services_screen.dart'; // Ensure this file exists
import 'privacy_policy_screen.dart';    // Ensure this file exists

class AccountScreen extends StatelessWidget {
  final String initial; // For the profile icon (e.g., "MF")
  final String name;   // For the user's full name
  final String email;  // For the user's email

  const AccountScreen({
    super.key,
    required this.initial,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF800000),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Menu Options
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Implement Edit Profile navigation or functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications Setting'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Implement Notifications navigation or functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('FAQs/Help Centre'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Implement FAQs/Help Centre navigation or functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Preferences'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Implement Preferences navigation or functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Implement Sign Out functionality
              },
            ),
            const SizedBox(height: 24),
            // Footer Links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsOfServiceScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Terms of Service',
                    style: TextStyle(color: Color(0xFF800000), fontSize: 14),
                  ),
                ),
                const SizedBox(width: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Privacy Policy',
                    style: TextStyle(color: Color(0xFF800000), fontSize: 14),
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