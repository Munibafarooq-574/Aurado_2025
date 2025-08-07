import 'package:flutter/foundation.dart';
import '../models/task.dart';  // Ensure this path is correct


class TaskManager extends ChangeNotifier {

  static final TaskManager _instance = TaskManager._internal();

  factory TaskManager() => _instance;

  TaskManager._internal();

  final List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => List.unmodifiable(_tasks);


  void addTask(TaskModel task) {
    _tasks.add(task);
    notifyListeners();
  }

  void removeTask(TaskModel task) {
    _tasks.remove(task);
    notifyListeners();
  }

  List<TaskModel> getTodayTasks() {
    final now = DateTime.now();
    return _tasks.where((task) {
      return task.dueDateTime.year == now.year &&
          task.dueDateTime.month == now.month &&
          task.dueDateTime.day == now.day;
    }).toList();
  }

  List<TaskModel> getUpcomingTasks() {
    final now = DateTime.now();
    return _tasks.where((task) {
      final taskDate = DateTime(task.dueDateTime.year, task.dueDateTime.month, task.dueDateTime.day);
      final today = DateTime(now.year, now.month, now.day);
      return taskDate.isAfter(today);
    }).toList();
  }



  List<TaskModel> getTasksByCategory(String category) {
    return _tasks.where((task) => task.category == category).toList();
  }

  void updateTask(TaskModel oldTask, TaskModel newTask) {
    final index = _tasks.indexOf(oldTask);
    if (index != -1) {
      _tasks[index] = newTask;
      notifyListeners();
    }
  }
}
