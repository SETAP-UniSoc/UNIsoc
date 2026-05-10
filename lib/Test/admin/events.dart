import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

void main() {
  group('Admin Events API Tests', () {

    // Test 1: Get events for a society returns 200
    test('Get events for valid society returns 200 with events list', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {
              "id": 1,
              "title": "Football Match",
              "description": "Big match",
              "location": "Stadium",
              "start_time": "2024-05-15T10:00:00Z",
              "end_time": "2024-05-15T12:00:00Z",
              "capacity_limit": 100
            }
          ]),
          200,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/societies/1/events/"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data is List, true);
      expect(data.length, 1);
      expect(data[0]["title"], "Football Match");
    });

    // Test 2: Create event successfully returns 201
    test('Create event with valid data returns 201', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "id": 5,
            "title": "New Event",
            "message": "Event created successfully"
          }),
          201,
        );
      });

      final response = await client.post(
        Uri.parse("http://test/api/societies/1/events/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": "New Event",
          "description": "Description",
          "location": "Room 101",
          "start_time": "2024-05-15T10:00:00Z",
          "end_time": "2024-05-15T12:00:00Z"
        }),
      );

      expect(response.statusCode, 201);
    });

    // Test 3: Create event with missing fields returns 400
    test('Create event with missing title returns 400', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Title is required"}),
          400,
        );
      });

      final response = await client.post(
        Uri.parse("http://test/api/societies/1/events/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "description": "No title",
          "location": "Room 101",
          "start_time": "2024-05-15T10:00:00Z",
          "end_time": "2024-05-15T12:00:00Z"
        }),
      );

      expect(response.statusCode, 400);
    });

    // Test 4: Create event with invalid capacity returns 400
    test('Create event with negative capacity returns 400', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Invalid capacity"}),
          400,
        );
      });

      final response = await client.post(
        Uri.parse("http://test/api/societies/1/events/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": "Event",
          "description": "Desc",
          "location": "Room",
          "start_time": "2024-05-15T10:00:00Z",
          "end_time": "2024-05-15T12:00:00Z",
          "capacity_limit": -5
        }),
      );

      expect(response.statusCode, 400);
    });

    // Test 5: Update event successfully returns 200
    test('Update existing event returns 200', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"message": "Event updated successfully"}),
          200,
        );
      });

      final response = await client.put(
        Uri.parse("http://test/api/events/1/update/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": "Updated Title",
          "description": "Updated Desc",
          "location": "Updated Location"
        }),
      );

      expect(response.statusCode, 200);
    });

    // Test 6: Delete event successfully returns 204
    test('Delete existing event returns 204', () async {
      final client = MockClient((request) async {
        return http.Response('', 204);
      });

      final response = await client.delete(
        Uri.parse("http://test/api/events/1/delete/"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 204);
    });

    // Test 7: Invalid society ID returns 404
    test('Get events for invalid society returns 404', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Society not found"}),
          404,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/societies/999/events/"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 404);
    });

    // Test 8: Unauthorized create event returns 403
    test('Non-admin creating event returns 403', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Admins only"}),
          403,
        );
      });

      final response = await client.post(
        Uri.parse("http://test/api/societies/1/events/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": "Event",
          "description": "Desc",
          "location": "Room",
          "start_time": "2024-05-15T10:00:00Z",
          "end_time": "2024-05-15T12:00:00Z"
        }),
      );

      expect(response.statusCode, 403);
    });

    // Test 9: Server error returns 500
    test('Server error during event creation returns 500', () async {
      final client = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final response = await client.post(
        Uri.parse("http://test/api/societies/1/events/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": "Event",
          "description": "Desc",
          "location": "Room",
          "start_time": "2024-05-15T10:00:00Z",
          "end_time": "2024-05-15T12:00:00Z"
        }),
      );

      expect(response.statusCode, 500);
    });

    // Test 10: No authentication token returns 401
    test('No authentication token returns 401', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Authentication credentials were not provided"}),
          401,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/societies/1/events/"),
        headers: {},
      );

      expect(response.statusCode, 401);
    });

  });
}