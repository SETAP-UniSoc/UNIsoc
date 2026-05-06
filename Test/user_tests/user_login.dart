import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/login_screen.user.dart';

void main() {
  group('Login Screen UI Tests', () {

    testWidgets('Login screen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));
      
      // Check that the screen loaded
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('UP number / Email field exists', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));
      
      // There should be at least one text field
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Password field exists', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));
      
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Login button exists', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));
      
      expect(find.text('Login'), findsWidgets);
    });

    testWidgets('Forgot Password link exists', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));
      
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('Signup button exists', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));
      
      expect(find.text('Signup'), findsOneWidget);
    });

    testWidgets('User can type in UP number field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));
      
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, '1234567');
      await tester.pump();
      
      expect(find.text('1234567'), findsOneWidget);
    });

    testWidgets('User can type in password field', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));
      
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.last, 'mypassword');
      await tester.pump();
      
      expect(find.text('mypassword'), findsOneWidget);
    });

    testWidgets('Login button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));
      
      // Fill in fields first
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, '1234567');
      await tester.enterText(textFields.last, 'password');
      await tester.pump();
      
      // Tap login button
      await tester.tap(find.text('Login').last);
      await tester.pump();
      
      // Screen should still be there (no crash)
      expect(find.byType(Scaffold), findsOneWidget);
    });

  });
}