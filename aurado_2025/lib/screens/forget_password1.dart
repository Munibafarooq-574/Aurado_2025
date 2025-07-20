// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import the LoginScreen
import 'otp_screen.dart'; // Import the OTPScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ForgetPasswordScreen(),
    );
  }
}

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFF5E8D4), // Light beige background similar to the image
        padding: EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0), // Reduced top padding to move it up
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF9B2C2C)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/forget_1.png', // Increased size of the image
                          width: 250,
                          height: 250,
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          'Forget Password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Enter your registered email below',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.red[700],
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Email address',
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email, color: Color(0xFF9B2C2C)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                            RegExp regExp = RegExp(pattern);
                            if (!regExp.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Remember the password? ',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Sign in',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => OTPScreen()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter a valid email'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}