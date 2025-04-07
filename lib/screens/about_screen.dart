import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("About Gatherly"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.groups_2_rounded,
                size: 80,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "💡 What is Gatherly?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Gatherly is your go-to app for effortlessly planning group events with your squad. Whether it’s a surprise birthday, last-minute plan, or college project—Gatherly has your back. 💖",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "🚀 How to Use",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            _buildStep(
              "1. Create an Event 🎉",
              "Fill in details like title, date, location, invitees, and tasks. No chaos, just clarity.",
            ),
            _buildStep(
              "2. Share & Assign 📝",
              "Split responsibilities like a pro! Assign tasks to each member.",
            ),
            _buildStep(
              "3. Track & Chill 🧘",
              "Keep tabs on what’s done and what’s pending. Everything in one place.",
            ),
            const SizedBox(height: 20),
            const Text(
              "🌟 Why Gatherly?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "✅ Simple. \n✅ Organized. \n✅ Gen-Z approved. \n\nBecause plans should be lit, not late. 🔥",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                "Made with 💜 by Team Gatherly",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.black),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
                children: [
                  TextSpan(
                    text: "$title\n",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
