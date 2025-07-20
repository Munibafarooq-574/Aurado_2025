import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  // ignore: prefer_final_fields
  List<Task> _tasks = [
    Task(
      title: "Complete Project",
      description: "Finish Flutter app development",
      deadline: DateTime.now(),
      priority: "High",
      category: "Work",
      isCompleted: false,
    ),
    Task(
      title: "Do Grocery Shopping",
      description: "Buy vegetables and fruits from the store",
      deadline: DateTime.now().add(Duration(days: 1)),
      priority: "Medium",
      category: "Shopping",
      isCompleted: false,
    ),
    Task(
      title: "Do Homework",
      description: "Complete math and science assignments",
      deadline: DateTime.now().add(Duration(days: 2)),
      priority: "High",
      category: "Personal",
      isCompleted: false,
    ),
    Task(
      title: "Review Project",
      description: "Check code and documentation",
      deadline: DateTime.now().add(Duration(days: 3)),
      priority: "Medium",
      category: "Work",
      isCompleted: false,
    ),
    Task(
      title: "Exercise Routine",
      description: "30-minute workout at home",
      deadline: DateTime.now().add(Duration(days: 1)),
      priority: "Low",
      category: "Health",
      isCompleted: false,
    ),
    Task(
      title: "Read Book",
      description: "Finish Chapter 3 of the novel",
      deadline: DateTime.now().add(Duration(days: 4)),
      priority: "Low",
      category: "Personal",
      isCompleted: false,
    ),
  ];

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void toggleTaskCompletion(int index) {
    if (index >= 0 && index < _tasks.length) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      notifyListeners();
    }
  }

  void editTask(int index, Task updatedTask) {
    if (index >= 0 && index < _tasks.length) {
      _tasks[index] = Task.copy(updatedTask);
      notifyListeners();
    }
  }

  void deleteTask(int index) {
    if (index >= 0 && index < _tasks.length) {
      _tasks.removeAt(index);
      notifyListeners();
    }
  }

  List<Task> filterTasks(String query) {
    if (query.isEmpty) {
      return _tasks; // Return all tasks
    }
    return _tasks.where((task) => task.title.toLowerCase().contains(query.toLowerCase())).toList();
  }
}