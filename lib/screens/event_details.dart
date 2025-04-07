import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/task.dart';
import 'create_event.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;
  final void Function(Event) onUpdate;
  final void Function(String) onDelete;

  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedEvent = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateEventScreen(existingEvent: event),
                ),
              );

              if (updatedEvent != null && updatedEvent is Event) {
                onUpdate(updatedEvent);
                Navigator.pop(context, updatedEvent); // Pass updated event back to HomeScreen
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              onDelete(event.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(event.description, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("📍 Location: ${event.location}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("📅 Date: ${event.date.toLocal().toString().split(' ')[0]}", style: const TextStyle(fontSize: 16)),
            const Divider(height: 30),
            const Text("👥 Invitees", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Wrap(
              spacing: 8,
              children: event.invitees.map((i) => Chip(label: Text(i))).toList(),
            ),
            const SizedBox(height: 20),
            const Text("📋 Tasks", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ...event.tasks.map((Task task) {
              return ListTile(
                title: Text(task.name),
                subtitle: Text("Assigned to: ${task.assignedTo}"),
                trailing: Icon(
                  task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: task.isCompleted ? Colors.green : Colors.grey,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
