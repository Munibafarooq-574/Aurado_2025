import 'package:flutter/material.dart';

class SignoutScreen extends StatelessWidget {
  const SignoutScreen({super.key});

  // Function to show confirmation dialog
  Future<void> _showSignOutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Color(0xFF800000)),
            ),
          ),
        ],
      ),
    );

    // If user confirmed sign out, navigate to login screen
    if (result == true) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,  // This removes the back button
        title: const Text(
          'SignOut',
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

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: const [
                  Text(
                    'Are you sure you want to sign out of your Aurado account?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showSignOutDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800000),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 40),
              Image.asset(
                'assets/signout.png',
                width: 200,
                height: 200,
              ),
              const Text(
                'Bye-Bye',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
