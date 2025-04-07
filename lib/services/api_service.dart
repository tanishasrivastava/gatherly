import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // use 10.0.2.2 for Android emulator

  // Fetch all events
  static Future<List<Event>> fetchEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/events'));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  // Create a new event
  static Future<bool> createEvent(Event event) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(event.toJson()),
    );

    return response.statusCode == 201;
  }

  // Add task to event
  static Future<bool> addTask(String eventId, Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events/$eventId/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );

    return response.statusCode == 200;
  }

  // Update task completion
  static Future<bool> toggleTask(String eventId, String taskId, bool isDone) async {
    final response = await http.put(
      Uri.parse('$baseUrl/events/$eventId/tasks/$taskId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'isCompleted': isDone}),
    );

    return response.statusCode == 200;
  }
}
