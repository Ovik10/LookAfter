import 'package:flutter/material.dart';
import 'package:look/screens/profile_change.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';


class ProfileDetailDiff extends StatefulWidget {
  final String userId;
  const ProfileDetailDiff({required this.userId, Key? key}) : super(key: key);

  @override
  State<ProfileDetailDiff> createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetailDiff> {
  String? _userEmail;
  String? _displayName;

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
                if (snapshot.hasData) {
                  return CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(snapshot.data!),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
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
          ],
        ),
      ),
    );
  }
}
