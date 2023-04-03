import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:look/reusable_widgets/reusable_widget.dart';
import 'package:look/screens/home_screen.dart';
import 'package:look/screens/signup_screen.dart';
import 'package:look/utils/color_utils.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(decoration: BoxDecoration(gradient: LinearGradient(colors:
    [hexStringToColor("CB2B93"),
    hexStringToColor("9546C4"),
    hexStringToColor("5E61F4")], 
    begin: Alignment.topCenter, 
    end: Alignment.bottomCenter)),
    child: SingleChildScrollView(child: Padding(
      padding: EdgeInsets.fromLTRB(
        20, MediaQuery.of(context).size.height * 0.6, 20, 0),
        child: Column(children: <Widget> [ 
    reusableTextField("Enter UserName", Icons.person_2_outlined, false, _emailTextController),
    SizedBox(height: 20,),
    reusableTextField("Enter Password", Icons.lock_outline, true, _passwordTextController),
    SizedBox(height: 20),
    signInSignUpButton(context, true, () {
      FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text).then(
          (value) => Navigator.push(
            context, MaterialPageRoute(
              builder: (context) => HomeScreen())).onError((error, stackTrace) => print("Error ${error.toString()}")));
      
    }),
    signUpOption()
    
    ],
    )),
    )));
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?", style: TextStyle(color: Colors.white70)),
      GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
        },
        child: const Text(
          " Sign Up",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
      )
      ],
    );
  }
}