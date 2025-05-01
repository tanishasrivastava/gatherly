import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroupPollsScreen extends StatefulWidget {
  final String groupId;

  const GroupPollsScreen({super.key, required this.groupId});

  @override
  State<GroupPollsScreen> createState() => _GroupPollsScreenState();
}

class _GroupPollsScreenState extends State<GroupPollsScreen> {
  List<Map<String, dynamic>> polls = [];

  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchPolls();
  }

  Future<void> _fetchPolls() async {
    try {
      final res = await http.get(Uri.parse('http://10.0.2.2:8081/api/groups/${widget.groupId}/polls'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          polls = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        print("Failed to fetch polls: ${res.body}");
      }
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  Future<void> _addPoll(BuildContext dialogContext, VoidCallback refreshDialogState) async {
    String question = _questionController.text.trim();
    List<String> options = _optionControllers
        .map((c) => c.text.trim())
        .where((o) => o.isNotEmpty)
        .toList();

    if (question.isEmpty || options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter a question and at least 2 options")),
      );
      return;
    }

    final body = {
      "groupCode": widget.groupId,
      "question": question,
      "options": options,
      "userId": "user_id_here",
    };

    try {
      final res = await http.post(
        Uri.parse('http://10.0.2.2:8081/api/groups/create-poll'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        _questionController.clear();
        _optionControllers.forEach((c) => c.clear());
        Navigator.pop(dialogContext);
        _fetchPolls();
      } else {
        print("Failed to create poll: ${res.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating poll: ${res.body}")),
        );
      }
    } catch (e) {
      print("Error adding poll: $e");
    }
  }

  Future<void> _voteForOption(String pollQuestion, String option) async {
    try {
      final res = await http.post(
        Uri.parse('http://10.0.2.2:8081/api/groups/vote-poll'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "groupCode": widget.groupId,
          "pollQuestion": pollQuestion,
          "userId": "user_id_here",
          "option": option,
        }),
      );
      if (res.statusCode == 200) {
        _fetchPolls();
      }
    } catch (e) {
      print("Voting error: $e");
    }
  }

  void _showAddPollDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.deepPurple.shade100,
              title: Text("Create Poll", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        hintText: "What's your poll?",
                        filled: true,
                        fillColor: Colors.deepPurple.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(height: 12),
                    ..._optionControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: entry.value,
                                decoration: InputDecoration(
                                  hintText: "Option ${index + 1}",
                                  filled: true,
                                  fillColor: Colors.deepPurple.shade50,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            if (_optionControllers.length > 2)
                              IconButton(
                                icon: Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  setStateDialog(() {
                                    _optionControllers.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }),
                    TextButton(
                      onPressed: () {
                        setStateDialog(() {
                          _optionControllers.add(TextEditingController());
                        });
                      },
                      child: Text("+ Add Option", style: TextStyle(color: Colors.deepPurple)),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => _addPoll(dialogContext, () => setStateDialog(() {})),
                  child: Text('Add', style: TextStyle(color: Colors.pinkAccent)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPollCard(Map<String, dynamic> poll) {
    final rawVotes = Map<String, dynamic>.from(poll['votes'] ?? {});
    final options = List<String>.from(poll['options']);
    final votes = {
      for (var entry in rawVotes.entries)
        entry.key: (entry.value as List).length
    };
    final totalVotes = votes.values.fold(0, (a, b) => a + b);

    String? leadingOption;
    int maxVotes = 0;
    for (var option in options) {
      final count = votes[option] ?? 0;
      if (count > maxVotes) {
        maxVotes = count;
        leadingOption = option;
      }
    }

    return Card(
      elevation: 6,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(poll['question'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple)),
            SizedBox(height: 10),
            ...options.map((option) {
              final count = votes[option] ?? 0;
              final isLeading = option == leadingOption;

              return GestureDetector(
                onTap: () => _voteForOption(poll['question'], option),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(vertical: 6),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isLeading ? Colors.pinkAccent.shade100 : Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(option,
                            style: TextStyle(fontSize: 16, color: Colors.deepPurple.shade900)),
                      ),
                      SizedBox(width: 8),
                      Text('$count', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.favorite, color: Colors.pinkAccent),
                    ],
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 12),
            if (leadingOption != null)
              Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber),
                  SizedBox(width: 6),
                  Text("Leading: $leadingOption",
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: Text('Group Polls'),
        backgroundColor: Colors.deepPurple.shade400,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: _showAddPollDialog,
        child: Icon(Icons.add),
      ),
      body: polls.isEmpty
          ? Center(child: Text("No polls yet. Tap + to create one."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: polls.length,
        itemBuilder: (_, index) => _buildPollCard(polls[index]),
      ),
    );
  }
}
