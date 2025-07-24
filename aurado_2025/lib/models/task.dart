class TaskModel {
  final String title;
  final String description;
  final String category;
  final String priority;
  final String repeat;
  final DateTime dueDateTime;
  final int minutesBefore;
  final bool notification;
  bool isCompleted;

  TaskModel({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.repeat,
    required this.dueDateTime,
    required this.minutesBefore,
    required this.notification,
    this.isCompleted = false,
  });

  // Copy constructor
  TaskModel.copy(TaskModel other)
      : this(
    title: other.title,
    description: other.description,
    category: other.category,
    priority: other.priority,
    repeat: other.repeat,
    dueDateTime: other.dueDateTime,
    minutesBefore: other.minutesBefore,
    notification: other.notification,
    isCompleted: other.isCompleted,
  );
}
