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
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 27, 145, 255),
            ),
            child: Container(
              child: Image.asset(
                'assets/logo.png', // Replace 'your_image.png' with the path to your image asset
                fit: BoxFit.fill, // Ensure the image covers the entire container
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: onHomeTap,
          ),
          ListTile(
            leading: Icon(Icons.person),
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
