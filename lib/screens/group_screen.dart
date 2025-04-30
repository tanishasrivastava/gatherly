import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'group_chat_screen.dart';
import 'group_polls_screen.dart'; // Import the GroupPollsScreen

class GroupScreen extends StatefulWidget {
  final Map<String, dynamic> groupData;
  final String myId;
  final String myName;

  GroupScreen({
    required this.groupData,
    required this.myId,
    required this.myName,
  });

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  late List<dynamic> members;
  Map<String, List<dynamic>> memberTasks = {};

  @override
  void initState() {
    super.initState();
    members = widget.groupData['members'] ?? [];
    memberTasks = Map<String, List<dynamic>>.from(widget.groupData['memberTasks'] ?? {});
  }

  Future<void> addTask(String memberId) async {
    TextEditingController taskController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: taskController,
          decoration: InputDecoration(
            hintText: 'Enter task',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (taskController.text.isNotEmpty) {
                await http.post(
                  Uri.parse('http://10.0.2.2:8081/api/groups/add-task'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'groupCode': widget.groupData['groupCode'],
                    'memberId': memberId,
                    'task': taskController.text.trim(),
                  }),
                );
                setState(() {
                  memberTasks.putIfAbsent(memberId, () => []).add(taskController.text.trim());
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> editTask(String memberId, String oldTask) async {
    TextEditingController editController = TextEditingController(text: oldTask);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Task', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            hintText: 'Update task',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String newTask = editController.text.trim();
              if (newTask.isNotEmpty) {
                final response = await http.post(
                  Uri.parse('http://10.0.2.2:8081/api/groups/edit-task'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'groupCode': widget.groupData['groupCode'],
                    'memberId': memberId,
                    'oldTask': oldTask,
                    'newTask': newTask,
                  }),
                );

                if (response.statusCode == 200) {
                  setState(() {
                    final tasks = memberTasks[memberId];
                    if (tasks != null) {
                      int index = tasks.indexOf(oldTask);
                      if (index != -1) {
                        tasks[index] = newTask;
                      }
                    }
                  });
                }

                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> removeTask(String memberId, String task) async {
    await http.post(
      Uri.parse('http://10.0.2.2:8081/api/groups/remove-task'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'groupCode': widget.groupData['groupCode'],
        'memberId': memberId,
        'task': task,
      }),
    );
    setState(() {
      memberTasks[memberId]?.remove(task);
    });
  }

  // Method for navigating to the Group Polls screen
  void _navigateToGroupPolls() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupPollsScreen(groupId: widget.groupData['groupCode']), // Pass groupCode to the polls screen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: Text(widget.groupData['name'] ?? 'Group'),
        backgroundColor: Colors.deepPurple.shade400,
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupChatScreen(
                    groupCode: widget.groupData['groupCode'],
                    myId: widget.myId,
                    myName: widget.myName,
                    members: members,
                  ),
                ),
              );
            },
          ),
          // IconButton to navigate to the Group Polls screen
          IconButton(
            icon: Icon(Icons.poll, color: Colors.white),
            onPressed: _navigateToGroupPolls,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: members.length,
        itemBuilder: (context, index) {
          String member = members[index];
          return Card(
            color: Colors.white,
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                member,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              children: [
                ...(memberTasks[member] ?? []).map((task) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: Colors.deepPurple.shade50,
                    title: Text(task),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => editTask(member, task),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => removeTask(member, task),
                        ),
                      ],
                    ),
                  ),
                )),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () => addTask(member),
                    icon: Icon(Icons.add),
                    label: Text('Add Task'),
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}
