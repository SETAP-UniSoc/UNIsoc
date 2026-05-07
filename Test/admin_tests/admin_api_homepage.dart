import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

void main() {
  group('Admin Homepage API Tests', () {

    // Test 1: Get societies returns 200
    test('Get societies returns 200 with data', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {"id": 1, "name": "Football", "member_count": 10}
          ]),
          200,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/societies/"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data.isNotEmpty, true);
    });

    // Test 2: Get events returns 200
    test('Get events returns 200 with data', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {"id": 1, "title": "Event", "start_time": "2024-05-15T10:00:00Z"}
          ]),
          200,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/events/all/"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 200);
    });

    // Test 3: Search societies returns 200
    test('Search societies returns 200 with results', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {"id": 1, "name": "Football"}
          ]),
          200,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/societies/?q=Football"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 200);
    });

    // Test 4: Empty societies list returns 200
    test('Empty societies list returns 200 with empty array', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([]), 200);
      });

      final response = await client.get(
        Uri.parse("http://test/api/societies/"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data.isEmpty, true);
    });

    // Test 5: Server error returns 500
    test('Server error returns 500', () async {
      final client = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final response = await client.get(
        Uri.parse("http://test/api/societies/"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 500);
    });

    // Test 6: Unauthorized returns 401
    test('Unauthorized access returns 401', () async {
      final client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final response = await client.get(
        Uri.parse("http://test/api/societies/"),
        headers: {},
      );

      expect(response.statusCode, 401);
    });

  });
}