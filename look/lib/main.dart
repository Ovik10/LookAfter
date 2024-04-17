import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:look/screens/map.dart';
import 'package:look/screens/signin_screen.dart';
import 'package:look/utils/color_utils.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
  LocationService().startTracking();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Look After',
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 0, 0, 0),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
            side: MaterialStateProperty.all<BorderSide>(
              BorderSide(color: Colors.black),
            ),
          ),
        ),
        textTheme: TextTheme(
          headline6: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
          button: TextStyle(fontSize: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.white),
          labelStyle: TextStyle(color: Colors.white), // Set label text color to white
          
        ),
        dividerTheme: DividerThemeData(color: Colors.white),
      ),
      home: const SignInScreen(),
    );
  }
}

