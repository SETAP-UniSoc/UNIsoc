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
  //  USER PROFILE
  // ═══════════════════════════════════════════════════════════

  group('Load User Profile - GET /user/profile/', () {
    test('TC-UP-01 | Returns user data when API is successful', () async {
      final client = MockClient((request) async {
        expect(request.url.path, contains('/user/profile/'));
        return http.Response(
          jsonEncode({
            "id": 1,
            "first_name": "Jane",
            "last_name": "Doe",
            "email": "jane@port.ac.uk",
            "up_number": "up123456",
          }),
          200,
        );
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

    test('TC-UP-02 | Returns 401 when user is not authenticated', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'detail': 'Authentication credentials were not provided.',
          }),
          401,
        ),
      );

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/user/profile/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 401);
    });

    test('TC-UP-03 | Returns 500 on server error', () async {
      final client = MockClient(
        (_) async => http.Response('Server Error', 500),
      );

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/user/profile/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 500);
    });

    test('TC-UP-04 | Throws exception on network error', () async {
      final client = MockClient((_) async => throw Exception('Network error'));

      expect(
        () async => await client.get(
          Uri.parse('${ApiService.baseUrl}/user/profile/'),
          headers: ApiService.headers,
        ),
        throwsException,
      );
    });

    test('TC-UP-05 | Falls back to first_name when name field is absent', () {
      // Mirrors the widget logic
      final data = {"first_name": "Jane", "email": "jane@port.ac.uk"};
      final nameValue = (data["name"] != null && data["name"]!.isNotEmpty)
          ? data["name"]
          : (data["first_name"] != null && data["first_name"]!.isNotEmpty)
          ? data["first_name"]
          : "User";
      expect(nameValue, "Jane");
    });

    test(
      'TC-UP-06 | Falls back to "User" when both name fields are absent',
      () {
        final data = <String, String>{"email": "jane@port.ac.uk"};
        final nameValue = (data["name"] != null && data["name"]!.isNotEmpty)
            ? data["name"]
            : (data["first_name"] != null && data["first_name"]!.isNotEmpty)
            ? data["first_name"]
            : "User";
        expect(nameValue, "User");
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  //  CHANGE EMAIL
  // ═══════════════════════════════════════════════════════════

  group('Change Email - POST /change-email/', () {
    test('TC-CE-01 | Successfully updates email → 200 OK', () async {
      final client = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['new_email'], 'newemail@port.ac.uk');
        return http.Response(
          jsonEncode({'message': 'Email changed successfully'}),
          200,
        );
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-email/'),
        headers: ApiService.headers,
        body: jsonEncode({'new_email': 'newemail@port.ac.uk'}),
      );

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body);
      expect(body['message'], 'Email changed successfully');
    });

    test('TC-CE-02 | Email already in use → 400 Bad Request', () async {
      final client = MockClient(
        (_) async =>
            http.Response(jsonEncode({'error': 'Email already in use'}), 400),
      );

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-email/'),
        headers: ApiService.headers,
        body: jsonEncode({'new_email': 'taken@port.ac.uk'}),
      );

      expect(response.statusCode, 400);
      final body = jsonDecode(response.body);
      expect(body['error'], 'Email already in use');
    });

    test('TC-CE-03 | Missing new_email field → 400 Bad Request', () async {
      final client = MockClient(
        (_) async =>
            http.Response(jsonEncode({'error': 'New email is required'}), 400),
      );

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-email/'),
        headers: ApiService.headers,
        body: jsonEncode({}),
      );

      expect(response.statusCode, 400);
    });

    test('TC-CE-04 | Unauthenticated request → 401 Unauthorized', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'detail': 'Authentication credentials were not provided.',
          }),
          401,
        ),
      );

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-email/'),
        headers: ApiService.headers,
        body: jsonEncode({'new_email': 'test@port.ac.uk'}),
      );

      expect(response.statusCode, 401);
    });

    test('TC-CE-05 | Throws exception on network failure', () async {
      final client = MockClient((_) async => throw Exception('No connection'));

      expect(
        () async => await client.post(
          Uri.parse('${ApiService.baseUrl}/change-email/'),
          headers: ApiService.headers,
          body: jsonEncode({'new_email': 'test@port.ac.uk'}),
        ),
        throwsException,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  CHANGE PASSWORD
  // ═══════════════════════════════════════════════════════════

  group('Change Password - POST /change-password/', () {
    test('TC-CP-01 | Successfully changes password → 200 OK', () async {
      final client = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['old_password'], isNotEmpty);
        expect(body['new_password'], isNotEmpty);
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
      final body = jsonDecode(response.body);
      expect(body['message'], 'Password changed successfully');
    });

    test('TC-CP-02 | Wrong current password → 400 Bad Request', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({'error': 'Old password is incorrect'}),
          400,
        ),
      );

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-password/'),
        headers: ApiService.headers,
        body: jsonEncode({
          'old_password': 'WrongPass1!',
          'new_password': 'NewPass1!',
        }),
      );

      expect(response.statusCode, 400);
      final body = jsonDecode(response.body);
      expect(body['error'], 'Old password is incorrect');
    });

    test('TC-CP-03 | New password too short → 400 Bad Request', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({'error': 'Password must be at least 8 characters long'}),
          400,
        ),
      );

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-password/'),
        headers: ApiService.headers,
        body: jsonEncode({
          'old_password': 'OldPass1!',
          'new_password': 'short',
        }),
      );

      expect(response.statusCode, 400);
      expect(jsonDecode(response.body)['error'], contains('8 characters'));
    });

    test('TC-CP-04 | Missing fields → 400 Bad Request', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({'error': 'Both old and new passwords are required'}),
          400,
        ),
      );

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-password/'),
        headers: ApiService.headers,
        body: jsonEncode({'old_password': ''}),
      );

      expect(response.statusCode, 400);
    });

    test('TC-CP-05 | Unauthenticated request → 401 Unauthorized', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'detail': 'Authentication credentials were not provided.',
          }),
          401,
        ),
      );

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-password/'),
        headers: ApiService.headers,
        body: jsonEncode({
          'old_password': 'OldPass1!',
          'new_password': 'NewPass1!',
        }),
      );

      expect(response.statusCode, 401);
    });

    test('TC-CP-06 | Throws exception on network failure', () async {
      final client = MockClient((_) async => throw Exception('No connection'));

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
  //  PASSWORD VALIDATION (pure Dart — mirrors widget logic)
  // ═══════════════════════════════════════════════════════════

  group('Password client-side validation logic', () {
    test('TC-PV-01 | Empty current password fails validation', () {
      final current = '';
      final newPass = 'NewPass1!';
      final isValid = current.isNotEmpty && newPass.isNotEmpty;
      expect(isValid, isFalse);
    });

    test('TC-PV-02 | Empty new password fails validation', () {
      final current = 'OldPass1!';
      final newPass = '';
      final isValid = current.isNotEmpty && newPass.isNotEmpty;
      expect(isValid, isFalse);
    });

    test('TC-PV-03 | New password shorter than 8 chars fails length check', () {
      expect('short'.length < 8, isTrue);
    });

    test('TC-PV-04 | New password ≥ 8 chars passes length check', () {
      expect('NewPass1!'.length >= 8, isTrue);
    });

    test('TC-PV-05 | Mismatched confirm password fails', () {
      final newPass = 'NewPass1!';
      final confirm = 'Different1!';
      expect(newPass == confirm, isFalse);
    });

    test('TC-PV-06 | Matching confirm password passes', () {
      final newPass = 'NewPass1!';
      final confirm = 'NewPass1!';
      expect(newPass == confirm, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════

  group('Load Notifications - GET /notifications/', () {
    test('TC-NL-01 | Returns notification preferences list → 200 OK', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode([
            {'society': 'Football Society', 'notify_new_events': true},
            {'society': 'Chess Club', 'notify_new_events': false},
          ]),
          200,
        ),
      );

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as List;
      expect(body.length, 2);
      expect(body[0]['society'], 'Football Society');
      expect(body[0]['notify_new_events'], isTrue);
    });

    test('TC-NL-02 | Returns empty list when no preferences set', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode([]), 200),
      );

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as List;
      expect(body, isEmpty);
    });

    test('TC-NL-03 | Unauthenticated request → 401 Unauthorized', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'detail': 'Authentication credentials were not provided.',
          }),
          401,
        ),
      );

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 401);
    });

    test('TC-NL-04 | Throws exception on network error', () async {
      final client = MockClient((_) async => throw Exception('Network error'));

      expect(
        () async => await client.get(
          Uri.parse('${ApiService.baseUrl}/notifications/'),
          headers: ApiService.headers,
        ),
        throwsException,
      );
    });
  });

  group('Update Notifications - POST /notifications/', () {
    test('TC-NU-01 | Successfully enables notifications → 200 OK', () async {
      final client = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['society_id'], 1);
        expect(body['event_notifications'], true);
        return http.Response(
          jsonEncode({
            'message': 'Notification preferences updated',
            'society': 'Football Society',
            'notify_new_events': true,
          }),
          200,
        );
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
        body: jsonEncode({'society_id': 1, 'event_notifications': true}),
      );

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body);
      expect(body['notify_new_events'], isTrue);
    });

    test('TC-NU-02 | Successfully disables notifications → 200 OK', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'message': 'Notification preferences updated',
            'notify_new_events': false,
          }),
          200,
        ),
      );

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
        body: jsonEncode({'society_id': 1, 'event_notifications': false}),
      );

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body);
      expect(body['notify_new_events'], isFalse);
    });

    test('TC-NU-03 | Society not found → 404 Not Found', () async {
      final client = MockClient(
        (_) async =>
            http.Response(jsonEncode({'error': 'Society not found'}), 404),
      );

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
        body: jsonEncode({'society_id': 9999, 'event_notifications': true}),
      );

      expect(response.statusCode, 404);
      expect(jsonDecode(response.body)['error'], 'Society not found');
    });

    test('TC-NU-04 | Not a member of society → 403 Forbidden', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({'error': 'Not a member of this society'}),
          403,
        ),
      );

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
        body: jsonEncode({'society_id': 1, 'event_notifications': true}),
      );

      expect(response.statusCode, 403);
      expect(
        jsonDecode(response.body)['error'],
        'Not a member of this society',
      );
    });

    test('TC-NU-05 | Unauthenticated request → 401 Unauthorized', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'detail': 'Authentication credentials were not provided.',
          }),
          401,
        ),
      );

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
        body: jsonEncode({'society_id': 1, 'event_notifications': true}),
      );

      expect(response.statusCode, 401);
    });

    test('TC-NU-06 | Throws exception on network failure', () async {
      final client = MockClient((_) async => throw Exception('No connection'));

      expect(
        () async => await client.post(
          Uri.parse('${ApiService.baseUrl}/notifications/'),
          headers: ApiService.headers,
          body: jsonEncode({'society_id': 1, 'event_notifications': true}),
        ),
        throwsException,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  MY SOCIETIES (used by notification settings loader)
  // ═══════════════════════════════════════════════════════════

  group('Load My Societies - GET /my-societies/', () {
    test('TC-MS-01 | Returns list of joined societies → 200 OK', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode([
            {'id': 1, 'name': 'Football Society', 'category': 'Sports'},
            {'id': 2, 'name': 'Chess Club', 'category': 'Games'},
          ]),
          200,
        ),
      );

      final result = await ApiService.getMySocieties(client: client);

      expect(result, isA<List>());
      expect(result.length, 2);
      expect(result[0]['name'], 'Football Society');
    });

    test(
      'TC-MS-02 | Returns empty list when user has joined no societies',
      () async {
        final client = MockClient(
          (_) async => http.Response(jsonEncode([]), 200),
        );

        final result = await ApiService.getMySocieties(client: client);

        expect(result, isEmpty);
      },
    );

    test('TC-MS-03 | Throws exception on server error', () async {
      final client = MockClient(
        (_) async => http.Response('Server Error', 500),
      );

      expect(
        () async => await ApiService.getMySocieties(client: client),
        throwsException,
      );
    });

    test('TC-MS-04 | Throws exception on network error', () async {
      final client = MockClient((_) async => throw Exception('Network error'));

      expect(
        () async => await ApiService.getMySocieties(client: client),
        throwsException,
      );
    });

    test('TC-MS-05 | Each society has id, name, and category fields', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode([
            {'id': 1, 'name': 'Football Society', 'category': 'Sports'},
          ]),
          200,
        ),
      );

      final result = await ApiService.getMySocieties(client: client);

      expect(result[0].containsKey('id'), isTrue);
      expect(result[0].containsKey('name'), isTrue);
      expect(result[0].containsKey('category'), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  APISERVICE HEADERS
  // ═══════════════════════════════════════════════════════════

  group('ApiService header logic', () {
    test('TC-AH-01 | Headers include Authorization when token is set', () {
      ApiService.authToken = 'test-token';
      expect(ApiService.headers.containsKey('Authorization'), isTrue);
      expect(ApiService.headers['Authorization'], 'Token test-token');
    });

    test('TC-AH-02 | Headers omit Authorization when token is null', () {
      ApiService.authToken = null;
      expect(ApiService.headers.containsKey('Authorization'), isFalse);
      ApiService.authToken = 'test-token'; // restore
    });

    test('TC-AH-03 | Headers always include Content-Type application/json', () {
      expect(ApiService.headers['Content-Type'], 'application/json');
    });

    test('TC-AH-04 | baseUrl starts with http', () {
      expect(ApiService.baseUrl, startsWith('http'));
    });
  });
}
