import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;

  const MyDrawer({
    Key? key,
    this.onHomeTap,
    this.onProfileTap,
    this.onLogoutTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Look After',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: onHomeTap,
          ),
          ListTile(
            leading: Icon(Icons.man),
            title: Text('Profile'),
            onTap: onProfileTap,
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: onLogoutTap,
          ),
        ],
      ),
    );
  }
}