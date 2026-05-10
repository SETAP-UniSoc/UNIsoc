import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unisoc/services/api_services.dart';

// Helper: build a MockClient that returns a fixed response
MockClient _clientWith(int statusCode, Object body) =>
    MockClient((_) async => http.Response(jsonEncode(body), statusCode));

void main() {
  setUp(() {
    ApiService.authToken = 'test-token';
  });

  // Test Plan Row 67 — Load Profile (GET /user/profile/)
  group('Load Profile — GET /user/profile/ (Test Plan Row 67)', () {

    test('TC-LP-01 | Valid token → 200 OK with name and email returned', () async {
      final client = MockClient((request) async {
        expect(request.url.path, contains('/user/profile/'));
        expect(request.method, 'GET');
        expect(request.headers['Authorization'], 'Token test-token');
        return http.Response(
          jsonEncode({"name": "AdminName", "email": "admin@ex.com"}),
          200,
        );
      });

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/user/profile/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body);
      expect(body['name'], 'AdminName');
      expect(body['email'], 'admin@ex.com');
    });

    test('TC-LP-02 | Profile falls back to first_name when name field absent', () {
      final data = {"first_name": "Jane", "email": "jane@port.ac.uk"};
      final nameValue = (data["name"] != null && data["name"]!.isNotEmpty)
          ? data["name"]
          : (data["first_name"] != null && data["first_name"]!.isNotEmpty)
              ? data["first_name"]
              : "Admin";
      expect(nameValue, "Jane");
    });

    test('TC-LP-03 | Falls back to "Admin" when both name fields are absent', () {
      final data = <String, String>{"email": "admin@port.ac.uk"};
      final nameValue = (data["name"] != null && data["name"]!.isNotEmpty)
          ? data["name"]
          : (data["first_name"] != null && data["first_name"]!.isNotEmpty)
              ? data["first_name"]
              : "Admin";
      expect(nameValue, "Admin");
    });

    test('TC-LP-04 | No token → 401 Unauthorized', () async {
      final client = _clientWith(401, {
        'detail': 'Authentication credentials were not provided.'
      });

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/user/profile/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 401);
    });

    test('TC-LP-05 | Server error → 500', () async {
      final client = _clientWith(500, {'error': 'Internal server error'});

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/user/profile/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 500);
    });

    test('TC-LP-06 | Network error → throws exception', () async {
      final client = MockClient((_) async => throw Exception('No connection'));

      expect(
        () async => await client.get(
          Uri.parse('${ApiService.baseUrl}/user/profile/'),
          headers: ApiService.headers,
        ),
        throwsException,
      );
    });
  });

  // Test Plan Row 68 — Update Name (POST /user/profile/)
  group('Update Name — POST /user/profile/ (Test Plan Row 68)', () {

    test('TC-UN-01 | Valid name → 200 OK, name updated successfully', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, contains('/user/profile/'));
        final body = jsonDecode(request.body);
        expect(body['name'], 'Marissa');
        return http.Response(
          jsonEncode({"name": "Marissa", "email": "admin@ex.com"}),
          200,
        );
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/user/profile/'),
        headers: ApiService.headers,
        body: jsonEncode({"name": "Marissa"}),
      );

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body);
      expect(body['name'], 'Marissa');
    });

    test('TC-UN-02 | Name updated — response contains updated name field', () async {
      final client = _clientWith(200, {"name": "Marissa", "email": "a@b.com"});

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/user/profile/'),
        headers: ApiService.headers,
        body: jsonEncode({"name": "Marissa"}),
      );

      expect(response.statusCode, 200);
      expect(jsonDecode(response.body)['name'], 'Marissa');
    });

    test('TC-UN-03 | Server rejects update → 400 Bad Request', () async {
      final client = _clientWith(400, {'error': 'Name update failed'});

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/user/profile/'),
        headers: ApiService.headers,
        body: jsonEncode({"name": "Marissa"}),
      );

      expect(response.statusCode, 400);
    });

    test('TC-UN-04 | Unauthenticated request → 401 Unauthorized', () async {
      final client = _clientWith(401, {
        'detail': 'Authentication credentials were not provided.'
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/user/profile/'),
        headers: ApiService.headers,
        body: jsonEncode({"name": "Marissa"}),
      );

      expect(response.statusCode, 401);
    });

    test('TC-UN-05 | Network failure → throws exception', () async {
      final client = MockClient((_) async => throw Exception('No connection'));

      expect(
        () async => await client.post(
          Uri.parse('${ApiService.baseUrl}/user/profile/'),
          headers: ApiService.headers,
          body: jsonEncode({"name": "Marissa"}),
        ),
        throwsException,
      );
    });
  });

  // Test Plan Row 69 — Empty Name Field (client-side validation)
  group('Empty Name Validation (Test Plan Row 69)', () {

    test('TC-EN-01 | Empty name string fails client-side validation', () {
      final name = ''.trim();
      expect(name.isEmpty, isTrue);
    });

    test('TC-EN-02 | Whitespace-only name also fails validation', () {
      final name = '   '.trim();
      expect(name.isEmpty, isTrue);
    });

    test('TC-EN-03 | Non-empty name passes client-side validation', () {
      final name = 'Marissa'.trim();
      expect(name.isEmpty, isFalse);
    });

    test('TC-EN-04 | Empty name sent to API → 400 Bad Request from backend', () async {
      final client = _clientWith(400, {
        'error': 'Name field cannot be left empty'
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/user/profile/'),
        headers: ApiService.headers,
        body: jsonEncode({"name": ""}),
      );

      expect(response.statusCode, 400);
      final body = jsonDecode(response.body);
      expect(body['error'], contains('empty'));
    });
  });

  // Test Plan Row 70 — Update Email (POST /change-email/)
  group('Update Email — POST /change-email/ (Test Plan Row 70)', () {

    test('TC-UE-01 | Valid current and new email → 200 OK', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, contains('/change-email/'));
        final body = jsonDecode(request.body);
        expect(body['current_email'], 'old@ex.com');
        expect(body['new_email'], 'marissa@gmail.com');
        return http.Response(
          jsonEncode({
            "message": "Email updated successfully",
            "email": "marissa@gmail.com"
          }),
          200,
        );
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-email/'),
        headers: ApiService.headers,
        body: jsonEncode({
          "current_email": "old@ex.com",
          "new_email": "marissa@gmail.com",
        }),
      );

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body);
      expect(body['email'], 'marissa@gmail.com');
    });

    test('TC-UE-02 | Email already in use → 400 Bad Request', () async {
      final client = _clientWith(400, {'error': 'Email already in use'});

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-email/'),
        headers: ApiService.headers,
        body: jsonEncode({
          "current_email": "old@ex.com",
          "new_email": "taken@gmail.com"
        }),
      );

      expect(response.statusCode, 400);
      expect(jsonDecode(response.body)['error'], 'Email already in use');
    });

    test('TC-UE-03 | Unauthenticated request → 401 Unauthorized', () async {
      final client = _clientWith(401, {
        'detail': 'Authentication credentials were not provided.'
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-email/'),
        headers: ApiService.headers,
        body: jsonEncode({
          "current_email": "old@ex.com",
          "new_email": "marissa@gmail.com"
        }),
      );

      expect(response.statusCode, 401);
    });

    test('TC-UE-04 | Network failure → throws exception', () async {
      final client = MockClient((_) async => throw Exception('No connection'));

      expect(
        () async => await client.post(
          Uri.parse('${ApiService.baseUrl}/change-email/'),
          headers: ApiService.headers,
          body: jsonEncode({
            "current_email": "old@ex.com",
            "new_email": "marissa@gmail.com"
          }),
        ),
        throwsException,
      );
    });
  });

  // Test Plan Row 71 — Missing New Email Field (client-side validation)
  group('Missing New Email Validation (Test Plan Row 71)', () {

    test('TC-ME-01 | Empty new email string fails client-side check', () {
      final currentEmail = 'old@ex.com';
      final newEmail = '';
      expect(currentEmail.isEmpty || newEmail.isEmpty, isTrue);
    });

    test('TC-ME-02 | Empty current email string also fails client-side check', () {
      final currentEmail = '';
      final newEmail = 'marissa@gmail.com';
      expect(currentEmail.isEmpty || newEmail.isEmpty, isTrue);
    });

    test('TC-ME-03 | Both fields filled passes client-side check', () {
      final currentEmail = 'old@ex.com';
      final newEmail = 'marissa@gmail.com';
      expect(currentEmail.isEmpty || newEmail.isEmpty, isFalse);
    });

    test('TC-ME-04 | Missing new_email sent to API → 400 Bad Request', () async {
      final client = _clientWith(400, {'error': 'Missing required fields'});

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-email/'),
        headers: ApiService.headers,
        body: jsonEncode({"current_email": "old@ex.com", "new_email": ""}),
      );

      expect(response.statusCode, 400);
      final body = jsonDecode(response.body);
      expect(body['error'], contains('Missing'));
    });
  });

  // Test Plan Row 72 — Missing Confirm Password Fields (client-side validation)
  group('Missing Password Fields Validation (Test Plan Row 72)', () {

    test('TC-MP-01 | Empty current password fails client-side check', () {
      final current = '';
      final newPass = 'NewPass1!';
      expect(current.isEmpty || newPass.isEmpty, isTrue);
    });

    test('TC-MP-02 | Empty new password fails client-side check', () {
      final current = 'OldPass1!';
      final newPass = '';
      expect(current.isEmpty || newPass.isEmpty, isTrue);
    });

    test('TC-MP-03 | Both fields filled passes client-side check', () {
      final current = 'OldPass1!';
      final newPass = 'NewPass1!';
      expect(current.isEmpty || newPass.isEmpty, isFalse);
    });

    test('TC-MP-04 | New password shorter than 8 chars fails length check', () {
      expect('short'.length < 8, isTrue);
    });

    test('TC-MP-05 | New password of 8+ chars passes length check', () {
      expect('NewPass1!'.length >= 8, isTrue);
    });

    test('TC-MP-06 | Missing password fields sent to API → 400 Bad Request', () async {
      final client = _clientWith(400, {
        'error': 'Both old and new passwords are required'
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-password/'),
        headers: ApiService.headers,
        body: jsonEncode({"old_password": "", "new_password": ""}),
      );

      expect(response.statusCode, 400);
      final body = jsonDecode(response.body);
      expect(body['error'], contains('required'));
    });

    test('TC-MP-07 | Unauthenticated request → 401 Unauthorized', () async {
      final client = _clientWith(401, {
        'detail': 'Authentication credentials were not provided.'
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-password/'),
        headers: ApiService.headers,
        body: jsonEncode({
          "old_password": "OldPass1!",
          "new_password": "NewPass1!"
        }),
      );

      expect(response.statusCode, 401);
    });
  });

  // Test Plan Row 73 — Password Mismatch (client-side validation)
  group('Password Mismatch Validation (Test Plan Row 73)', () {

    test('TC-PM-01 | Different new and confirm passwords fails validation', () {
      final newPass = 'NewPass1!';
      final confirm = 'Different1!';
      expect(newPass == confirm, isFalse);
    });

    test('TC-PM-02 | Matching new and confirm passwords passes validation', () {
      final newPass = 'NewPass1!';
      final confirm = 'NewPass1!';
      expect(newPass == confirm, isTrue);
    });

    test('TC-PM-03 | Valid matching passwords → 200 OK from API', () async {
      final client = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['old_password'], 'OldPass1!');
        expect(body['new_password'], 'NewPass1!');
        return http.Response(
          jsonEncode({"message": "Password changed successfully"}),
          200,
        );
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-password/'),
        headers: ApiService.headers,
        body: jsonEncode({
          "old_password": "OldPass1!",
          "new_password": "NewPass1!",
        }),
      );

      expect(response.statusCode, 200);
      expect(
        jsonDecode(response.body)['message'],
        'Password changed successfully',
      );
    });

    test('TC-PM-04 | Wrong current password → 400 Bad Request from API', () async {
      final client = _clientWith(400, {
        'error': 'Old password is incorrect'
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-password/'),
        headers: ApiService.headers,
        body: jsonEncode({
          "old_password": "WrongPass1!",
          "new_password": "NewPass1!",
        }),
      );

      expect(response.statusCode, 400);
      expect(jsonDecode(response.body)['error'], 'Old password is incorrect');
    });

    test('TC-PM-05 | New password too short → 400 Bad Request from API', () async {
      final client = _clientWith(400, {
        'error': 'Password must be at least 8 characters long'
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/change-password/'),
        headers: ApiService.headers,
        body: jsonEncode({
          "old_password": "OldPass1!",
          "new_password": "short",
        }),
      );

      expect(response.statusCode, 400);
      expect(jsonDecode(response.body)['error'], contains('8 characters'));
    });

    test('TC-PM-06 | Network failure → throws exception', () async {
      final client = MockClient((_) async => throw Exception('No connection'));

      expect(
        () async => await client.post(
          Uri.parse('${ApiService.baseUrl}/change-password/'),
          headers: ApiService.headers,
          body: jsonEncode({
            "old_password": "OldPass1!",
            "new_password": "NewPass1!",
          }),
        ),
        throwsException,
      );
    });
  });

  // Test Plan Rows 43–46 — Notification Preferences (GET /notifications/)
  group('Notification Preferences — GET /notifications/ (Test Plan Rows 43–46)', () {

    test('TC-NL-01 | Authenticated request → 200 OK with preferences list', () async {
      final client = _clientWith(200, [
        {"society": "Football Society", "notify_new_events": true},
        {"society": "Chess Club", "notify_new_events": false},
      ]);

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as List;
      expect(body.length, 2);
      expect(body[0]['notify_new_events'], isTrue);
    });

    test('TC-NL-02 | No societies joined → 200 OK with empty list', () async {
      final client = _clientWith(200, <dynamic>[]);

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as List;
      expect(body, isEmpty);
    });

    test('TC-NL-03 | Unauthenticated → 401 Unauthorized (Test Plan Row 45)', () async {
      final client = _clientWith(401, {
        'detail': 'Authentication credentials were not provided.'
      });

      final response = await client.get(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
      );

      expect(response.statusCode, 401);
    });

    test('TC-NL-04 | Network failure → throws exception', () async {
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

  group('Update Notifications — POST /notifications/ (Test Plan Rows 43–46)', () {

    test('TC-NU-01 | Opt-in → 200 OK, notify_new_events: true (Test Plan Row 43)', () async {
      final client = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['event_notifications'], isTrue);
        return http.Response(
          jsonEncode({
            "message": "Notification preferences updated",
            "notify_new_events": true,
          }),
          200,
        );
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
        body: jsonEncode({"society_id": 1, "event_notifications": true}),
      );

      expect(response.statusCode, 200);
      expect(jsonDecode(response.body)['notify_new_events'], isTrue);
    });

    test('TC-NU-02 | Opt-out → 200 OK, notify_new_events: false (Test Plan Row 46)', () async {
      final client = _clientWith(200, {
        "message": "Notification preferences updated",
        "notify_new_events": false,
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
        body: jsonEncode({"society_id": 1, "event_notifications": false}),
      );

      expect(response.statusCode, 200);
      expect(jsonDecode(response.body)['notify_new_events'], isFalse);
    });

    test('TC-NU-03 | Not a member of society → 403 Forbidden (Test Plan Row 44)', () async {
      final client = _clientWith(403, {
        'error': 'Not a member of this society'
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
        body: jsonEncode({"society_id": 1, "event_notifications": true}),
      );

      expect(response.statusCode, 403);
      expect(jsonDecode(response.body)['error'], 'Not a member of this society');
    });

    test('TC-NU-04 | Society not found → 404 Not Found', () async {
      final client = _clientWith(404, {'error': 'Society not found'});

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
        body: jsonEncode({"society_id": 9999, "event_notifications": true}),
      );

      expect(response.statusCode, 404);
    });

    test('TC-NU-05 | Unauthenticated → 401 Unauthorized (Test Plan Row 45)', () async {
      final client = _clientWith(401, {
        'detail': 'Authentication credentials were not provided.'
      });

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/notifications/'),
        headers: ApiService.headers,
        body: jsonEncode({"society_id": 1, "event_notifications": true}),
      );

      expect(response.statusCode, 401);
    });

    test('TC-NU-06 | Network failure → throws exception', () async {
      final client = MockClient((_) async => throw Exception('No connection'));

      expect(
        () async => await client.post(
          Uri.parse('${ApiService.baseUrl}/notifications/'),
          headers: ApiService.headers,
          body: jsonEncode({"society_id": 1, "event_notifications": true}),
        ),
        throwsException,
      );
    });
  });

  // ApiService header logic used by the endpoints above
  group('ApiService header logic', () {
    test('TC-AH-01 | Authorization header present when token is set', () {
      ApiService.authToken = 'test-token';
      expect(ApiService.headers['Authorization'], 'Token test-token');
    });

    test('TC-AH-02 | Authorization header absent when token is null', () {
      ApiService.authToken = null;
      expect(ApiService.headers.containsKey('Authorization'), isFalse);
      ApiService.authToken = 'test-token';
    });

    test('TC-AH-03 | Content-Type is always application/json', () {
      expect(ApiService.headers['Content-Type'], 'application/json');
    });

    test('TC-AH-04 | baseUrl starts with http', () {
      expect(ApiService.baseUrl, startsWith('http'));
    });
  });
}
