import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import ' edit_profile_screen.dart';
import 'terms_of_services_screen.dart';
import 'privacy_policy_screen.dart';
import 'signout_screen.dart';


class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  String _getInitials(String fullName) {
    List<String> parts = fullName.split(' ');
    String initials = '';
    if (parts.isNotEmpty) initials += parts[0][0].toUpperCase();
    if (parts.length > 1) initials += parts[1][0].toUpperCase();
    return initials.isNotEmpty ? initials : '?';
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF800000),
                  backgroundImage: user.profileImage != null
                      ? FileImage(user.profileImage!)
                      : null,
                  child: user.profileImage == null
                      ? Text(
                    _getInitials(user.username),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                      : null,
                ),

                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user.email,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignoutScreen(),
                  ),
                );
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
