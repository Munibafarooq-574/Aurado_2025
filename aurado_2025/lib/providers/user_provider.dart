import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User _user = User(username: "Muniba", email: "muniba@example.com");

  User get user => _user;


  void updateUser({String? username, String? email, File? profileImage, bool clearProfileImage = false}) {
    if (username != null) _user.username = username;
    if (email != null) _user.email = email;

    if (clearProfileImage) {
      _user.profileImage = null;
    } else if (profileImage != null) {
      _user.profileImage = profileImage;
    }
    notifyListeners();
  }

}
