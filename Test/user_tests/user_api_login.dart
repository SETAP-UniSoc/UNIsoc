import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unisoc/services/api_services.dart';

void main() {
  group('Login API Tests', () {

    // VALID LOGIN
    test('Valid login returns 200', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"token": "fake-token", "role": "user"}),
          200,
        );
      });

      final response = await ApiService.login("1234567", "correctPass", client: client);
      expect(response.statusCode, 200);
    });

    // UP NUMBER NOT FOUND
    test('UP number not found returns 404', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "User not found"}),
          404,
        );
      });

      final response = await ApiService.login("9999999", "password", client: client);
      expect(response.statusCode, 404);
    });

    // INCORRECT PASSWORD
    test('Incorrect password returns 401', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Invalid credentials"}),
          401,
        );
      });

      final response = await ApiService.login("1234567", "wrongpass", client: client);
      expect(response.statusCode, 401);
    });

    // EMPTY FIELDS
    test('Empty fields returns 400', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "All fields are required"}),
          400,
        );
      });

      final response = await ApiService.login("", "", client: client);
      expect(response.statusCode, 400);
    });

  });
}