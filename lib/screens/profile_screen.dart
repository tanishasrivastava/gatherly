import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String baseUrl = "http://10.0.2.2:8081/api/users/getByPhone";

  String? _phone;
  String? _name;
  String? _gender;
  int? _age;
  String? _location;
  String? _imagePath;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhoneAndFetchProfile();
  }

  Future<void> _loadPhoneAndFetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString('userPhone');

    if (savedPhone != null) {
      setState(() {
        _phone = savedPhone;
      });
      _fetchUserProfile(savedPhone);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user is logged in"), backgroundColor: Colors.red),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserProfile(String phone) async {
    try {
      final url = Uri.parse('$baseUrl/$phone');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _name = data['name'];
          _gender = data['gender'];
          _age = int.tryParse(data['age'].toString());
          _location = data['location'];
          _imagePath = data['imagePath'];
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load profile"), backgroundColor: Colors.red),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildProfileItem(String title, String value) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _imagePath != null && _imagePath!.isNotEmpty
                  ? NetworkImage(_imagePath!)
                  : const AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            const SizedBox(height: 20),
            if (_name != null) _buildProfileItem("Name", _name!),
            if (_phone != null) _buildProfileItem("Phone", _phone!),
            if (_gender != null) _buildProfileItem("Gender", _gender!),
            if (_age != null) _buildProfileItem("Age", _age.toString()),
            if (_location != null) _buildProfileItem("Location", _location!),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/editProfile');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Edit Profile", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
