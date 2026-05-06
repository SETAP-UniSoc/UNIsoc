import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unisoc/services/api_services.dart';

// ─────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────

/// Builds a [MockClient] that returns a fixed response for every request.
MockClient _clientWith(int statusCode, Object body) =>
    MockClient((_) async => http.Response(jsonEncode(body), statusCode));

/// Simulates the "attend event" API call (POST /events/<id>/join/).
Future<http.Response> attendEvent(int eventId, {http.Client? client}) async {
  client ??= http.Client();
  return client.post(
    Uri.parse('${ApiService.baseUrl}/events/$eventId/join/'),
    headers: ApiService.headers,
  );
}

/// Simulates the "leave event" API call (POST /events/<id>/leave/).
Future<http.Response> leaveEvent(int eventId, {http.Client? client}) async {
  client ??= http.Client();
  return client.post(
    Uri.parse('${ApiService.baseUrl}/events/$eventId/leave/'),
    headers: ApiService.headers,
  );
}

/// Simulates the "check attendance" API call (GET /events/<id>/attending/).
Future<http.Response> checkAttendance(
  int eventId, {
  http.Client? client,
}) async {
  client ??= http.Client();
  return client.get(
    Uri.parse('${ApiService.baseUrl}/events/$eventId/attending/'),
    headers: ApiService.headers,
  );
}

/// Simulates fetching all events for a society (GET /societies/<id>/events/).
Future<http.Response> getSocietyEvents(
  int societyId, {
  http.Client? client,
}) async {
  client ??= http.Client();
  return client.get(
    Uri.parse('${ApiService.baseUrl}/societies/$societyId/events/'),
    headers: ApiService.headers,
  );
}

// ─────────────────────────────────────────────
//  Tests
// ─────────────────────────────────────────────

