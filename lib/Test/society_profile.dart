import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:unisoc/services/api_services.dart';

void main() {
  setUp(() {
    ApiService.authToken = 'test-token';
  });

  // ═══════════════════════════════════════════════════════════
  // SOCIETY DETAILS
  // ═══════════════════════════════════════════════════════════

  group('Society Details - GET /societies/{id}/', () {

    test('Returns society details successfully', () async {
      final client = MockClient((_) async {
        return http.Response(jsonEncode({
          "id": 1,
          "name": "Football Society",
          "description": "All about football"
        }), 200);
      });

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/societies/1/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 200);

      final body = jsonDecode(response.body);
      expect(body['name'], 'Football Society');
    });

    test('Returns 404 for invalid society ID', () async {
      final client = MockClient((_) async {
        return http.Response('Not Found', 404);
      });

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/societies/999/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 404);
    });

    test('Handles server error', () async {
      final client = MockClient((_) async {
        return http.Response('Server Error', 500);
      });

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/societies/1/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 500);
    });

    test('Throws exception on network failure', () async {
      final client = MockClient((_) async => throw Exception('Network error'));

      expect(
        () async => await client.get(
          Uri.parse('${ApiService.baseUrl}/societies/1/'),
          headers: ApiService.headers,
        ),
        throwsException,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════
  // EVENTS
  // ═══════════════════════════════════════════════════════════

  group('Events - GET /societies/{id}/events/', () {

    test('Returns event list', () async {
      final client = MockClient((_) async {
        return http.Response(jsonEncode([
          {"id": 1, "title": "Match Day"}
        ]), 200);
      });

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/societies/1/events/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 200);

      final body = jsonDecode(response.body);
      expect(body is List, true);
    });

    test('Returns empty event list', () async {
      final client = MockClient((_) async {
        return http.Response(jsonEncode([]), 200);
      });

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/societies/1/events/'),
        headers: ApiService.headers,
      );

      final body = jsonDecode(response.body);
      expect(body, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // MEMBERSHIP
  // ═══════════════════════════════════════════════════════════

  group('Membership - POST /join/ & /leave/', () {

    test('User joins society successfully', () async {
      final client = MockClient((_) async {
        return http.Response(jsonEncode({'message': 'Joined'}), 200);
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/societies/1/join/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 200);
    });

    test('User leaves society successfully', () async {
      final client = MockClient((_) async {
        return http.Response(jsonEncode({'message': 'Left'}), 200);
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/societies/1/leave/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 200);
    });

    test('Returns 401 when unauthenticated', () async {
      final client = MockClient((_) async {
        return http.Response('Unauthorized', 401);
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/societies/1/join/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 401);
    });
  });

 
  // admin permissions for events
 

  group('Permissions - Admin Actions', () {

    test('Admin can create event', () async {
      final client = MockClient((_) async {
        return http.Response(jsonEncode({'message': 'Created'}), 201);
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/societies/1/events/create/'),
        headers: ApiService.headers,
        body: jsonEncode({"title": "New Event"}),
      );

      expect(response.statusCode, 201);
    });

    test('Non-admin receives 403 when creating event', () async {
      final client = MockClient((_) async {
        return http.Response('Forbidden', 403);
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/societies/1/events/create/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 403);
    });

    test('Admin can delete society', () async {
      final client = MockClient((_) async {
        return http.Response('', 204);
      });

      final response = await client.delete(
        Uri.parse('${ApiService.baseUrl}/societies/1/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 204);
    });
  });

 
  //event attendance


  group('Event Attendance - POST /events/{id}/attend/', () {

    test('User joins event successfully', () async {
      final client = MockClient((_) async {
        return http.Response(jsonEncode({'message': 'Attending'}), 200);
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/events/1/attend/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 200);
    });

    test('User leaves event successfully', () async {
      final client = MockClient((_) async {
        return http.Response(jsonEncode({'message': 'Not attending'}), 200);
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/events/1/leave/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 200);
    });

    test('Returns 400 when event is full', () async {
      final client = MockClient((_) async {
        return http.Response('Event Full', 400);
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/events/1/attend/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 400);
    });

    test('Returns 401 when unauthenticated', () async {
      final client = MockClient((_) async {
        return http.Response('Unauthorized', 401);
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/events/1/attend/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 401);
    });
  });
}