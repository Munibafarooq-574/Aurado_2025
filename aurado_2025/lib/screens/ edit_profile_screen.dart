import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _profileImage;
  final picker = ImagePicker();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();



  @override
  void initState() {
    super.initState();
    // Provider se current user data load karo aur controllers mein set karo
    final user = Provider.of<UserProvider>(context, listen: false).user;

    // Assuming username is like "FirstName LastName"
    List<String> names = user.username.split(' ');
    _firstNameController.text = names.isNotEmpty ? names[0] : '';
    _lastNameController.text = names.length > 1 ? names[1] : '';
    _emailController.text = user.email;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // 1. _isPasswordStrong ko yahan define karo (class level method)
  bool _isPasswordStrong(String pwd) {
    if (pwd.length < 6) return false;
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(pwd)) return false; // uppercase check
    if (!RegExp(r'(?=.*[0-9])').hasMatch(pwd)) return false; // digit check
    if (!RegExp(r'(?=.*[!@#$%^&*])').hasMatch(pwd)) return false; // special char check
    return true;
  }

  // Toggle this for testing or real initials
  bool testingMode = true;

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xff800000), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Picture'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_profileImage != null) // Only show remove option if image exists
                ListTile(
                  leading: const Icon(Icons.delete, color: Color(0xff800000)),
                  title: const Text(
                    'Remove Picture',
                    style: TextStyle(color: Color(0xff800000)),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _profileImage = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  String _getInitials(String firstName, String lastName) {
    String firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    String initials = firstInitial + lastInitial;
    return initials.isNotEmpty ? initials : '?';
  }

  Future<bool?> _showSaveConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Save'),
        content: const Text('Are you sure you want to save changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false), // No
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true), // Yes
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Edit Profile',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF800000),
                  backgroundImage:
                  _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? (testingMode
                      ? const Text(
                    'MF',
                    style:
                    TextStyle(fontSize: 30, color: Colors.white),
                  )
                      : Text(
                    _getInitials(
                      _firstNameController.text,
                      _lastNameController.text,
                    ),
                    style: const TextStyle(
                        fontSize: 30, color: Colors.white),
                  ))
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: _showImageSourceDialog,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: _inputDecoration('First Name'),
                    controller: _firstNameController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: _inputDecoration('Last Name'),
                    controller: _lastNameController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            TextField(
              decoration: _inputDecoration('E-mail'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 50),
            TextField(
              decoration: _inputDecoration('Current Password'),
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 50),
            TextField(
              decoration: _inputDecoration('New Password'),
              controller: _newPasswordController,
              obscureText: true,
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff800000),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      // Same validations here...
                      final firstName = _firstNameController.text.trim();
                      final lastName = _lastNameController.text.trim();
                      final email = _emailController.text.trim();
                      final password = _passwordController.text;
                      final newPassword = _newPasswordController.text;

                      // Required fields check
                      if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all required fields')),
                        );
                        return;
                      }

                      // Email validation
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(email)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid email address')),
                        );
                        return;
                      }

                      // Password validation
                      if (newPassword.isNotEmpty) {
                        if (password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter your current password')),
                          );
                          return;
                        }
                        if (newPassword == password) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('New password cannot be same as current password. Please change it.')),
                          );
                          return;
                        }
                        if (!_isPasswordStrong(newPassword)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('New password is not strong enough')),
                          );
                          return;
                        }
                      }

                      // Show confirmation dialog before saving
                      final confirmed = await _showSaveConfirmationDialog();
                      if (confirmed != true) {
                        // User pressed No or dismissed dialog
                        return;
                      }


                      // Combine firstName and lastName as username
                      String updatedUsername = "$firstName $lastName";

                      // Update provider data
                      userProvider.updateUser(
                        username: updatedUsername,
                        email: email,
                      );
                      // If confirmed = true, proceed with saving
                      // Update user profile here, then show success snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile saved successfully!')),
                      );

                      // Example: Notify HomeScreen to update avatar/name
                      // This depends on your app architecture.
                      // If HomeScreen is parent, you can pass back data using Navigator.pop:
                      Navigator.pop(context, {
                        'firstName': firstName,
                        'lastName': lastName,
                        'profileImage': _profileImage,
                      });
                    },

                    child: const Text('Save'),
                  ),
                ),
                SizedBox(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
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