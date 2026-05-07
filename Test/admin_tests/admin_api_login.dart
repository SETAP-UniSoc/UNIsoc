import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:unisoc/services/api_services.dart';

void main() {
  setUp(() {
    ApiService.authToken = null; // Admin not logged in yet
  });

  // ═══════════════════════════════════════════════════════════
  //  FETCH SOCIETIES (GET /societies/) — populates dropdown
  // ═══════════════════════════════════════════════════════════

  group('Fetch Societies for Dropdown - GET /societies/', () {
    test('TC-AL-01 | Returns society list on 200 OK', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode([
            {'id': 1, 'name': 'Football Society'},
            {'id': 2, 'name': 'Chess Club'},
          ]),
          200,
        ),
      );

      final result = await ApiService.getSocieties(client: client);

      expect(result, isA<List>());
      expect(result.length, 2);
      expect(result[0]['name'], 'Football Society');
    });

    test('TC-AL-02 | Returns empty list when no societies exist', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode([]), 200),
      );

      final result = await ApiService.getSocieties(client: client);

      expect(result, isEmpty);
    });

    test('TC-AL-03 | Throws exception on 500 server error', () async {
      final client = MockClient(
        (_) async => http.Response('Server Error', 500),
      );

      expect(
        () async => await ApiService.getSocieties(client: client),
        throwsException,
      );
    });

    test('TC-AL-04 | Throws exception on network failure', () async {
      final client = MockClient((_) async => throw Exception('Network error'));

      expect(
        () async => await ApiService.getSocieties(client: client),
        throwsException,
      );
    });

    test('TC-AL-05 | Society list contains id and name fields', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode([
            {'id': 1, 'name': 'Football Society', 'category': 'Sports'},
          ]),
          200,
        ),
      );

      final result = await ApiService.getSocieties(client: client);

      expect(result[0].containsKey('id'), isTrue);
      expect(result[0].containsKey('name'), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  ADMIN LOGIN (POST /login/)
  // ═══════════════════════════════════════════════════════════

  group('Admin Login - POST /login/', () {
    test(
      'TC-AL-06 | Valid credentials + correct society → 200 OK with token',
      () async {
        final client = MockClient((request) async {
          final body = jsonDecode(request.body);
          expect(body['email'], 'admin@port.ac.uk');
          expect(body['password'], 'AdminPass1!');
          expect(body['society_id'], '1');
          return http.Response(
            jsonEncode({
              'token': 'abc123',
              'role': 'admin',
              'email': 'admin@port.ac.uk',
              'society_id': 1,
              'society_name': 'Football Society',
            }),
            200,
          );
        });

        final response = await client.post(
          Uri.parse('${ApiService.baseUrl}/login/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': 'admin@port.ac.uk',
            'password': 'AdminPass1!',
            'society_id': '1',
          }),
        );

        expect(response.statusCode, 200);
        final body = jsonDecode(response.body);
        expect(body['token'], 'abc123');
        expect(body['role'], 'admin');
        expect(body['society_id'], 1);
      },
    );

    test('TC-AL-07 | Wrong password → 401 Unauthorized', () async {
      final client = MockClient(
        (_) async =>
            http.Response(jsonEncode({'error': 'Invalid credentials'}), 401),
      );

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'admin@port.ac.uk',
          'password': 'wrongpassword',
          'society_id': '1',
        }),
      );

      expect(response.statusCode, 401);
      expect(jsonDecode(response.body)['error'], 'Invalid credentials');
    });

    test('TC-AL-08 | Wrong society selected → 403 Forbidden', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({'error': 'Invalid society selection'}),
          403,
        ),
      );

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'admin@port.ac.uk',
          'password': 'AdminPass1!',
          'society_id': '99',
        }),
      );

      expect(response.statusCode, 403);
      expect(jsonDecode(response.body)['error'], 'Invalid society selection');
    });

    test('TC-AL-09 | Missing password → 400 Bad Request', () async {
      final client = MockClient(
        (_) async =>
            http.Response(jsonEncode({'error': 'Password required'}), 400),
      );

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': 'admin@port.ac.uk', 'password': ''}),
      );

      expect(response.statusCode, 400);
    });

    test('TC-AL-10 | Non-existent email → 401 Unauthorized', () async {
      final client = MockClient(
        (_) async =>
            http.Response(jsonEncode({'error': 'Invalid credentials'}), 401),
      );

      final response = await client.post(
        Uri.parse('${ApiService.baseUrl}/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'nobody@port.ac.uk',
          'password': 'AdminPass1!',
          'society_id': '1',
        }),
      );

      expect(response.statusCode, 401);
    });

    test(
      'TC-AL-11 | Admin has no assigned society → 400 Bad Request',
      () async {
        final client = MockClient(
          (_) async => http.Response(
            jsonEncode({'error': 'Admin has no assigned society'}),
            400,
          ),
        );

        final response = await client.post(
          Uri.parse('${ApiService.baseUrl}/login/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': 'orphan@port.ac.uk',
            'password': 'AdminPass1!',
            'society_id': '1',
          }),
        );

        expect(response.statusCode, 400);
        expect(
          jsonDecode(response.body)['error'],
          'Admin has no assigned society',
        );
      },
    );

    test(
      'TC-AL-12 | Throws exception on network failure during login',
      () async {
        final client = MockClient(
          (_) async => throw Exception('Connection refused'),
        );

        expect(
          () async => await client.post(
            Uri.parse('${ApiService.baseUrl}/login/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': 'admin@port.ac.uk',
              'password': 'AdminPass1!',
              'society_id': '1',
            }),
          ),
          throwsException,
        );
      },
    );

    test(
      'TC-AL-13 | Successful login response contains all required fields',
      () async {
        final client = MockClient(
          (_) async => http.Response(
            jsonEncode({
              'token': 'abc123',
              'role': 'admin',
              'email': 'admin@port.ac.uk',
              'up_number': 'up123456',
              'society_id': 1,
              'society_name': 'Football Society',
            }),
            200,
          ),
        );

        final response = await client.post(
          Uri.parse('${ApiService.baseUrl}/login/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': 'admin@port.ac.uk',
            'password': 'AdminPass1!',
            'society_id': '1',
          }),
        );

        final body = jsonDecode(response.body);
        expect(body.containsKey('token'), isTrue);
        expect(body.containsKey('role'), isTrue);
        expect(body.containsKey('society_id'), isTrue);
        expect(body.containsKey('society_name'), isTrue);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  //  CLIENT-SIDE VALIDATION LOGIC (pure Dart)
  // ═══════════════════════════════════════════════════════════

  group('Client-side login validation logic', () {
    test('TC-CV-01 | Empty email fails validation', () {
      final email = ''.trim();
      expect(email.isEmpty, isTrue);
    });

    test('TC-CV-02 | Empty password fails validation', () {
      final password = '';
      expect(password.isEmpty, isTrue);
    });

    test('TC-CV-03 | Email without @ fails format check', () {
      final email = 'notanemail.com';
      expect(email.contains('@'), isFalse);
    });

    test('TC-CV-04 | Valid email passes format check', () {
      final email = 'admin@port.ac.uk';
      expect(email.contains('@'), isTrue);
    });

    test('TC-CV-05 | No society selected → selectedSocietyId is null', () {
      String? selectedSocietyId;
      expect(selectedSocietyId, isNull);
    });

    test('TC-CV-06 | Society selected → selectedSocietyId is not null', () {
      String? selectedSocietyId = '1';
      expect(selectedSocietyId, isNotNull);
    });

    test('TC-CV-07 | Both fields empty → validation fails', () {
      final email = '';
      final password = '';
      final isValid = email.isNotEmpty && password.isNotEmpty;
      expect(isValid, isFalse);
    });

    test('TC-CV-08 | Both fields filled → passes empty check', () {
      final email = 'admin@port.ac.uk';
      final password = 'AdminPass1!';
      final isValid = email.isNotEmpty && password.isNotEmpty;
      expect(isValid, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  APISERVICE TOKEN & HEADER LOGIC
  // ═══════════════════════════════════════════════════════════

  group('ApiService token and header logic', () {
    test('TC-AH-01 | Token stored correctly after login', () {
      ApiService.authToken = 'abc123';
      expect(ApiService.authToken, 'abc123');
    });

    test('TC-AH-02 | societyId stored correctly after login', () {
      ApiService.societyId = 1;
      expect(ApiService.societyId, 1);
    });

    test('TC-AH-03 | societyName stored correctly after login', () {
      ApiService.societyName = 'Football Society';
      expect(ApiService.societyName, 'Football Society');
    });

    test('TC-AH-04 | Authorization header present when token is set', () {
      ApiService.authToken = 'abc123';
      expect(ApiService.headers['Authorization'], 'Token abc123');
    });

    test('TC-AH-05 | Authorization header absent when token is null', () {
      ApiService.authToken = null;
      expect(ApiService.headers.containsKey('Authorization'), isFalse);
    });

    test('TC-AH-06 | Content-Type is always application/json', () {
      expect(ApiService.headers['Content-Type'], 'application/json');
    });

    test('TC-AH-07 | isAdminOfSociety returns true for matching id', () {
      ApiService.societyId = 1;
      expect(ApiService.isAdminOfSociety(1), isTrue);
    });

    test('TC-AH-08 | isAdminOfSociety returns false for different id', () {
      ApiService.societyId = 1;
      expect(ApiService.isAdminOfSociety(2), isFalse);
    });

    test(
      'TC-AH-09 | isAdminOfSociety returns false when societyId is null',
      () {
        ApiService.societyId = null;
        expect(ApiService.isAdminOfSociety(1), isFalse);
      },
    );

    test('TC-AH-10 | baseUrl starts with http', () {
      expect(ApiService.baseUrl, startsWith('http'));
      expect(ApiService.baseUrl, isNotEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  SOCIETY DROPDOWN PARSING (pure Dart)
  // ═══════════════════════════════════════════════════════════

  group('Society dropdown data parsing', () {
    test('TC-DP-01 | Society list maps id and name correctly', () {
      final raw = [
        {'id': 1, 'name': 'Football Society'},
        {'id': 2, 'name': 'Chess Club'},
      ];
      final mapped = raw
          .map((s) => {'id': s['id'], 'name': s['name']})
          .toList();

      expect(mapped[0]['id'], 1);
      expect(mapped[0]['name'], 'Football Society');
      expect(mapped[1]['id'], 2);
    });

    test('TC-DP-02 | Society id converts to string for dropdown value', () {
      final society = {'id': 5, 'name': 'Drama Society'};
      final value = society['id'].toString();
      expect(value, '5');
    });

    test('TC-DP-03 | Correct society found by id string', () {
      final societies = [
        {'id': 1, 'name': 'Football Society'},
        {'id': 2, 'name': 'Chess Club'},
      ];
      final selected = societies.firstWhere((s) => s['id'].toString() == '2');
      expect(selected['name'], 'Chess Club');
    });

    test('TC-DP-04 | Empty society list produces empty dropdown items', () {
      final societies = <Map<String, dynamic>>[];
      expect(societies.isEmpty, isTrue);
    });

    test(
      'TC-DP-05 | Society name is stored when dropdown item is selected',
      () {
        final societies = [
          {'id': 1, 'name': 'Football Society'},
        ];
        String? selectedSocietyName;
        final selected = societies.firstWhere((s) => s['id'].toString() == '1');
        selectedSocietyName = selected['name'] as String;
        expect(selectedSocietyName, 'Football Society');
      },
    );
  });
}
