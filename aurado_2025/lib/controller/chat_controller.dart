import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatController {
  static final ChatController _instance = ChatController._internal();

  factory ChatController() => _instance;

  ChatController._internal();

  String? _currentEmail;

  List<Map<String, String>> _messages = [];

  /// Call after login/signup
  Future<void> setCurrentUser(String email) async {
    _currentEmail = email.trim().toLowerCase();
    await _loadMessages();
  }

  /// Logout
  void clearCurrentUser() {
    _currentEmail = null;
    _messages = [];
  }

  List<Map<String, String>> get messages => _messages;

  /// Add new message
  Future<void> addMessage({
    required String sender,
    required String text,
  }) async {
    _messages.add({
      "sender": sender,
      "text": text,
    });

    await _saveMessages();
  }

  /// Remove all messages of current user
  Future<void> clearChat() async {
    _messages.clear();
    await _saveMessages();
  }

  Future<void> _loadMessages() async {
    if (_currentEmail == null) return;

    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString("chat_$_currentEmail");

    if (data == null) {
      _messages = [];
      return;
    }

    final List decoded = jsonDecode(data);

    _messages = decoded
        .map<Map<String, String>>(
          (e) => Map<String, String>.from(e),
    )
        .toList();
  }

  Future<void> _saveMessages() async {
    if (_currentEmail == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      "chat_$_currentEmail",
      jsonEncode(_messages),
    );
  }
}