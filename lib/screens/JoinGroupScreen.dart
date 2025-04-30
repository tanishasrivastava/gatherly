import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'group_screen.dart';

class JoinGroupScreen extends StatefulWidget {
  @override
  _JoinGroupScreenState createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final TextEditingController _groupCodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = false;
  Future<void> joinGroup() async {
    String groupCode = _groupCodeController.text.trim();
    String memberId = _nameController.text.trim();

    if (groupCode.isEmpty || memberId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill both fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8081/api/groups/join'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'groupCode': groupCode,
          'memberId': memberId,
        }),
      );

      if (response.statusCode == 200) {
        final groupResponse = await http.get(
          Uri.parse('http://10.0.2.2:8081/api/groups/$groupCode'),
        );

        if (groupResponse.statusCode == 200) {
          final groupData = jsonDecode(groupResponse.body);

          // Pass `memberId` as a temporary value, NOT overwriting the user's real name
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GroupScreen(
                groupData: groupData,
                myId: memberId,  // Just pass the ID locally
                myName: memberId, // Just pass the ID locally
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch group details')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: Text('Join Group'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _groupCodeController,
                    decoration: InputDecoration(
                      labelText: 'Group Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Name / ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      backgroundColor: Colors.blueAccent,
                    ),
                    onPressed: joinGroup,
                    child: Text('Join Group', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
