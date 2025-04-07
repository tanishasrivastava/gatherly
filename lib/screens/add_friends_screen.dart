import 'package:flutter/material.dart';

class AddFriendsScreen extends StatelessWidget {
  const AddFriendsScreen({super.key});

  // Mock contacts (replace with real contact fetching logic)
  final List<Map<String, String>> mockContacts = const [
    {"name": "Aarav Sharma", "phone": "+91 98765 43210"},
    {"name": "Tanya Kapoor", "phone": "+91 91234 56789"},
    {"name": "Ishaan Mehta", "phone": "+91 99887 77665"},
    {"name": "Zoya Sheikh", "phone": "+91 87654 32100"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Friends"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: mockContacts.length,
              itemBuilder: (context, index) {
                final contact = mockContacts[index];
                return _buildContactTile(contact['name']!, contact['phone']!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search contacts...',
        hintStyle: const TextStyle(fontFamily: 'Poppins'),
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildContactTile(String name, String phone) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purpleAccent,
          child: Text(name[0], style: const TextStyle(color: Colors.white)),
        ),
        title: Text(name,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
        subtitle: Text(phone,
            style: const TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
        trailing: ElevatedButton(
          onPressed: () {
            // TODO: Add friend logic here
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          child: const Text("Add", style: TextStyle(fontSize: 14)),
        ),
      ),
    );
  }
}
