// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'otp_screen.dart'; // Adjust path as needed for navigation back to OTP screen
import 'successfulNewPass_screen.dart'; // Import the new success screen
import '../providers/preferences_provider.dart';
import 'package:provider/provider.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NewPasswordScreen(),
    );
  }
}

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _passwordStrength = '';
  bool _obscureNewPassword = true; // Toggle for New Password visibility
  bool _obscureConfirmPassword = true; // Toggle for Confirm Password visibility

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _checkPasswordStrength(String password) {
    if (password.isEmpty) return '';

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#\$&*~]'));
    int length = password.length;

    if (length < 6) return 'Weak';

    int conditionsMet = 0;
    if (hasUppercase) conditionsMet++;
    if (hasDigits) conditionsMet++;
    if (hasSpecial) conditionsMet++;

    if (length >= 8 && conditionsMet == 3) {
      return 'Strong';
    } else if (length >= 6 && conditionsMet >= 2) {
      return 'Medium';
    } else {
      return 'Weak';
    }
  }


  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  void _resetPassword() {
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter password.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Add password reset logic here (e.g., API call)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password reset successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
    // Navigate to SuccessfulNewPassScreen after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SuccessfulNewPassScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isNewPasswordEmpty = _newPasswordController.text.isEmpty;
    final preferencesProvider = Provider.of<PreferencesProvider>(context);
    final backgroundColorHex = preferencesProvider.themeColor;

    return Scaffold(
      body: Container(
        color: hexToColor(backgroundColorHex),
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
                      MaterialPageRoute(builder: (context) => OTPScreen()),
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
                      SizedBox(height: 30.0), // Added to shift content downward
                      Text(
                        'Change New Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Choose a new password that you haven\'t used before.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        onChanged: (value) {
                          setState(() {
                            _passwordStrength = _checkPasswordStrength(value);
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        _passwordStrength.isNotEmpty ? 'Strength: $_passwordStrength' : '',
                        style: TextStyle(
                          color: _passwordStrength == 'Weak'
                              ? Colors.red
                              : _passwordStrength == 'Medium'
                              ? Colors.orange
                              : _passwordStrength == 'Strong'
                              ? Colors.green
                              : Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(height: 15.0),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Image.asset(
                        'assets/forget_3.png', // Use the provided image
                        width: 250, // Matches OTP screen
                        height: 250, // Matches OTP screen
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: isNewPasswordEmpty ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF800000),
                          minimumSize: Size(double.infinity, 50.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          // Disable button style when new password is empty
                          foregroundColor: isNewPasswordEmpty ? Colors.grey : Colors.white,
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                        child: Text(
                          'Reset Password',
                          style: TextStyle(fontSize: 16.0, color: isNewPasswordEmpty ? Colors.black54 : Colors.white),
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