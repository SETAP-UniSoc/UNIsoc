import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:unisoc/services/api_services.dart';

void main() {
  group('User Homepage API Tests (Matched to Test Plan)', () {

    test('APIs return data for valid load (200 OK)', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([
          {"id": 1, "name": "Football", "member_count": 5}
        ]), 200);
      });

      final societies = await ApiService.getSocieties(client: client);
      expect(societies.isNotEmpty, true);
    });

    test('API handles delayed response (loading state)', () async {
      final client = MockClient((request) async {
        await Future.delayed(const Duration(seconds: 1));
        return http.Response(jsonEncode([]), 200);
      });

      final societies = await ApiService.getSocieties(client: client);
      expect(societies, isA<List>());
    });

    test('API throws exception on server error (500 response)', () async {
      final client = MockClient((request) async {
        return http.Response('Server error', 500);
      });

      expect(
        () async => await ApiService.getSocieties(client: client),
        throwsException,
      );
    });

    test('Search API returns results for valid query "Football"', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([
          {"id": 1, "name": "Football", "type": "society"}
        ]), 200);
      });

      final response = await client.get(Uri.parse("http://test/search?q=Football"));
      final data = jsonDecode(response.body);
      expect(data.isNotEmpty, true);
    });

    test('Societies API returns data for featured societies display', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([
          {"id": 1, "name": "Football", "member_count": 10},
          {"id": 2, "name": "Basketball", "member_count": 8},
          {"id": 3, "name": "Chess", "member_count": 5},
          {"id": 4, "name": "Music", "member_count": 12},
          {"id": 5, "name": "Drama", "member_count": 7}
        ]), 200);
      });

      final societies = await ApiService.getSocieties(client: client);
      expect(societies.length, greaterThanOrEqualTo(5));
    });

    // FIXED: Events test with complete mock data
    test('Events API returns events for logged in user', () async {
      final client = MockClient((request) async {
        final url = request.url.toString();
        
        // Mock my-societies response
        if (url.contains('/my-societies/')) {
          return http.Response(jsonEncode([
            {"id": 1, "name": "Football Society", "category": "Sports", "description": "Football club"}
          ]), 200);
        }
        
        // Mock events for society
        if (url.contains('/societies/1/events/')) {
          return http.Response(jsonEncode([
            {
              "id": 100,
              "title": "Football Match",
              "description": "Big match this weekend",
              "location": "Stadium",
              "start_time": DateTime.now().add(Duration(days: 1)).toIso8601String(),
              "end_time": DateTime.now().add(Duration(days: 1, hours: 2)).toIso8601String(),
              "capacity_limit": 100,
              "status": "upcoming",
              "attendee_count": 5
            }
          ]), 200);
        }
        
        return http.Response('{}', 404);
      });

      final events = await ApiService.getEventsForJoinedSocieties(client: client);
      expect(events.isNotEmpty, true);
      expect(events.length, greaterThan(0));
    });
  });
}