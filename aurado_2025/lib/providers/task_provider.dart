import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> tasks = [];

  void addTask(Task task) {
    tasks.add(task);
    notifyListeners();
  }
}