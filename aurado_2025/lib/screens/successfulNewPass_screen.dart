// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'newpassword_screen.dart'; // Adjust path as needed for navigation back to NewPasswordScreen
import 'login_screen.dart'; // Import the LoginScreen
import 'package:provider/provider.dart';
import '../providers/preferences_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SuccessfulNewPassScreen(),
    );
  }
}


Color hexToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

class SuccessfulNewPassScreen extends StatelessWidget {
  const SuccessfulNewPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencesProvider = Provider.of<PreferencesProvider>(context);
    final backgroundColorHex = preferencesProvider.themeColor;
    return Scaffold(
      body: Container(
        color:  hexToColor(backgroundColorHex),
        padding: EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF9B2C2C)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewPasswordScreen()),
                    );
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 30.0), // Matching the downward shift from NewPasswordScreen
                      Image.asset(
                        'assets/forget_4.png', // Use the provided image
                        width: 250.0, // Matching NewPasswordScreen image size
                        height: 250.0, // Matching NewPasswordScreen image size
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Password Changed Successfully!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'You can now log in with your new password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF800000),
                          minimumSize: Size(double.infinity, 50.0), // Matching button size
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: Text(
                          'Go to Login',
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}