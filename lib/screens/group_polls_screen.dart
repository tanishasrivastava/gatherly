import 'package:flutter/material.dart';

class GroupPollsScreen extends StatefulWidget {
  final String groupId;

  const GroupPollsScreen({super.key, required this.groupId});

  @override
  State<GroupPollsScreen> createState() => _GroupPollsScreenState();
}

class _GroupPollsScreenState extends State<GroupPollsScreen> {
  List<Map<String, dynamic>> polls = [];

  final TextEditingController _questionController = TextEditingController();

  void _addPoll() {
    if (_questionController.text.isNotEmpty) {
      setState(() {
        polls.add({
          'question': _questionController.text,
          'votes': Map<String, int>(),
          'options': ['👍', '👎', '❤️', '😆'], // Fun emojis for poll options
        });
        _questionController.clear();
      });
    }
    Navigator.pop(context);
  }

  void _showAddPollDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade100,
        title: Text("Create Poll", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: _questionController,
          decoration: InputDecoration(
            hintText: "What's your poll?",
            hintStyle: TextStyle(color: Colors.deepPurple.shade300),
            filled: true,
            fillColor: Colors.deepPurple.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _addPoll,
            child: Text('Add', style: TextStyle(color: Colors.pinkAccent)),
          ),
        ],
      ),
    );
  }

  void _voteForOption(int pollIndex, String option) {
    setState(() {
      if (!polls[pollIndex]['votes'].containsKey(option)) {
        polls[pollIndex]['votes'][option] = 1;
      } else {
        polls[pollIndex]['votes'][option] += 1;
      }
    });
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: polls.length,
        itemBuilder: (_, index) {
          final poll = polls[index];
          final totalVotes = poll['votes'].values.fold(0, (prev, element) => prev + element);
          return Card(
            color: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(poll['question'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var option in poll['options'])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: GestureDetector(
                        onTap: () => _voteForOption(index, option),
                        child: Row(
                          children: [
                            Text(option, style: TextStyle(fontSize: 20)),
                            SizedBox(width: 8),
                            Icon(Icons.favorite, color: Colors.pinkAccent),
                            SizedBox(width: 8),
                            Text(
                              '${poll['votes'][option] ?? 0} Votes',
                              style: TextStyle(color: Colors.deepPurple.shade600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: totalVotes == 0 ? 0 : poll['votes'].values.reduce((a, b) => a + b) / totalVotes,
                    backgroundColor: Colors.deepPurple.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                  ),
                ],
              ),
              trailing: Icon(Icons.how_to_vote, color: Colors.purple),
            ),
          );
        },
      ),
    );
  }
}
