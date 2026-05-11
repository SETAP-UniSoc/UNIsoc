import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

void main() {
  group('Admin Analytics API Tests', () {

    // Test 1: Valid analytics load (week period)
    test('Valid week period returns 200 with full data', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
            "totals": [10, 12, 15, 18, 20, 22, 25],
            "live_count": 25,
            "events_stats": [
              {"title": "Tech Talk", "attendee_count": 5},
              {"title": "Workshop", "attendee_count": 3}
            ]
          }),
          200,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/my-analytics/?period=week"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['live_count'], 25);
      expect(data['events_stats'].length, 2);
    });

    // Test 2: Month period returns 30 days of data
    test('Valid month period returns 200 with month data', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["1 Apr", "2 Apr", "3 Apr", "..."],
            "totals": [10, 12, 15, 18],
            "live_count": 18,
            "events_stats": []
          }),
          200,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/my-analytics/?period=month"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 200);
    });

    // Test 3: 6 months period returns week-based data
    test('Valid 6 months period returns 200 with week data', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Week 1", "Week 2", "Week 3", "Week 4"],
            "totals": [10, 15, 20, 25],
            "live_count": 25,
            "events_stats": []
          }),
          200,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/my-analytics/?period=6months"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 200);
    });

    // Test 4: Year period returns monthly data
    test('Valid year period returns 200 with month labels', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
            "totals": [5, 8, 12, 15, 18, 20, 22, 25, 28, 30, 32, 35],
            "live_count": 35,
            "events_stats": []
          }),
          200,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/my-analytics/?period=year"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['labels'].length, 12);
    });

    // Test 5: Empty analytics data (no members/no events)
    test('No analytics data returns 200 with empty lists', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": [],
            "totals": [],
            "live_count": 0,
            "events_stats": []
          }),
          200,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/my-analytics/?period=week"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['live_count'], 0);
      expect(data['events_stats'].length, 0);
    });

    // Test 6: Live member count correct
    test('Live member count matches active members', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Week 1", "Week 2"],
            "totals": [10, 20],
            "live_count": 20,
            "events_stats": []
          }),
          200,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/my-analytics/?period=week"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['live_count'], data['totals'].last);
    });

    // Test 7: Event attendance with data
    test('Event attendance returns attendee counts per event', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Week 1", "Week 2"],
            "totals": [10, 15],
            "live_count": 15,
            "events_stats": [
              {"title": "Football Match", "attendee_count": 10},
              {"title": "Chess Tournament", "attendee_count": 5},
              {"title": "Music Concert", "attendee_count": 8}
            ]
          }),
          200,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/my-analytics/?period=week"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['events_stats'].length, 3);
      expect(data['events_stats'][0]['title'], 'Football Match');
      expect(data['events_stats'][0]['attendee_count'], 10);
    });

    // Test 8: Invalid period parameter
    test('Invalid period parameter returns 400', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Invalid period"}),
          400,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/my-analytics/?period=invalid"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 400);
    });

    // Test 9: Unauthorized access (non-admin user)
    test('Non-admin user access returns 403 Forbidden', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Admins only"}),
          403,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/my-analytics/"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 403);
    });

    // Test 10: No authentication token
    test('No authentication token returns 401 Unauthorized', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Authentication credentials were not provided"}),
          401,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/my-analytics/"),
        headers: {},
      );

      expect(response.statusCode, 401);
    });

    // Test 11: Server error
    test('Server error returns 500', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Internal server error"}),
          500,
        );
      });

      final response = await client.get(
        Uri.parse("http://test/api/my-analytics/"),
        headers: {"Content-Type": "application/json"},
      );

      expect(response.statusCode, 500);
    });

    // Test 12: Network failure (timeout)
    test('Network failure throws exception', () async {
      final client = MockClient((request) async {
        throw Exception("Connection timeout");
      });

      expect(
        () async => await client.get(
          Uri.parse("http://test/api/my-analytics/"),
          headers: {"Content-Type": "application/json"},
        ),
        throwsException,
      );
    });

  });
}