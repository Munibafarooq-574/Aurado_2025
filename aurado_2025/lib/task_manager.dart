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
    print('TaskManager: Added task "${task.title}", Total tasks: ${_tasks.length}');
    notifyListeners();
  }

  void removeTask(TaskModel task) {
    _tasks.removeWhere((t) => t.id == task.id);
    print('TaskManager: Removed task "${task.title}", Total tasks: ${_tasks.length}');
    notifyListeners();
  }

  List<TaskModel> getMissedTasks() {
    final now = DateTime.now();
    final missed = _tasks.where((task) {
      return !task.isCompleted && task.dueDateTime.isBefore(now);
    }).toList();
    print('TaskManager: Fetched ${missed.length} missed tasks');
    return missed;
  }

  List<TaskModel> getTodayTasks() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final filteredTasks = _tasks.where((task) {
      final due = task.dueDateTime;
      return !task.isCompleted &&
          (due.isAfter(now) || due.isAtSameMomentAs(now)) &&
          due.isBefore(todayEnd);
    }).toList();

    filteredTasks.sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
    print('TaskManager: Fetched ${filteredTasks.length} today tasks');
    return filteredTasks;
  }

  List<TaskModel> getUpcomingTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcoming = _tasks.where((task) {
      final taskDate = DateTime(task.dueDateTime.year, task.dueDateTime.month, task.dueDateTime.day);
      return taskDate.isAfter(today) && !task.isCompleted;
    }).toList();

    upcoming.sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
    print('TaskManager: Fetched ${upcoming.length} upcoming tasks');
    return upcoming;
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
      print('TaskManager: Task "${task.title}" marked completed at $now');
      notifyListeners();
    } else {
      print('TaskManager: Task not found to mark complete: ${task.title}');
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
      print('TaskManager: Task "${task.title}" marked incomplete');
      notifyListeners();
    } else {
      print('TaskManager: Task not found to mark incomplete: ${task.title}');
    }
  }

  List<TaskModel> getCompletedTasks() {
    final completed = _tasks.where((task) => task.isCompleted).toList();
    print('TaskManager: Fetched ${completed.length} completed tasks');
    return completed;
  }

  List<TaskModel> getTasksByCategory(String category) {
    final categoryTasks = _tasks.where((task) => task.category == category).toList();
    print('TaskManager: Fetched ${categoryTasks.length} tasks for category: $category');
    return categoryTasks;
  }

  void updateTask(TaskModel oldTask, TaskModel newTask) {
    final index = _tasks.indexWhere((task) => task.id == oldTask.id);
    if (index != -1) {
      _tasks[index] = newTask;
      print('TaskManager: Updated task "${oldTask.title}" to "${newTask.title}"');
      notifyListeners();
    }
  }
}