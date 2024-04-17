import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:look/screens/map.dart';

void main() {
  group('MapScreen Integration Tests', () {
    late Widget mapScreen;
    setUpAll(() async {
      await Firebase.initializeApp();
    });
    setUp(() {
      mapScreen = MaterialApp(
        home: MapSample(),
      );
    });
    testWidgets('MapScreen should display map with initial position',
        (WidgetTester tester) async {
      await tester.pumpWidget(mapScreen);
      expect(find.byType(GoogleMap), findsOneWidget);
      expect(find.byType(Marker), findsOneWidget);
    });
    testWidgets('MapScreen should respond to "My Location" button tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(mapScreen);
      await tester.tap(find.text('My Location'));
      await tester.pump();
      expect(find.byType(Marker), findsOneWidget);
    });
  });
}
