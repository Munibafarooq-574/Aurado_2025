class Task {
  final String title;
  final String description;
  final DateTime deadline;
  final String priority;
  final String category;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.category,
    this.isCompleted = false,
  });

  // Copy constructor
  Task.copy(Task other)
      : this(
    title: other.title,
    description: other.description,
    deadline: other.deadline,
    priority: other.priority,
    category: other.category,
    isCompleted: other.isCompleted,
  );
}