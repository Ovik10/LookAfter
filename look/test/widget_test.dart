import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:look/screens/home_screen.dart';

void main() {
   setUpAll(() async {
    await Firebase.initializeApp();
  });
  testWidgets('HomeScreen Widget Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));
    expect(find.text('Look After'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Contacts'), findsOneWidget);
    expect(find.text('Add Contact'), findsOneWidget);
    expect(find.text('Chats'), findsOneWidget);
  });
}