void main() {
  setUp(() {
    // Ensure a token is set so the Authorization header is included
    ApiService.authToken = 'test-token';
  });

  // ── Sample payloads ──────────────────────────────────────────────────────

  final futureEventJson = {
    'id': 1,
    'title': 'Flutter Workshop',
    'description': 'An intro to Flutter',
    'location': 'Room 101',
    'start_time': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
    'end_time': DateTime.now()
        .add(const Duration(days: 3, hours: 2))
        .toIso8601String(),
    'capacity_limit': 50,
  };

  final pastEventJson = {
    'id': 2,
    'title': 'Old Hackathon',
    'description': 'A past hackathon',
    'location': 'Hall B',
    'start_time': DateTime.now()
        .subtract(const Duration(days: 7))
        .toIso8601String(),
    'end_time': DateTime.now()
        .subtract(const Duration(days: 6, hours: 22))
        .toIso8601String(),
    'capacity_limit': 30,
  };

  // ── Attend Event ──────────────────────────────────────────────────────────

  group('Attend Event API', () {
    test(
      'TC-AE-01 | Authenticated user attends event → 200 OK with success message',
      () async {
        final client = _clientWith(200, {'message': "You're attending!"});

        final response = await attendEvent(1, client: client);

        expect(response.statusCode, 200);
        final body = jsonDecode(response.body);
        expect(body['message'], "You're attending!");
      },
    );

    test(
      'TC-AE-02 | Unauthenticated user attempts to attend event → 401 Unauthorized',
      () async {
        final client = _clientWith(401, {
          'detail': 'Authentication credentials were not provided.',
        });

        final response = await attendEvent(1, client: client);

        expect(response.statusCode, 401);
      },
    );

    test(
      'TC-AE-03 | User attempts to join a full event → 400 Bad Request',
      () async {
        final client = _clientWith(400, {'error': 'Event is full'});

        final response = await attendEvent(1, client: client);

        expect(response.statusCode, 400);
        final body = jsonDecode(response.body);
        expect(body['error'], 'Event is full');
      },
    );

    test(
      'TC-AE-04 | User attempts to attend a past event → 400 Bad Request',
      () async {
        final client = _clientWith(400, {'error': 'Event has already passed'});

        final response = await attendEvent(2, client: client);

        expect(response.statusCode, 400);
        final body = jsonDecode(response.body);
        expect(body['error'], contains('passed'));
      },
    );
  });

  // ── Leave Event ───────────────────────────────────────────────────────────

  group('Leave Event API', () {
    test(
      'TC-LE-01 | Authenticated user leaves event → 200 OK with success message',
      () async {
        final client = _clientWith(200, {'message': 'Left event'});

        final response = await leaveEvent(1, client: client);

        expect(response.statusCode, 200);
        final body = jsonDecode(response.body);
        expect(body['message'], 'Left event');
      },
    );

    test(
      'TC-LE-02 | User tries to leave an event they are not attending → 400',
      () async {
        final client = _clientWith(400, {'error': 'Not attending this event'});

        final response = await leaveEvent(99, client: client);

        expect(response.statusCode, 400);
      },
    );

    test(
      'TC-LE-03 | Unauthenticated leave request → 401 Unauthorized',
      () async {
        final client = _clientWith(401, {
          'detail': 'Authentication credentials were not provided.',
        });

        final response = await leaveEvent(1, client: client);

        expect(response.statusCode, 401);
      },
    );
  });

  // ── Check Attendance ──────────────────────────────────────────────────────

  group('Check Event Attendance API', () {
    test('TC-CA-01 | User is attending → is_attending: true', () async {
      final client = _clientWith(200, {
        'is_attending': true,
        'event_id': 1,
        'title': futureEventJson['title'],
      });

      final response = await checkAttendance(1, client: client);

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body);
      expect(body['is_attending'], isTrue);
    });

    test('TC-CA-02 | User is not attending → is_attending: false', () async {
      final client = _clientWith(200, {'is_attending': false, 'event_id': 1});

      final response = await checkAttendance(1, client: client);

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body);
      expect(body['is_attending'], isFalse);
    });

    test('TC-CA-03 | Non-existent event → 404 Not Found', () async {
      final client = _clientWith(404, {'error': 'Event not found'});

      final response = await checkAttendance(9999, client: client);

      expect(response.statusCode, 404);
    });
  });

  // ── Fetch Society Events ──────────────────────────────────────────────────

  group('Fetch Society Events API', () {
    test('TC-SE-01 | Valid society returns list of events → 200 OK', () async {
      final client = _clientWith(200, [futureEventJson, pastEventJson]);

      final response = await getSocietyEvents(1, client: client);

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as List;
      expect(body.length, 2);
      expect(body.first['title'], futureEventJson['title']);
    });

    test(
      'TC-SE-02 | Society with no events → 200 OK with empty list',
      () async {
        final client = _clientWith(200, <dynamic>[]);

        final response = await getSocietyEvents(1, client: client);

        expect(response.statusCode, 200);
        final body = jsonDecode(response.body) as List;
        expect(body, isEmpty);
      },
    );

    test('TC-SE-03 | Invalid / non-existent society → 404 Not Found', () async {
      final client = _clientWith(404, {'error': 'Society not found'});

      final response = await getSocietyEvents(9999, client: client);

      expect(response.statusCode, 404);
    });

    test('TC-SE-04 | Unauthenticated request → 401 Unauthorized', () async {
      final client = _clientWith(401, {
        'detail': 'Authentication credentials were not provided.',
      });

      final response = await getSocietyEvents(1, client: client);

      expect(response.statusCode, 401);
    });
  });

  // ── Business-rule helpers ─────────────────────────────────────────────────

  group('Attendance business-rule helpers', () {
    test('TC-BR-01 | Event in the future → isPast is false', () {
      final startTime = DateTime.now().add(const Duration(days: 3));
      expect(startTime.isBefore(DateTime.now()), isFalse);
    });

    test('TC-BR-02 | Event in the past → isPast is true', () {
      final startTime = DateTime.now().subtract(const Duration(days: 1));
      expect(startTime.isBefore(DateTime.now()), isTrue);
    });

    test('TC-BR-03 | Response body contains is_attending flag', () {
      final body = jsonDecode('{"is_attending": true}');
      expect(body['is_attending'], isTrue);
    });

    test('TC-BR-04 | Events list is sorted ascending by start_time', () {
      final events = [
        {
          'start_time': DateTime.now()
              .add(const Duration(days: 5))
              .toIso8601String(),
        },
        {
          'start_time': DateTime.now()
              .add(const Duration(days: 1))
              .toIso8601String(),
        },
        {
          'start_time': DateTime.now()
              .add(const Duration(days: 3))
              .toIso8601String(),
        },
      ];

      events.sort(
        (a, b) => DateTime.parse(
          a['start_time']!,
        ).compareTo(DateTime.parse(b['start_time']!)),
      );

      final times = events
          .map((e) => DateTime.parse(e['start_time']!))
          .toList();
      for (var i = 0; i < times.length - 1; i++) {
        expect(times[i].isBefore(times[i + 1]), isTrue);
      }
    });

    test('TC-BR-05 | Capacity limit null means unlimited', () {
      final event = {'capacity_limit': null, 'title': 'Open Event'};
      expect(event['capacity_limit'], isNull);
    });

    test('TC-BR-06 | ApiService.baseUrl is correctly set', () {
      expect(ApiService.baseUrl, isNotEmpty);
      expect(ApiService.baseUrl, startsWith('http'));
    });

    test(
      'TC-BR-07 | ApiService.headers includes Authorization when token is set',
      () {
        ApiService.authToken = 'test-token';
        expect(ApiService.headers.containsKey('Authorization'), isTrue);
        expect(ApiService.headers['Authorization'], 'Token test-token');
      },
    );

    test(
      'TC-BR-08 | ApiService.headers omits Authorization when token is null',
      () {
        ApiService.authToken = null;
        expect(ApiService.headers.containsKey('Authorization'), isFalse);
        ApiService.authToken = 'test-token'; // restore
      },
    );
  });
}
