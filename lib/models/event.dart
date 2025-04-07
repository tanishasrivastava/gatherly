import 'task.dart';

class Event {
  final String id;
  String title;
  String description;
  DateTime date;
  String location;
  List<String> invitees;
  List<Task> tasks;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.invitees,
    required this.tasks,
  });

  // Convert Event instance to JSON
  Map<String, dynamic> toJson() => {
    'id': id, // ✅ Include ID
    'title': title,
    'description': description,
    'date': date.toIso8601String(),
    'location': location,
    'invitees': invitees,
    'tasks': tasks.map((t) => t.toJson()).toList(),
  };

  // Create Event instance from JSON
  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json['_id'] ?? json['id'] ?? '', // ✅ Handles both MongoDB and local format
    title: json['title'],
    description: json['description'],
    date: DateTime.parse(json['date']),
    location: json['location'],
    invitees: List<String>.from(json['invitees']),
    tasks: (json['tasks'] as List).map((t) => Task.fromJson(t)).toList(),
  );
}
