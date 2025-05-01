import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submitLogin(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse("http://10.0.2.2:8081/api/users/login");

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "phone": _phoneController.text.trim(),
            "password": _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final userName = data['name'];
          final userPhone = _phoneController.text.trim();

          // Save login state and user data
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          prefs.setString('userName', userName);
          prefs.setString('userPhone', userPhone); // 👈 Save phone for profile fetch

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid phone or password"),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Server error: ${response.statusCode}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Network error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text("Welcome Back 👋", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Login to continue planning with Gatherly", style: TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration("Phone", Icons.phone),
                    validator: (val) => val!.isEmpty ? "Enter phone" : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration("Password", Icons.lock),
                    validator: (val) => val!.isEmpty ? "Enter password" : null,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () => _submitLogin(context),
                    style: _buttonStyle(),
                    child: const Text("Login"),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
      textStyle: const TextStyle(fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
