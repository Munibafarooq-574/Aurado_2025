// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'forget_password1.dart'; // Adjust path as needed
import 'newpassword_screen.dart'; // Import the NewPasswordScreen
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OTPScreen(),
    );
  }
}

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  int _seconds = 150; // 2 minutes and 30 seconds
  late Timer _timer;
  bool _otpEntered = false;
  List<String> _otp = List.filled(4, '');
  int _attempts = 0;
  final _correctOTP = '1234'; // Example correct OTP, replace with dynamic OTP if needed
  final int _maxAttempts = 5; // Set max attempts to 5
  bool _otpExpired = false; // Track OTP expiration

  @override
  void initState() {
    super.initState();
    startTimer();
    // Schedule notification after 10 minutes
    Future.delayed(Duration(seconds: 600), () {
      if (!_otpEntered && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Time expired. Please request a new OTP.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        setState(() {
          _otpExpired = true; // Mark OTP as expired when timer reaches 0
        });
        _timer.cancel();
      }
    });
  }

  void checkOTP() {
    // Check if all OTP fields are filled
    if (_otp.any((digit) => digit.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your OTP.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if OTP has expired
    if (_otpExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP has expired. Please request a new OTP.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    String enteredOTP = _otp.join();
    if (enteredOTP == _correctOTP) {
      setState(() {
        _otpEntered = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP Verified Successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
      // Navigate to NewPasswordScreen after OTP verification
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewPasswordScreen()),
        );
      });
    } else {
      setState(() {
        _attempts++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP is wrong. Attempts remaining: ${_maxAttempts - _attempts}'),
          duration: Duration(seconds: 2),
        ),
      );
      if (_attempts >= _maxAttempts) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_maxAttempts attempts completed. Please request a new OTP.'),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          _seconds = 150; // Reset timer
          _otp = List.filled(4, '');
          _attempts = 0;
          _otpEntered = false;
          _otpExpired = false; // Reset expiration status
          startTimer();
        });
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formatTime(int seconds) {
      int minutes = seconds ~/ 60;
      int remainingSeconds = seconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }

    return Scaffold(
      body: Container(
        color: Color(0xFFF5E8D4),
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
                      MaterialPageRoute(builder: (context) => ForgetPasswordScreen()),
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
                      Image.asset(
                        'assets/forget_2.png',
                        width: 250,
                        height: 250,
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'OTP Verification',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'We will send you a one-time password on this Email',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.red[700],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                              (index) => Container(
                            width: 50.0,
                            height: 50.0,
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                            child: TextField(
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 3) {
                                  FocusScope.of(context).nextFocus();
                                }
                                setState(() {
                                  _otp[index] = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        formatTime(_seconds),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextButton(
                        onPressed: _seconds > 0
                            ? null
                            : () {
                          setState(() {
                            _seconds = 150;
                            _otp = List.filled(4, '');
                            _attempts = 0;
                            _otpEntered = false;
                            _otpExpired = false; // Reset expiration status
                            startTimer();
                          });
                        },
                        child: Text(
                          'Do not receive OTP? Send OTP',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: _seconds > 0 ? Colors.grey : Colors.orange[700],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          checkOTP();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF800000),
                          minimumSize: Size(double.infinity, 50.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: Text(
                          'Submit',
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