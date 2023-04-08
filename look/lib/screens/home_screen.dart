import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:look/reusable_widgets/my_drawer.dart';
import 'package:look/screens/map.dart';
import 'package:look/screens/profile_change.dart';
import 'package:look/screens/profile_detail.dart';
import 'package:look/screens/signin_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void navigateToHome() {
    Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
  }

  void navigateToProfile() {
    Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileDetail()),
              );
  }

  void logoutUser() {
    FirebaseAuth.instance.signOut().then((value) {
              print("Signed Out");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            }).onError((error, stackTrace) {
              print("Error ${error.toString()}");
            });
          }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Look After'),
      ),
      drawer: MyDrawer(
        onHomeTap: navigateToHome,
        onProfileTap: navigateToProfile,
        onLogoutTap: logoutUser,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.05, 20, 0), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Map',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24, 
                ),),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text('Show Map'),
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapSample()),
              );
            },
          ), ]
        ),
      ),
    ),),);
  }
}
