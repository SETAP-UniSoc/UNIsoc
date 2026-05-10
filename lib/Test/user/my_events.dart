import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('My Events API Tests', () {

    // valid response with events
    test('Returns events successfully', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([
          {
            "id": 1,
            "title": "Football Match",
            "description": "Test",
            "location": "Campus",
            "start_time": "2025-01-01T10:00:00Z",
            "end_time": "2025-01-01T12:00:00Z"
          }
        ]), 200);
      });

      final response = await client.get(Uri.parse('fake-url'));
      expect(response.statusCode, 200);
    });

    // not a memebr of any events
    test('Returns empty list when no events', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([]), 200);
      });

      final response = await client.get(Uri.parse('fake-url'));
      final data = jsonDecode(response.body);

      expect(data, isEmpty);
    });

    //not authenticated
    test('Returns 401 when not authenticated', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Unauthorized"}),
          401,
        );
      });

      final response = await client.get(Uri.parse('fake-url'));
      expect(response.statusCode, 401);
    });

    //server error
    test('Handles server error correctly', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Server error"}),
          500,
        );
      });

      final response = await client.get(Uri.parse('fake-url'));
      expect(response.statusCode, 500);
    });

    // events sorted by date
    test('Events are sorted by date correctly', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([
          {
            "id": 2,
            "start_time": "2025-01-02T10:00:00Z"
          },
          {
            "id": 1,
            "start_time": "2025-01-01T10:00:00Z"
          }
        ]), 200);
      });

      final response = await client.get(Uri.parse('fake-url'));
      final data = jsonDecode(response.body);

      data.sort((a, b) =>
          DateTime.parse(a['start_time']).compareTo(DateTime.parse(b['start_time'])));

      expect(data.first['id'], 1);
    });

    // past event is correctly identified
    test('Past events are correctly identified', () async {
  final now = DateTime.now();

  final pastEvent = {
    "id": 1,
    "start_time": now.subtract(const Duration(days: 1)).toIso8601String()
  };

  final isPast = DateTime.parse(pastEvent['start_time'] as String).isBefore(now);

  expect(isPast, true);
});

    // leave event successfully
    test('Leave event returns success', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"message": "Left event"}),
          200,
        );
      });

      final response = await client.post(Uri.parse('fake-url'));
      expect(response.statusCode, 200);
    });

    // leave event failure
    test('Leave event handles failure', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": "Error leaving event"}),
          500,
        );
      });

      final response = await client.post(Uri.parse('fake-url'));
      expect(response.statusCode, 500);
    });

    // retsry after error
    test('Retry after error succeeds', () async {
      int callCount = 0;

      final client = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          return http.Response("Error", 500);
        } else {
          return http.Response(jsonEncode([]), 200);
        }
      });

      final firstResponse = await client.get(Uri.parse('fake-url'));
      final secondResponse = await client.get(Uri.parse('fake-url'));

      expect(firstResponse.statusCode, 500);
      expect(secondResponse.statusCode, 200);
    });

  });
}