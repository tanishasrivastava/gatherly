import 'package:flutter/material.dart';

class AddFriendsScreen extends StatelessWidget {
  const AddFriendsScreen({super.key});

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
        elevation: 5,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: mockContacts.length,
              itemBuilder: (context, index) {
                final contact = mockContacts[index];
                return _buildContactTile(contact['name']!, contact['phone']!, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Search friends...',
          hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.black.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildContactTile(String name, String phone, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: 8,
        color: Colors.purple.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            leading: CircleAvatar(
              backgroundColor: Colors.purpleAccent,
              child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(
              name,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontFamily: 'Poppins', fontSize: 18, color: Colors.black),
            ),
            subtitle: Text(
              phone,
              style: TextStyle(fontFamily: 'Poppins', color: Colors.black.withOpacity(0.6)),
            ),
            trailing: GestureDetector(
              onTap: () {
                _showAddFriendDialog(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Text(
                  "Add",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to show the dialog when a friend is added
  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 16,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purpleAccent, Colors.purple.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 50),
                const SizedBox(height: 20),
                const Text(
                  "Friend Added!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    backgroundColor: Colors.black.withOpacity(0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
