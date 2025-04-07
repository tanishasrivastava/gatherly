import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onChanged;

  const TaskItem({
    required this.task,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(
        task.name, // ✅ was task.title
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          decoration: task.isCompleted ? TextDecoration.lineThrough : null, // ✅ was task.isDone
        ),
      ),
      subtitle: Text(
        'Assigned to: ${task.assignedTo}',
        style: TextStyle(color: Colors.grey[700]),
      ),
      value: task.isCompleted, // ✅ was task.isDone
      onChanged: onChanged,
      activeColor: Colors.teal,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: task.isCompleted ? Colors.teal[50] : Colors.white, // ✅ was task.isDone
    );
  }
}
