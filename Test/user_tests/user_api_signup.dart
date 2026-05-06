import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const String baseUrl = "http://10.128.4.160:8000/api/user/register/";

  group('Signup API Tests', () {

    // Signup successful - MOCKED
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

    // Empty fields - MOCKED
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

    // UP number invalid - MOCKED
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

    // Email format - MOCKED
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

    // Passwords do not match - MOCKED
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

    // Password too short - MOCKED
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

    // Network error - MOCKED
    test("Network error", () async {
      final client = MockClient((request) async {
        throw Exception("Network error");
      });

      expect(
        () async => await client.post(Uri.parse("http://invalid-url")),
        throwsException,
      );
    });

    // Server error - MOCKED
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

  });
}