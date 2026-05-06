import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:unisoc/services/api_services.dart';

void main() {
  group('MySocietyPage API Tests', () {

    // valid load
    test('Returns societies when API is successful', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([
          {
            "id": 1, 
            "name": "Football Society",
            "category": "Sports",
            "description": "Football club"
          }
        ]), 200);
      });

      final result = await ApiService.getMySocieties(client: client);
      
      expect(result, isA<List>());
      expect(result.isNotEmpty, true);
      expect(result[0]["id"], 1);
      expect(result[0]["name"], "Football Society");
    });

    // empty list
    test('Returns empty list when no societies', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([]), 200);
      });

      final result = await ApiService.getMySocieties(client: client);
      
      expect(result, isA<List>());
      expect(result.isEmpty, true);
    });

    // 🔵 API FAILURE
    test('Throws exception on server error', () async {
      final client = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      expect(
        () async => await ApiService.getMySocieties(client: client),
        throwsException,
      );
    });

    // network error
    test('Throws exception on network error', () async {
      final client = MockClient((request) async {
        throw Exception("Network error");
      });

      expect(
        () async => await ApiService.getMySocieties(client: client),
        throwsException,
      );
    });
  });
}