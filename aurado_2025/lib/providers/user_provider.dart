import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User _user = User(username: "Muniba", email: "muniba@example.com");

  User get user => _user;

  void updateUser({String? username, String? email}) {
    if (username != null) _user.username = username;
    if (email != null) _user.email = email;
    notifyListeners();  // UI ko update karne ke liye
  }
}
