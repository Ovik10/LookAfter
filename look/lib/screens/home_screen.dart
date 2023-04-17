
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:look/reusable_widgets/my_drawer.dart';
import 'package:look/screens/add_contact.dart';
import 'package:look/screens/map.dart';
import 'package:look/screens/profile_change.dart';
import 'package:look/screens/profile_detail.dart';
import 'package:look/screens/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  getContactList();
}

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

  List<Object> _contactList = [];
  

  @override
  Widget build(BuildContext context) {

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    print('User ID: $userId');
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
          ), 
          SizedBox(height: 20),
           Text('Contacts',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24, 
                ),),
                if (_contactList.isEmpty)
                  Text('You have no contacts yet.')
                else
                  ListView(
  shrinkWrap: true,
  children: _contactList.map((contact) {
    // Build a widget for each contact
    return ListTile(
      title: Text(contact.toString()),
      onTap: () {
        // Navigate to the profile details of the selected contact
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetail(),
            //contactId: contact.id
          ),
        );
      },
    );
  }).toList(),
)
                  ,
                ElevatedButton(
            child: Text('Add Contact'),
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddContact()),
              );
            },
          ),
                ]
        ),
      ),
    ),),);
  }
Future<void> getContactList() async {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
final snapshot = await userDocRef.get();
final contacts = List<String>.from(snapshot.get('contacts'));
print(contacts);
 
  
    setState(() {
      _contactList = List.from(contacts);
      print(_contactList);
    });
}
}