import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<TaskModel> tasks = [];

  void addTask(TaskModel task) {
    tasks.add(task);
    notifyListeners();
  }
}