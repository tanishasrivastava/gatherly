// ✅ Updated CreateEventScreen with editing capability for existing tasks and invitees
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';

class CreateEventScreen extends StatefulWidget {
  final Event? existingEvent;

  const CreateEventScreen({super.key, this.existingEvent});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final uuid = const Uuid();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  DateTime _selectedDate = DateTime.now();

  List<String> _invitees = [];
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingEvent != null) {
      _titleController = TextEditingController(text: widget.existingEvent!.title);
      _descriptionController = TextEditingController(text: widget.existingEvent!.description);
      _locationController = TextEditingController(text: widget.existingEvent!.location);
      _selectedDate = widget.existingEvent!.date;
      _invitees = List.from(widget.existingEvent!.invitees);
      _tasks = List.from(widget.existingEvent!.tasks);
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _locationController = TextEditingController();
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newEvent = Event(
        id: widget.existingEvent?.id ?? uuid.v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        location: _locationController.text,
        invitees: _invitees,
        tasks: _tasks,
      );

      Navigator.pop(context, newEvent);
    }
  }

  void _editTask(Task task, int index) {
    TextEditingController taskNameController = TextEditingController(text: task.name);
    String assignedTo = task.assignedTo;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taskNameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            DropdownButton<String>(
              value: assignedTo,
              isExpanded: true,
              onChanged: (value) {
                if (value != null) {
                  setState(() => assignedTo = value);
                }
              },
              items: _invitees
                  .map((invitee) => DropdownMenuItem(
                value: invitee,
                child: Text(invitee),
              ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _tasks[index] = Task(
                  id: task.id,
                  name: taskNameController.text,
                  isCompleted: task.isCompleted,
                  assignedTo: assignedTo,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existingEvent != null ? 'Edit Event' : 'Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              ListTile(
                title: Text('Date: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const Divider(),
              const Text('Invitees:'),
              ..._invitees.asMap().entries.map((entry) => ListTile(
                title: Text(entry.value),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => setState(() => _invitees.removeAt(entry.key)),
                ),
              )),
              TextButton(
                onPressed: () async {
                  final name = await _showInputDialog('Add Invitee');
                  if (name != null && name.isNotEmpty) {
                    setState(() => _invitees.add(name));
                  }
                },
                child: const Text('+ Add Invitee'),
              ),
              const Divider(),
              const Text('Tasks:'),
              ..._tasks.asMap().entries.map((entry) => ListTile(
                title: Text('${entry.value.name} (To: ${entry.value.assignedTo})'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editTask(entry.value, entry.key),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(() => _tasks.removeAt(entry.key)),
                    ),
                  ],
                ),
              )),
              TextButton(
                onPressed: () async {
                  final taskName = await _showInputDialog('Task Name');
                  if (taskName != null && taskName.isNotEmpty && _invitees.isNotEmpty) {
                    String? assignedTo = await showDialog<String>(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Assign to:'),
                        children: _invitees
                            .map((invitee) => SimpleDialogOption(
                          onPressed: () => Navigator.pop(context, invitee),
                          child: Text(invitee),
                        ))
                            .toList(),
                      ),
                    );
                    if (assignedTo != null) {
                      setState(() => _tasks.add(Task(
                        id: uuid.v4(),
                        name: taskName,
                        isCompleted: false,
                        assignedTo: assignedTo,
                      )));
                    }
                  }
                },
                child: const Text('+ Add Task'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showInputDialog(String title) async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}