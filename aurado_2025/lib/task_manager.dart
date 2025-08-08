import 'package:flutter/foundation.dart';
import '../models/task.dart';

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
    _tasks.removeWhere((t) => t.id == task.id);
    notifyListeners();
  }

  List<TaskModel> getMissedTasks() {
    final now = DateTime.now();
    return _tasks.where((task) {
      return !task.isCompleted && task.dueDateTime.isBefore(now);
    }).toList();
  }
  List<TaskModel> getTodayTasks() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(Duration(days: 1));

    return _tasks.where((task) {
      final due = task.dueDateTime;
      return !task.isCompleted &&
          (due.isAfter(now) || due.isAtSameMomentAs(now)) &&
          due.isBefore(todayEnd);
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

  void markTaskAsCompleted(TaskModel task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final now = DateTime.now();
      final updatedTask = _tasks[index].copyWith(
        isCompleted: true,
        completedDateTime: now,
      );
      _tasks[index] = updatedTask;
      print('Task "${task.title}" marked completed at $now');
      print('Updated task: isCompleted=${updatedTask.isCompleted}, completedDateTime=${updatedTask.completedDateTime}');
      notifyListeners();
    } else {
      print('Task not found to mark complete: ${task.title}');
    }
  }

  void markTaskAsIncomplete(TaskModel task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final updatedTask = _tasks[index].copyWith(
        isCompleted: false,
        completedDateTime: null,
      );
      _tasks[index] = updatedTask;
      print('Task "${task.title}" marked incomplete');
      notifyListeners();
    } else {
      print('Task not found to mark incomplete: ${task.title}');
    }
  }



  List<TaskModel> getCompletedTasks() {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  List<TaskModel> getTasksByCategory(String category) {
    return _tasks.where((task) => task.category == category).toList();
  }

  void updateTask(TaskModel oldTask, TaskModel newTask) {
    final index = _tasks.indexWhere((task) => task.id == oldTask.id);
    if (index != -1) {
      _tasks[index] = newTask;
      notifyListeners();
    }
  }
}