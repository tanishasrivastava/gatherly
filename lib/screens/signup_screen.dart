import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  Future<void> _submitSignup(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse("http://10.0.2.2:8081/api/users/signup");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": _nameController.text,
          "phone": _phoneController.text,
          "password": _passwordController.text,
          "imagePath": "",
          "gender": "",
          "age": "",
          "location": "",
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup successful!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Phone number already exists"), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup failed"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text("Join Gatherly 🎉", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 28),
                  TextFormField(controller: _nameController, decoration: _inputDecoration("Name", Icons.person), validator: (val) => val!.isEmpty ? "Enter name" : null),
                  const SizedBox(height: 18),
                  TextFormField(controller: _emailController, decoration: _inputDecoration("Email", Icons.email), validator: (val) => val!.isEmpty ? "Enter email" : null),
                  const SizedBox(height: 18),
                  TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: _inputDecoration("Phone", Icons.phone), validator: (val) => val!.isEmpty ? "Enter phone" : null),
                  const SizedBox(height: 18),
                  TextFormField(controller: _passwordController, obscureText: true, decoration: _inputDecoration("Password", Icons.lock), validator: (val) => val!.length < 6 ? "Min 6 characters" : null),
                  const SizedBox(height: 18),
                  TextFormField(controller: _confirmController, obscureText: true, decoration: _inputDecoration("Confirm Password", Icons.lock), validator: (val) => val != _passwordController.text ? "Passwords don’t match" : null),
                  const SizedBox(height: 28),
                  ElevatedButton(onPressed: () => _submitSignup(context), style: _buttonStyle(), child: const Text("Create Account")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(prefixIcon: Icon(icon), labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)));
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14), textStyle: const TextStyle(fontSize: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)));
  }
}
