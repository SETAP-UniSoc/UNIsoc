import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user/user_home_page.dart';

void main() {
  group('User Homepage Widget Tests', () {

    // Test that the homepage renders without crashing
    testWidgets('HomePage renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
        ),
      );
      
      // Wait for initial render
      await tester.pump();
      
      // Wait for API calls (2 seconds)
      await tester.pump(const Duration(seconds: 2));
      
      // Check if the app bar title exists
      expect(find.text('UniSoc'), findsOneWidget);
    });

    // Test that loading indicator appears then disappears
    testWidgets('Shows loading indicator then data loads', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
        ),
      );
      
      // Check loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for API calls
      await tester.pump(const Duration(seconds: 3));
      
      // Loading indicator should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // Test that search bar exists
    testWidgets('Search bar exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
        ),
      );
      
      await tester.pump(const Duration(seconds: 2));
      
      expect(find.byType(TextField), findsOneWidget);
    });

    // Test search bar input
    testWidgets('Search bar accepts text input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
        ),
      );
      
      await tester.pump(const Duration(seconds: 2));
      
      await tester.enterText(find.byType(TextField), 'Football');
      await tester.pump();
      
      expect(find.text('Football'), findsOneWidget);
    });

    // Test that Browse Societies section exists
    testWidgets('Browse Societies section is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
        ),
      );
      
      await tester.pump(const Duration(seconds: 2));
      
      expect(find.text('Browse Societies'), findsOneWidget);
    });

    // Test that Sort by dropdown exists
    testWidgets('Sort by dropdown exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
        ),
      );
      
      await tester.pump(const Duration(seconds: 2));
      
      expect(find.text('Sort by'), findsOneWidget);
    });

    // Test that Filter by dropdown exists
    testWidgets('Filter by dropdown exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
        ),
      );
      
      await tester.pump(const Duration(seconds: 2));
      
      expect(find.text('Filter by'), findsOneWidget);
    });

    // Test that Upcoming Events section exists
    testWidgets('Upcoming Events section is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
        ),
      );
      
      await tester.pump(const Duration(seconds: 2));
      
      expect(find.text('Upcoming Events'), findsOneWidget);
    });

    // Test that Top Societies carousel exists
    testWidgets('Top Societies carousel is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
        ),
      );
      
      await tester.pump(const Duration(seconds: 2));
      
      expect(find.text('Top Societies'), findsOneWidget);
    });

  });
}