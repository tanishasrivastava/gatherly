import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../screens/add_friends_screen.dart';
import '../screens/about_screen.dart';

class SidebarDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.purpleAccent),
            child: Text("Gatherly 💜", style: TextStyle(fontSize: 24, color: Colors.white)),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen())),
          ),
          ListTile(
            leading: Icon(Icons.group_add),
            title: Text('Add Friends'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddFriendsScreen())),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About Gatherly'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AboutScreen())),
          ),
        ],
      ),
    );
  }
}
