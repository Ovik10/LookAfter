import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:look/screens/home_screen.dart';
import 'package:look/screens/profile_change.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:look/screens/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileDetail extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  const ProfileDetail({
    Key? key,
    required this.auth,
    required this.storage,
  }) : super(key: key);

  

  @override
  State<ProfileDetail> createState() => _ProfileDetailState();
}

final DatabaseReference databaseRef = FirebaseDatabase.instanceFor(
  app: Firebase.app(),
  databaseURL: 'https://lookafter-dae81-default-rtdb.europe-west1.firebasedatabase.app/',
).ref();
class _ProfileDetailState extends State<ProfileDetail> {
  String? _userEmail;
  String? _displayName;

  Future<String?> _getProfilePictureUrl(String userId) async {
    final ref = widget.storage.ref().child('profile_images/$userId.jpg');
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
    _getUserData();
  }

  Future<void> _getUserData() async {
    final user = widget.auth.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email;
        _displayName = user.displayName;
      });
    }
  }

  Future<void> _updateProfile() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileChange()),
    );
  }

  Future<void> _deleteProfile(String password) async {
  try {
    // Reauthenticate user
    AuthCredential credential = EmailAuthProvider.credential(email: _userEmail!, password: password);
    await widget.auth.currentUser?.reauthenticateWithCredential(credential);

    // Delete user data from Firestore
    FirebaseFirestore.instance.collection('users').doc(widget.auth.currentUser!.uid).delete();

    // Delete user data from Realtime Database
    databaseRef.child('users').child(widget.auth.currentUser!.uid).remove();

    // Delete user data from Firebase Storage
    final firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${widget.auth.currentUser!.uid}.jpg');
      firebaseStorageRef.delete();

    // Delete user account
    await FirebaseAuth.instance.currentUser?.delete();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  } catch (e) {
    // Handle error
    print('Error deleting user: $e');
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
              future: _getProfilePictureUrl(widget.auth.currentUser!.uid),
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
                    backgroundColor: Colors.grey,
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
              'Username:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_displayName ?? 'Loading...'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update Profile'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _buildPasswordDialog(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set button color to red
              ),
              child: Text('Delete Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordDialog() {
    TextEditingController passwordController = TextEditingController();
    return AlertDialog(
      title: Text('Confirm Deletion'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('To confirm deletion, please enter your password:'),
          SizedBox(height: 10),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            String password = passwordController.text.trim();
            if (password.isNotEmpty) {
              _deleteProfile(password);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Set button color to red
          ),
          child: Text('Delete'),
        ),
      ],
    );
  }
}
