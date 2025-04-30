import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'group_chat_screen.dart';

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
        title: Text('Add Task'),
        content: TextField(
          controller: taskController,
          decoration: InputDecoration(hintText: 'Enter task'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (taskController.text.isNotEmpty) {
                await http.post(
                  Uri.parse('http://10.0.2.2:8089/api/groups/add-task'),
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

  Future<void> removeTask(String memberId, String task) async {
    await http.post(
      Uri.parse('http://10.0.2.2:8089/api/groups/remove-task'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.groupData['name'] ?? 'Group'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => GroupChatScreen(
                  groupCode: widget.groupData['groupCode'],
                  myId: widget.myId,
                  myName: widget.myName,   // ✅ Passing correct myName (user's real name)
                  members: members,        // ✅ Passing list of member names
                ),
              ));
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: members.length,
        itemBuilder: (context, index) {
          String member = members[index];
          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              title: Text(member),
              children: [
                ...(memberTasks[member] ?? []).map((task) => ListTile(
                  title: Text(task),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => removeTask(member, task),
                  ),
                )),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => addTask(member),
                  icon: Icon(Icons.add),
                  label: Text('Add Task'),
                ),
                SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
