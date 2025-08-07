class TaskModel {
  final String id; // Unique ID for each task
  final String title;
  final String description;
  final String? category; // Made nullable
  final String? priority; // Made nullable
  final String? repeat;   // Made nullable
  final DateTime dueDateTime;
  final int minutesBefore;
  final bool notification;
  bool isCompleted;

  TaskModel({
    String? id, // Optional ID, auto-generated if not provided
    required this.title,
    required this.description,
    this.category,
    this.priority,
    this.repeat,
    required this.dueDateTime,
    required this.minutesBefore,
    required this.notification,
    this.isCompleted = false,
    int? timer, // Deprecated parameter, kept for compatibility
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  /// 🔁 Copy constructor (deep copy)
  TaskModel.copy(TaskModel other)
      : id = other.id,
        title = other.title,
        description = other.description,
        category = other.category,
        priority = other.priority,
        repeat = other.repeat,
        dueDateTime = other.dueDateTime,
        minutesBefore = other.minutesBefore,
        notification = other.notification,
        isCompleted = other.isCompleted;

  /// ✏️ Copy with optional new values (useful for editing tasks)
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? repeat,
    DateTime? dueDateTime,
    int? minutesBefore,
    bool? notification,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      repeat: repeat ?? this.repeat,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      minutesBefore: minutesBefore ?? this.minutesBefore,
      notification: notification ?? this.notification,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TaskModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}