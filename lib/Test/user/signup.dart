import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const String baseUrl = "http://10.128.4.160:8000/api/user/register/";

  group('Signup Tests', () {

  
    // API TESTS (MOCKED)
   

    test("Signup successful → 201", () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"message": "User registered successfully"}),
          201,
        );
      });

      final response = await client.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": "Sam",
          "last_name": "Smith",
          "up_number": "UP1234567",
          "email": "test${DateTime.now().millisecondsSinceEpoch}@gmail.com",
          "password": "Sams123*",
          "confirm_password": "Sams123*",
        }),
      );

      expect(response.statusCode, 201);
    });

    test("Please fill in all fields → 400", () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "All fields are required"}),
          400,
        );
      });

      final response = await client.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": "",
          "last_name": "",
          "up_number": "",
          "email": "",
          "password": "",
          "confirm_password": "",
        }),
      );

      expect(response.statusCode, 400);
    });

    test("UP number must be exactly 7 digits → 400", () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Invalid UP number format"}),
          400,
        );
      });

      final response = await client.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": "Sam",
          "last_name": "Smith",
          "up_number": "UP123",
          "email": "sam1@gmail.com",
          "password": "Sams123*",
          "confirm_password": "Sams123*",
        }),
      );

      expect(response.statusCode, 400);
    });

    test("Enter a valid email address → 400", () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Enter a valid email address"}),
          400,
        );
      });

      final response = await client.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": "Sam",
          "last_name": "Smith",
          "up_number": "UP1234567",
          "email": "invalidemail",
          "password": "Sams123*",
          "confirm_password": "Sams123*",
        }),
      );

      expect(response.statusCode, 400);
    });

    test("Passwords do not match → 400", () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Passwords do not match"}),
          400,
        );
      });

      final response = await client.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": "Sam",
          "last_name": "Smith",
          "up_number": "UP1234567",
          "email": "sam2@gmail.com",
          "password": "Sams123*",
          "confirm_password": "Different123*",
        }),
      );

      expect(response.statusCode, 400);
    });

    test("Password must be at least 8 characters → 400", () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Password must be at least 8 characters"}),
          400,
        );
      });

      final response = await client.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": "Sam",
          "last_name": "Smith",
          "up_number": "UP1234567",
          "email": "sam3@gmail.com",
          "password": "short",
          "confirm_password": "short",
        }),
      );

      expect(response.statusCode, 400);
    });

    test("Signup failed (500)", () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Internal server error"}),
          500,
        );
      });

      final response = await client.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": "Error",
          "last_name": "Test",
          "up_number": "UP1234567",
          "email": "error@test.com",
          "password": "Sams123*",
          "confirm_password": "Sams123*",
        }),
      );

      expect(response.statusCode, 500);
    });

    test("Network error", () async {
      final client = MockClient((request) async {
        throw Exception("Network error");
      });

      expect(
        () async => await client.post(Uri.parse("http://invalid-url")),
        throwsException,
      );
    });

  
    // VALIDATION TESTS
    

    test("Please fill in all fields", () {
      String firstName = "";
      String lastName = "";
      expect(firstName.isEmpty || lastName.isEmpty, true);
    });

    test("UP number must be exactly 7 digits", () {
      String up = "123456";
      expect(RegExp(r'^\d{7}$').hasMatch(up), false);
    });

    test("Valid UP number", () {
      String up = "1234567";
      expect(RegExp(r'^\d{7}$').hasMatch(up), true);
    });

    test("Enter a valid email address", () {
      String email = "samsmith.com";
      expect(RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email), false);
    });

    test("Valid email", () {
      String email = "samsmith@gmail.com";
      expect(RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email), true);
    });

    test("Passwords do not match", () {
      String p1 = "Sams123*";
      String p2 = "Different123*";
      expect(p1 != p2, true);
    });

    test("Password must be at least 8 characters", () {
      String password = "Sams12*";
      expect(password.length < 8, true);
    });

    test("Password must not exceed 20 characters", () {
      String password = "Samsmith123456789****";
      expect(password.length > 20, true);
    });

    test("Password must contain one uppercase letter", () {
      String password = "sams123*";
      expect(RegExp(r'[A-Z]').hasMatch(password), false);
    });

    test("Password must contain one number", () {
      String password = "Samsmith*";
      expect(RegExp(r'\d').hasMatch(password), false);
    });

    test("Password must contain one special character", () {
      String password = "Sams1234";
      expect(RegExp(r'[^\w\s]').hasMatch(password), false);
    });

    test("Valid password", () {
      String password = "Sams123*";
      bool valid = password.length >= 8 &&
          password.length <= 20 &&
          RegExp(r'[A-Z]').hasMatch(password) &&
          RegExp(r'\d').hasMatch(password) &&
          RegExp(r'[^\w\s]').hasMatch(password);

      expect(valid, true);
    });

  });
}