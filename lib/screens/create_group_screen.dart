import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();
  final TextEditingController _groupCodeController = TextEditingController(); // New controller for groupCode

  String? _groupCode;
  bool _isLoading = false;

  Future<void> _createGroup() async {
    final String name = _nameController.text.trim();
    final String description = _descController.text.trim();
    final List<String> members = _membersController.text
        .split(',')
        .map((e) => e.trim())
        .toList();
    final String groupCode = _groupCodeController.text.trim(); // Get the groupCode

    if (name.isEmpty || description.isEmpty || members.isEmpty || groupCode.isEmpty) return;

    setState(() => _isLoading = true);

    const String url = "http://10.0.2.2:8081/api/groups/create"; // ← change if deployed

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "description": description,
        "members": members,
        "groupCode": groupCode, // Send groupCode in the request body
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _groupCode = data['groupCode'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group creation failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text(
          '✨ Create a New Group',
          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.teal),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Group Name', _nameController, Icons.group),
              const SizedBox(height: 16),
              _buildTextField('Description', _descController, Icons.description),
              const SizedBox(height: 16),
              _buildTextField('Members (comma separated)', _membersController, Icons.people),
              const SizedBox(height: 16),
              _buildTextField('Group Code', _groupCodeController, Icons.code), // New text field for groupCode
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                onPressed: _createGroup,
                icon: const Icon(Icons.rocket_launch),
                label: const Text('Create Group'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (_groupCode != null)
                Column(
                  children: [
                    const Text(
                      '🎉 Group Created!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Group Code: $_groupCode',
                      style: const TextStyle(fontSize: 18, letterSpacing: 1.2),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      cursorColor: Colors.teal,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.teal),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }
}
