import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_event.dart';
// You can import profile_screen.dart, add_friends_screen.dart, etc. here if needed

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gatherly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/create': (context) => const CreateEventScreen(),
        // You can add more routes below as you build:
        // '/profile': (context) => const ProfileScreen(),
        // '/add-friends': (context) => const AddFriendsScreen(),
        // '/about': (context) => const AboutScreen(),
      },
    );
  }
}
