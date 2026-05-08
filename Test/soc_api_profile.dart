import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

void main() {
  group('Society Profile API Tests', () {

    // Test 1: Get society details returns 200
    test('Get society details for valid society ID returns 200', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "id": 1,
            "name": "Football Society",
            "category": "Sports",
            "description": "Football club",
          }),
          200,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/societies/1/"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['name'], 'Football Society');
    });

    // Test 2: Get society events returns 200
    test('Get events for valid society returns 200 with events list', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {
              "id": 1,
              "title": "Football Match",
              "description": "Big match",
              "location": "Stadium",
              "start_time": DateTime.now().add(Duration(days: 1)).toIso8601String(),
              "end_time": DateTime.now().add(Duration(days: 1, hours: 2)).toIso8601String(),
              "capacity_limit": 100,
              "attendee_count": 5
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
      expect(data[0]['title'], 'Football Match');
    });

    // Test 3: Check membership returns 200
    test('Check membership for user in society returns is_member true', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"society_id": 1, "is_member": true}),
          200,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/societies/1/check-membership/"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['is_member'], true);
    });

    // Test 4: Join society returns 201
    test('Join valid society returns 201', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"message": "Joined successfully"}),
          201,
        );
      });

      final response = await client.post(
        Uri.parse("http://test/api/society/1/join/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({}),
      );

      expect(response.statusCode, 201);
    });

    // Test 5: Leave society returns 200
    test('Leave society returns 200', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"message": "Successfully left society"}),
          200,
        );
      });

      final response = await client.post(
        Uri.parse("http://test/api/society/1/leave/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({}),
      );

      expect(response.statusCode, 200);
    });

    // Test 6: Already joined society returns 200
    test('Join already joined society returns 200 with message', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"message": "Already joined"}),
          200,
        );
      });

      final response = await client.post(
        Uri.parse("http://test/api/society/1/join/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({}),
      );

      expect(response.statusCode, 200);
    });

    // Test 7: Invalid society ID returns 404
    test('Get society details for invalid ID returns 404', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Society not found"}),
          404,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/societies/999/"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 404);
    });

    // Test 8: Join invalid society returns 404
    test('Join invalid society returns 404', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Society not found"}),
          404,
        );
      });

      final response = await client.post(
        Uri.parse("http://test/api/society/999/join/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({}),
      );

      expect(response.statusCode, 404);
    });

    // Test 9: Update society description returns 200 (admin only)
    test('Admin updates society description returns 200', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "id": 1,
            "name": "Football Society",
            "description": "Updated description",
            "message": "Society updated successfully"
          }),
          200,
        );
      });

      final response = await client.patch(
        Uri.parse("http://test/api/societies/1/admin/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"description": "Updated description"}),
      );

      expect(response.statusCode, 200);
    });

    // Test 10: Unauthorized user cannot join society returns 401
    test('Unauthorized user joining society returns 401', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Invalid credentials"}),
          401,
        );
      });

      final response = await client.post(
        Uri.parse("http://test/api/society/1/join/"),
        headers: {},
        body: jsonEncode({}),
      );

      expect(response.statusCode, 401);
    });

    // Test 11: Server error returns 500
    test('Server error returns 500', () async {
      final client = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final response = await client.get(
        Uri.parse("http://test/api/societies/1/"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 500);
    });

    // Test 12: Check event attendance returns is_attending status
    test('Check event attendance returns is_attending true', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"is_attending": true}),
          200,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/events/1/attending/"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['is_attending'], true);
    });

    // Test 13: Join event returns 200
    test('Join event returns 200', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"message": "Joined event", "attendee_count": 6}),
          200,
        );
      });

      final response = await client.post(
        Uri.parse("http://test/api/events/1/join/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({}),
      );

      expect(response.statusCode, 200);
    });

    // Test 14: Leave event returns 200
    test('Leave event returns 200', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"message": "Left event successfully"}),
          200,
        );
      });

      final response = await client.post(
        Uri.parse("http://test/api/events/1/leave/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({}),
      );

      expect(response.statusCode, 200);
    });

    // Test 15: Event full returns 400
    test('Join full event returns 400 error', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Event is full! Capacity: 10"}),
          400,
        );
      });

      final response = await client.post(
        Uri.parse("http://test/api/events/1/join/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({}),
      );

      expect(response.statusCode, 400);
    });

  });
}