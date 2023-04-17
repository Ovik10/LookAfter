import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:look/main.dart';
import 'package:look/reusable_widgets/reusable_widget.dart';
import 'package:look/screens/home_screen.dart';
import 'package:look/utils/color_utils.dart';
import 'package:logging/logging.dart';
import 'package:firebase_database/firebase_database.dart';


final Logger _logger = Logger('SignUpScreen');

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

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
  databaseURL: 'https://lookafter-dae81-default-rtdb.europe-west1.firebasedatabase.app/',
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
  .createUserWithEmailAndPassword(email: email, password: password)
  .then((value) {
    // Create a reference to the user node in the database
    DatabaseReference userRef = databaseRef.child('users').child(value.user!.uid);

    // Create a map with the user data to be written to the database
    Map<String, dynamic> userData = {
      'username': userName,
      'email': email,
    };

    // Write the user data to the database
    userRef.set(userData).then((_) {
      _logger.info("Account created");
      Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  })
  .onError((error, stackTrace) {
    _logger.severe("Error ${error.toString()}", error, stackTrace);
  });
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
