import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unisoc/screens/login_screen.user.dart';
import 'package:unisoc/services/api_services.dart';

void main() {
  group('User Login Tests', () {

    
    // UI TESTS
   

    testWidgets('Login screen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('UP number / Email field exists', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));
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

    testWidgets('User can type in fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));

      final textFields = find.byType(TextField);

      await tester.enterText(textFields.first, '1234567');
      await tester.enterText(textFields.last, 'password');
      await tester.pump();

      expect(find.text('1234567'), findsOneWidget);
      expect(find.text('password'), findsOneWidget);
    });

    testWidgets('Login button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, '1234567');
      await tester.enterText(textFields.last, 'password');
      await tester.pump();

      await tester.tap(find.text('Login').last);
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    
    // API TESTS
 

    test('Valid login → 200', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"token": "fake-token"}),
          200,
        );
      });

      final response = await ApiService.login("1234567", "correctPass", client: client);
      expect(response.statusCode, 200);
    });

    test('UP number not found → 404', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "UP number not found"}),
          404,
        );
      });

      final response = await ApiService.login("9999999", "password", client: client);
      expect(response.statusCode, 404);
    });

    test('Incorrect password → 401', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Incorrect password"}),
          401,
        );
      });

      final response = await ApiService.login("1234567", "wrongpass", client: client);
      expect(response.statusCode, 401);
    });

    test('UP number empty → 400', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Please enter all fields"}),
          400,
        );
      });

      final response = await ApiService.login("", "password", client: client);
      expect(response.statusCode, 400);
    });

    test('Password empty → 400', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Please enter all fields"}),
          400,
        );
      });

      final response = await ApiService.login("1234567", "", client: client);
      expect(response.statusCode, 400);
    });

  });
}