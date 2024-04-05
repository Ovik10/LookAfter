import 'package:flutter/material.dart';
import 'package:look/screens/home_screen.dart';
import 'package:look/screens/map_diff.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileDetailDiff extends StatefulWidget {
  final String userId;
  const ProfileDetailDiff({required this.userId, Key? key}) : super(key: key);

  @override
  State<ProfileDetailDiff> createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetailDiff> {
  String? _userEmail;
  String? _displayName;
  late String _loggedInUserId;

  Future<String?> _getProfilePictureUrl() async {
    final ref = FirebaseStorage.instance.ref().child('profile_images/${widget.userId}.jpg');
    try {
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData(widget.userId);
    _getLoggedInUserId();
  }

  Future<void> _getLoggedInUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _loggedInUserId = user.uid;
      } else {
        print('User not logged in');
      }
    } catch (e) {
      print('Error getting logged-in user data: $e');
    }
  }

  Future<void> _getUserData(String auserId) async {
    final DatabaseReference databaseRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://lookafter-dae81-default-rtdb.europe-west1.firebasedatabase.app/',
    ).ref();
    final userRef = databaseRef.child('users/$auserId');
    final dataSnapshot = await userRef.once().catchError((error) {
      print("Error retrieving data from Firebase: $error");
    });
    final userData = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
    if (userData != null) {
      setState(() {
        _userEmail = userData['email'];
        _displayName = userData['username'];
      });
    }
  }

  Future<void> _deleteContact(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_loggedInUserId).update({
        'contacts': FieldValue.arrayRemove([userId]),
      });
      
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      print('Error deleting contact: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Detail'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<String?>(
              future: _getProfilePictureUrl(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return CircleAvatar(
                    radius: 100,
                    backgroundImage: NetworkImage(snapshot.data!),
                  );
                } else {
                  return CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey, // Set default color to grey
                    child: Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.white,
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 60),
            Text(
              'Email:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_userEmail ?? 'Loading...'),
            SizedBox(height: 20),
            Text(
              'Display Name:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_displayName ?? 'Loading...'),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapDiff(userId: widget.userId),
                  ),
                );
              },
              child: Text('Show Position'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _deleteContact(widget.userId),
              child: Text('Delete Contact'),
            ),
          ],
        ),
      ),
    );
  }
}
