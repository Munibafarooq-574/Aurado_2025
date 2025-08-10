import 'dart:io';

class User {
  String username;
  String email;
  File? profileImage;  // Nullable File type

  User({
    required this.username,
    required this.email,
    this.profileImage,
  });
}
