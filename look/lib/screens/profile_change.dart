import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:look/reusable_widgets/reusable_widget.dart';
import 'package:look/utils/color_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';

class ProfileChange extends StatefulWidget {
  const ProfileChange({Key? key}) : super(key: key);

  @override
  State<ProfileChange> createState() => _ProfileChangeState();
}

class _ProfileChangeState extends State<ProfileChange> {
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        _userNameTextController.text = user.displayName ?? '';
        _emailTextController.text = user.email ?? '';
      });
    }
  }
  @override
  void dispose() {
    _userNameTextController.dispose();
    _emailTextController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
duration: const Duration(seconds: 2),
),
);
}

  Future<void> _getImageFromGallery(String userId) async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/$userId.jpg');
      final uploadTask = firebaseStorageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _uploadedImageUrl = downloadUrl;
      });
      _showSnackBar('Profile image uploaded successfully');
    }
  }
  Future<void> _updateProfile() async {
    final DatabaseReference databaseRef = FirebaseDatabase.instanceFor(
  app: Firebase.app(),
  databaseURL: 'https://lookafter-dae81-default-rtdb.europe-west1.firebasedatabase.app/',
).ref();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(_userNameTextController.text.trim());
        await user.updateEmail(_emailTextController.text.trim());

        DatabaseReference userRef =
          databaseRef.child('users').child(user.uid);
      await userRef.update({
        'username': _userNameTextController.text.trim(),
        'email': _emailTextController.text.trim(),
      });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile has been updated!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Update profile",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
             hexStringToColor("05CDF9"),
            hexStringToColor("1036BB"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.3, 20, 0),
            child: Column(
              children: <Widget>[
  GestureDetector(
    onTap: () {
      _getImageFromGallery(FirebaseAuth.instance.currentUser!.uid);
    },
    child: CircleAvatar(
      radius: 100,
      backgroundColor: Colors.white,
      backgroundImage: _uploadedImageUrl == null
          ? null
          : NetworkImage(_uploadedImageUrl!),
      child: _uploadedImageUrl == null
          ? Icon(
              Icons.person,
              size: 50,
              color: Colors.blue,
            )
          : null,
    ),
  ),

SizedBox(height: 60),
                reusableTextField(
                  "Enter UserName",
                  Icons.person_2_outlined,
                  false,
                  _userNameTextController,
                ),
                SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "Enter Email",
                  Icons.email,
                  false,
                  _emailTextController,
                ),
                SizedBox(height: 20),
            

            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update'),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    )));
  }
}
