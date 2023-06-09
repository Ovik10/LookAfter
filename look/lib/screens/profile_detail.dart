import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:look/screens/profile_change.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
                if (snapshot.hasData) {
                  return CircleAvatar(
                    radius: 100,
                    backgroundImage: NetworkImage(snapshot.data!),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
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
          ],
        ),
      ),
    );
  }
}
