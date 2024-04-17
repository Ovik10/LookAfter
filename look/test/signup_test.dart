import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:look/main.dart';
import 'package:look/screens/signup_screen.dart';
import 'package:look/screens/home_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
void main() {
  group('SignUpScreen', () {
    late SignUpScreen signUpScreen;
    late MockFirebaseAuth mockFirebaseAuth;
    setUp(() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      runApp(MyApp());
      signUpScreen = SignUpScreen();
      mockFirebaseAuth = MockFirebaseAuth();
    });
    testWidgets('should show snackbar if any field is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: signUpScreen));
      await tester.tap(find.text('Sign Up'));
      expect(find.text('Please fill all the fields.'), findsOneWidget);
    });
    testWidgets('should show snackbar if email is invalid',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: signUpScreen));
      await tester.enterText(find.byIcon(Icons.person_2_outlined), 'John');
      await tester.enterText(find.byIcon(Icons.email), 'invalidemail');
      await tester.enterText(find.byIcon(Icons.lock_outline), 'password');
      await tester.tap(find.text('Sign Up'));
      expect(find.text('Please enter a valid email address.'), findsOneWidget);
    });
    testWidgets('should navigate to HomeScreen after successful sign-up',
        (WidgetTester tester) async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'example@email.com', password: 'password123'))
          .thenAnswer((_) => Future.value());
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'example@email.com',
        password: 'password123',
      )).thenAnswer((_) => Future.value());
      await tester.pumpWidget(MaterialApp(home: signUpScreen));
      await tester.enterText(find.byIcon(Icons.person_2_outlined), 'John');
      await tester.enterText(find.byIcon(Icons.email), 'john@example.com');
      await tester.enterText(find.byIcon(Icons.lock_outline), 'password');
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
