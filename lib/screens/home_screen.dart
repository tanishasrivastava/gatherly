import 'package:flutter/material.dart';
import '../models/event.dart';
import '../widgets/event_card.dart';
import '../models/task.dart';
import 'event_details.dart';
import 'profile_screen.dart';
import 'add_friends_screen.dart';
import 'about_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoggedIn = false;
  String userName = "User";  // Default username

  final List<Event> _events = [
    Event(
      id: 't1',
      title: 'Movie Night 🍿',
      description: 'Let’s watch a fun movie!',
      date: DateTime(2025, 4, 10),
      location: 'Tanisha’s House',
      invitees: ['Vallika', 'Arjun'],
      tasks: [
        Task(
          id: 't1',
          name: 'Bring popcorn',
          isCompleted: false,
          assignedTo: 'Vallika',
        ),
        Task(
          id: 't2',
          name: 'Choose movie',
          isCompleted: true,
          assignedTo: 'Arjun',
        ),
      ],
    ),
  ];

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      userName = prefs.getString('userName') ?? "User";
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _deleteEvent(String eventId) {
    setState(() {
      _events.removeWhere((event) => event.id == eventId);
    });
  }

  void _updateEvent(Event updatedEvent) {
    setState(() {
      final index = _events.indexWhere((event) => event.id == updatedEvent.id);
      if (index != -1) {
        _events[index] = updatedEvent;
      }
    });
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please log in to create or update events.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.cyan],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/profile_placeholder.png'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isLoggedIn ? 'Hey, $userName!' : 'Welcome!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '✨ Let’s plan something fun!',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.teal),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add_outlined, color: Colors.teal),
              title: const Text('Add Friends'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddFriendsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.teal),
              title: const Text('About Gatherly'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()));
              },
            ),
            SwitchListTile(
              title: Text(isLoggedIn ? 'Logout' : 'Login'),
              secondary: const Icon(Icons.login, color: Colors.teal),
              value: isLoggedIn,
              onChanged: (value) {
                setState(() {
                  isLoggedIn = value;
                  if (!isLoggedIn) {
                    _logout();
                  }
                });
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.teal),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Gatherly ✨',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/profile_placeholder.png'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!isLoggedIn) {
            _showLoginRequiredDialog();
            return;
          }

          final newEvent = await Navigator.pushNamed(context, '/create');
          if (newEvent != null && newEvent is Event) {
            setState(() {
              _events.add(newEvent);
            });
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (!isLoggedIn) {
                      _showLoginRequiredDialog();
                      return;
                    }
                    Navigator.pushNamed(context, '/createGroup');
                  },
                  icon: const Icon(Icons.group, color: Colors.white),
                  label: const Text('Create Group'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (!isLoggedIn) {
                      _showLoginRequiredDialog();
                      return;
                    }
                    Navigator.pushNamed(context, '/joinGroup');
                  },
                  icon: const Icon(Icons.input, color: Colors.white),
                  label: const Text('Join Group'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white, // 👈 sets the text and icon color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),

              ],
            ),
          ),
          Expanded(
            child: _events.isEmpty
                ? const Center(
              child: Text(
                'No events yet. Tap "+" to create one!',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
                : ListView.builder(
              itemCount: _events.length,
              padding: const EdgeInsets.only(bottom: 100, top: 8),
              itemBuilder: (context, index) {
                final event = _events[index];
                return EventCard(
                  event: event,
                  onTap: () async {
                    if (!isLoggedIn) {
                      _showLoginRequiredDialog();
                      return;
                    }

                    final updatedEvent = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsScreen(
                          event: event,
                          onDelete: _deleteEvent,
                          onUpdate: _updateEvent,
                        ),
                      ),
                    );

                    if (updatedEvent != null && updatedEvent is Event) {
                      _updateEvent(updatedEvent);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.remove('userName');
    setState(() {
      userName = "User";
    });
  }
}
