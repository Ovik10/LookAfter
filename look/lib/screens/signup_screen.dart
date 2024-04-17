import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:look/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:look/reusable_widgets/reusable_widget.dart';
import 'package:look/screens/home_screen.dart';
import 'package:look/utils/color_utils.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('SignUpScreen');

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  bool _isEmailValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$")
        .hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseReference databaseRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://lookafter-dae81-default-rtdb.europe-west1.firebasedatabase.app/',
    ).ref();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
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
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.4, 20, 0),
            child: Column(
              children: <Widget>[
                Text(
                  "Look After",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 80,),
                reusableTextField(
                  "UserName",
                  Icons.person_2_outlined,
                  false,
                  _userNameTextController,
                ),
                SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "Email",
                  Icons.email,
                  false,
                  _emailTextController,
                ),
                SizedBox(height: 20),
                reusableTextField(
                  "Password",
                  Icons.lock_outline,
                  true,
                  _passwordTextController,
                ),
                SizedBox(height: 20),
                signInSignUpButton(context, false, () {
                  final userName = _userNameTextController.text.trim();
                  final email = _emailTextController.text.trim();
                  final password = _passwordTextController.text.trim();

                  if (userName.isEmpty || email.isEmpty || password.isEmpty) {
                    _showSnackBar('Please fill all the fields.');
                  } else if (!_isEmailValid(email)) {
                    _showSnackBar('Please enter a valid email address.');
                  } else {
                    FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: email, password: password)
                        .then((value) async {
                      final userRef =
                          databaseRef.child('users').child(value.user!.uid);
                      Map<String, dynamic> userData = {
                        'username': userName,
                        'email': email,
                      };

                      // Create Firestore document for the user
await FirebaseFirestore.instance
    .collection('users')
    .doc(value.user!.uid)
    .set({
  ...userData, 
  'contacts': [], 
  'email': email, 
});
 await FirebaseFirestore.instance.collection('users').doc(value.user!.uid).collection('chats').doc('dummy').set({});

                      // Update Realtime Database with user data
                      userRef.set(userData).then((_) {
                        _logger.info("Account created");

                        // Automatically sign in the user after successful sign-up
                        FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: email, password: password)
                            .then((userCredential) {
                          _logger.info("User signed in after sign-up");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()));
                        }).catchError((error) {
                          _logger.severe(
                              "Error signing in after sign-up: $error");
                        });
                      });
                    }).catchError((error, stackTrace) {
                      _logger.severe(
                          "Error creating account: $error", error, stackTrace);
                    });
                  }
                }),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}