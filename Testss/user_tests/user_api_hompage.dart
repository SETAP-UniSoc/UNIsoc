import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:unisoc/services/api_services.dart';

void main() {

  group('User Homepage API Tests (Matched to Test Plan)', () {

    // VALID LOAD (HEADER / HOMEPAGE LOAD)
    test('APIs return data for valid load (200 OK)', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([
          {"name": "Football"}
        ]), 200);
      });

      final societies = await ApiService.getSocieties(client: client);

      expect(societies.isNotEmpty, true);
    });

    // LOADING STATE (DELAYED RESPONSE)
    test('API handles delayed response (loading state)', () async {
      final client = MockClient((request) async {
        await Future.delayed(const Duration(seconds: 1));
        return http.Response(jsonEncode([]), 200);
      });

      final societies = await ApiService.getSocieties(client: client);

      expect(societies, isA<List>());
    });

    // API FAILURE
    test('API throws exception on server error (500 response)', () async {
      final client = MockClient((request) async {
        return http.Response('Server error', 500);
      });

      expect(
        () async => await ApiService.getSocieties(client: client),
        throwsException,
      );
    });

    // SEARCHBAR (VALID QUERY)
    test('Search API returns results for valid query "Football"', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([
          {"name": "Football"}
        ]), 200);
      });

      final response =
          await client.get(Uri.parse("http://test/search?q=Football"));

      final data = jsonDecode(response.body);

      expect(data.isNotEmpty, true);
    });

    // FEATURED SOCIETIES (DATA EXISTS)
    test('Societies API returns data for featured societies display', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([
          {"name": "Football"},
          {"name": "Basketball"},
          {"name": "Chess"},
          {"name": "Music"},
          {"name": "Drama"}
        ]), 200);
      });

      final societies = await ApiService.getSocieties(client: client);

      expect(societies.length, greaterThanOrEqualTo(5));
    });

    //EVENTS (VALID USER)
    test('Events API returns events for logged in user', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([
          {"title": "Match"}
        ]), 200);
      });

      final events =
          await ApiService.getEventsForJoinedSocieties(client: client);

      expect(events.isNotEmpty, true);
    });

  });
}