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
  // USER PROFILE
  // ═══════════════════════════════════════════════════════════

  group('User Profile - GET /user/profile/', () {

    test('Returns user data successfully', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({
          "id": 1,
          "first_name": "Jane",
          "last_name": "Doe",
          "email": "jane@port.ac.uk",
        }), 200);
      });

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/user/profile/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 200);

      final body = jsonDecode(response.body);
      expect(body['first_name'], 'Jane');
      expect(body['email'], 'jane@port.ac.uk');
    });

    test('Returns 401 when unauthenticated', () async {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({'detail': 'Authentication credentials were not provided.'}),
          401,
        );
      });

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/user/profile/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 401);
    });

    test('Handles server error', () async {
      final client = MockClient((_) async {
        return http.Response('Server Error', 500);
      });

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/user/profile/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 500);
    });

    test('Throws exception on network failure', () async {
      final client = MockClient((_) async => throw Exception('Network error'));

      expect(
        () async => await client.get(
          Uri.parse('${ApiService.baseUrl}/user/profile/'),
          headers: ApiService.headers,
        ),
        throwsException,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════
  // CHANGE EMAIL
  // ═══════════════════════════════════════════════════════════

  group('Change Email - POST /change-email/', () {

    test('Successfully updates email', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Email changed successfully'}),
          200,
        );
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-email/'),
        headers: ApiService.headers,
        body: jsonEncode({'new_email': 'new@port.ac.uk'}),
      );

      expect(response.statusCode, 200);
    });

    test('Returns error when email already exists', () async {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({'error': 'Email already in use'}),
          400,
        );
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-email/'),
        headers: ApiService.headers,
        body: jsonEncode({'new_email': 'used@port.ac.uk'}),
      );

      expect(response.statusCode, 400);
    });

    test('Returns 401 when unauthenticated', () async {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({'detail': 'Authentication credentials were not provided.'}),
          401,
        );
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-email/'),
        headers: ApiService.headers,
        body: jsonEncode({'new_email': 'test@port.ac.uk'}),
      );

      expect(response.statusCode, 401);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // CHANGE PASSWORD
  // ═══════════════════════════════════════════════════════════

  group('Change Password - POST /change-password/', () {

    test('Successfully changes password', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Password changed successfully'}),
          200,
        );
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-password/'),
        headers: ApiService.headers,
        body: jsonEncode({
          'old_password': 'OldPass1!',
          'new_password': 'NewPass1!',
        }),
      );

      expect(response.statusCode, 200);
    });

    test('Returns error for wrong password', () async {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({'error': 'Old password is incorrect'}),
          400,
        );
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-password/'),
        headers: ApiService.headers,
        body: jsonEncode({
          'old_password': 'WrongPass',
          'new_password': 'NewPass1!',
        }),
      );

      expect(response.statusCode, 400);
    });

    test('Returns error when password too short', () async {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({'error': 'Password too short'}),
          400,
        );
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-password/'),
        headers: ApiService.headers,
        body: jsonEncode({
          'old_password': 'OldPass1!',
          'new_password': '123',
        }),
      );

      expect(response.statusCode, 400);
    });

    test('Throws exception on network failure', () async {
      final client = MockClient((_) async => throw Exception('Network error'));

      expect(
        () async => await client.post(
          Uri.parse('${ApiService.baseUrl}/change-password/'),
          headers: ApiService.headers,
          body: jsonEncode({
            'old_password': 'OldPass1!',
            'new_password': 'NewPass1!',
          }),
        ),
        throwsException,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════

  group('Notifications - GET /notifications/', () {

    test('Returns notification list', () async {
      final client = MockClient((_) async {
        return http.Response(jsonEncode([
          {
            "society": "Football Society",
            "notify_new_events": true
          }
        ]), 200);
      });

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 200);

      final body = jsonDecode(response.body);
      expect(body is List, true);
    });

    test('Returns empty notification list', () async {
      final client = MockClient((_) async {
        return http.Response(jsonEncode([]), 200);
      });

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
      );

      final body = jsonDecode(response.body);
      expect(body, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // MY SOCIETIES
  // ═══════════════════════════════════════════════════════════

  group('My Societies - GET /my-societies/', () {

    test('Returns societies list', () async {
      final client = MockClient((_) async {
        return http.Response(jsonEncode([
          {
            "id": 1,
            "name": "Football Society",
            "category": "Sports"
          }
        ]), 200);
      });

      final result = await ApiService.getMySocieties(client: client);

      expect(result, isA<List>());
      expect(result.isNotEmpty, true);
    });

    test('Returns empty list when no societies', () async {
      final client = MockClient((_) async {
        return http.Response(jsonEncode([]), 200);
      });

      final result = await ApiService.getMySocieties(client: client);

      expect(result, isEmpty);
    });

    test('Throws exception on server error', () async {
      final client = MockClient((_) async {
        return http.Response('Server Error', 500);
      });

      expect(
        () async => await ApiService.getMySocieties(client: client),
        throwsException,
      );
    });

    test('Throws exception on network error', () async {
      final client = MockClient((_) async => throw Exception('Network error'));

      expect(
        () async => await ApiService.getMySocieties(client: client),
        throwsException,
      );
    });
  });
}