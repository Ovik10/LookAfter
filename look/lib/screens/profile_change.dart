import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:look/reusable_widgets/reusable_widget.dart';
import 'package:look/utils/color_utils.dart';

class ProfileChange extends StatefulWidget {
  const ProfileChange({Key? key}) : super(key: key);

  @override
  State<ProfileChange> createState() => _ProfileChangeState();
}

class _ProfileChangeState extends State<ProfileChange> {
  TextEditingController _passwordTextController = TextEditingController(text: "name");
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

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
    _passwordTextController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(_userNameTextController.text.trim());
        await user.updateEmail(_emailTextController.text.trim());
        await user.updatePassword(_passwordTextController.text.trim());

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
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4")
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.6, 20, 0),
            child: Column(
              children: <Widget>[
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
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outline,
                  true,
                  _passwordTextController,
                ),
                SizedBox(height: 20),
            

            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update'),
            ),
          ],
        ),
      ),
    )));
  }
}
