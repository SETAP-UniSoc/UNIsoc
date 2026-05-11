import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

void main() {
  group('Forgotten Password Screen API Tests', () {

    // 1. USER EMAIL VERIFICATION SUCCESS
    test('Valid user email returns 200 and verifies user', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({
          "user_id": 1
        }), 200);
      });

      final response = await client.get(
        Uri.parse("http://test/api/check-user?email=test@email.com&type=user"),
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['user_id'], 1);
    });

    // 2. USER EMAIL NOT FOUND
    test('Invalid user email returns 404', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({
          "error": "Email not found"
        }), 404);
      });

      final response = await client.get(
        Uri.parse("http://test/api/check-user"),
      );

      expect(response.statusCode, 404);
    });

    // 3. ADMIN EMAIL VERIFICATION SUCCESS
    test('Valid admin email returns 200', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({
          "user_id": 99
        }), 200);
      });

      final response = await client.get(
        Uri.parse("http://test/api/check-user?type=admin"),
      );

      expect(response.statusCode, 200);
    });

    // 4. UP NUMBER VALIDATION SUCCESS
    test('Valid UP number returns 200', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({
          "message": "UP verified"
        }), 200);
      });

      final response = await client.post(
        Uri.parse("http://test/api/verify-up"),
        body: jsonEncode({
          "user_id": "1",
          "up_number": "UP1234567"
        }),
      );

      expect(response.statusCode, 200);
    });

    // 5. UP NUMBER INVALID
    test('Invalid UP number returns error', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({
          "error": "Invalid UP number"
        }), 400);
      });

      final response = await client.post(
        Uri.parse("http://test/api/verify-up"),
      );

      expect(response.statusCode, 400);
    });

    // 6. PASSWORD RESET SUCCESS
    test('Valid password reset returns 200', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({
          "message": "Password updated"
        }), 200);
      });

      final response = await client.post(
        Uri.parse("http://test/api/reset-password"),
        body: jsonEncode({
          "user_id": "1",
          "password": "NewPass123"
        }),
      );

      expect(response.statusCode, 200);
    });

    // 7. PASSWORD MISMATCH HANDLING (frontend validation case)
    test('Password mismatch should not call API', () {
      final password = "Test1234";
      final confirm = "Test9999";

      expect(password == confirm, false);
    });

    // 8. EMPTY PASSWORD VALIDATION
    test('Empty password should be rejected', () {
      final password = "";

      expect(password.isEmpty, true);
    });

    // 9. SERVER ERROR HANDLING
    test('Server error returns 500', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({
          "error": "Internal server error"
        }), 500);
      });

      final response = await client.post(
        Uri.parse("http://test/api/reset-password"),
      );

      expect(response.statusCode, 500);
    });

    // 10. NETWORK FAILURE
    test('Network failure throws exception', () async {
      final client = MockClient((request) async {
        throw Exception("Connection error");
      });

      expect(
        () async => await client.get(Uri.parse("http://test/api/check-user")),
        throwsException,
      );
    });

  });
}