import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_event.dart';
import 'screens/create_group_screen.dart';
import 'screens/JoinGroupScreen.dart';
import 'screens/group_screen.dart';

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
        '/createGroup': (context) => const CreateGroupScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/create': (context) => const CreateEventScreen(),
        '/joinGroup': (context) => JoinGroupScreen(),

        '/groupScreen': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return GroupScreen(
            groupData: args['groupData'],
            myId: args['myId'],
            myName: args['myName'],
          );
        },


      },
    );
  }
}
