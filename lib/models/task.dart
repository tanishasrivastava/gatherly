class Task {
  final String id;
  final String name;
  final String assignedTo;
  bool isCompleted;

  Task({
    required this.id,
    required this.name,
    required this.assignedTo,
    this.isCompleted = false,
  });

  // Factory constructor to create a Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] ?? json['id'] ?? '', // Support both '_id' and 'id'
      name: json['name'],
      assignedTo: json['assignedTo'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  // Convert Task instance to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'assignedTo': assignedTo,
    'isCompleted': isCompleted,
  };

  // Clone the task (useful when updating in stateful widgets)
  Task copyWith({
    String? id,
    String? name,
    String? assignedTo,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      assignedTo: assignedTo ?? this.assignedTo,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
