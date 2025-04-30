import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gatherly/widgets/profile_image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isEditMode = false;
  bool _isLoading = true;
  bool _isCreating = false;

  String? _name;
  String? _phone;
  String? _gender;
  String? _age;
  String? _location;
  String? _imagePath;
  String? _password;
  String? _confirmPassword;

  final String baseUrl = 'http://10.0.2.2:8089/api/users';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    const phoneNumber = '1234567890'; // replace with actual logged-in user's phone
    final url = Uri.parse('$baseUrl/phone/$phoneNumber');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _name = data['name'];
          _phone = data['phone'];
          _gender = data['gender'];
          _age = data['age'];
          _location = data['location'];
          _imagePath = data['imagePath'];
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        // No profile exists, so user will create one
        setState(() {
          _isCreating = true;
          _isEditMode = true;
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Failed to load profile: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleImagePick(File imageFile) {
    setState(() {
      _imagePath = imageFile.path;
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_isCreating && _password != _confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ));
        return;
      }

      final profileData = {
        "name": _name,
        "phone": _phone,
        "gender": _gender,
        "age": _age,
        "location": _location,
        "imagePath": _imagePath,
        "password": _password,
      };

      final url = _isCreating
          ? Uri.parse('$baseUrl/create')
          : Uri.parse('$baseUrl/update');

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: json.encode(profileData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Profile saved successfully!"),
            backgroundColor: Colors.green,
          ));

          setState(() {
            _isEditMode = false;
            _isCreating = false;
          });

          _fetchUserProfile(); // Refresh details
        } else {
          print("Failed: ${response.body}");
        }
      } catch (error) {
        print("Error saving profile: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditMode && !_isCreating)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            ProfileImagePicker(
              onImagePicked: _handleImagePick,

            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    label: "Name",
                    icon: Icons.person_outline,
                    enabled: _isEditMode,
                    initialValue: _name,
                    onSaved: (value) => _name = value,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    label: "Phone Number",
                    icon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                    enabled: _isCreating,
                    initialValue: _phone,
                    onSaved: (value) => _phone = value,
                  ),
                  const SizedBox(height: 15),
                  _buildDropdownField(),
                  const SizedBox(height: 15),
                  _buildTextField(
                    label: "Age",
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    enabled: _isEditMode,
                    initialValue: _age,
                    onSaved: (value) => _age = value,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    label: "Location",
                    icon: Icons.location_on_outlined,
                    enabled: _isEditMode,
                    initialValue: _location,
                    onSaved: (value) => _location = value,
                  ),
                  if (_isCreating) ...[
                    const SizedBox(height: 15),
                    _buildTextField(
                      label: "Password",
                      icon: Icons.lock_outline,
                      enabled: true,
                      obscureText: true,
                      onSaved: (value) => _password = value,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      label: "Confirm Password",
                      icon: Icons.lock_outline,
                      enabled: true,
                      obscureText: true,
                      onSaved: (value) => _confirmPassword = value,
                    ),
                  ],
                  const SizedBox(height: 25),
                  if (_isEditMode || _isCreating)
                    ElevatedButton.icon(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text(
                        "Save Profile",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required void Function(String?) onSaved,
    String? initialValue,
    IconData? icon,
    bool enabled = true,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initialValue,
      enabled: enabled,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Poppins'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onSaved: onSaved,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your $label";
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: const Icon(Icons.wc_outlined, color: Colors.black54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: ['Male', 'Female', 'Other']
          .map((gender) => DropdownMenuItem(
        value: gender,
        child: Text(gender),
      ))
          .toList(),
      onChanged: _isEditMode ? (value) => _gender = value : null,
      validator: (value) => value == null ? 'Please select a gender' : null,
    );
  }
}
