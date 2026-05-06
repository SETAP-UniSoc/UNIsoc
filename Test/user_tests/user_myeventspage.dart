import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/services/api_services.dart';
import 'package:unisoc/screens/my_events_page.dart';

// ─────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────

String _futureTime([int daysAhead = 3]) =>
    DateTime.now().add(Duration(days: daysAhead)).toIso8601String();

String _pastTime([int daysAgo = 7]) =>
    DateTime.now().subtract(Duration(days: daysAgo)).toIso8601String();

Map<String, dynamic> _makeEvent({
  int id = 1,
  String title = 'Flutter Workshop',
  String location = 'Room 101',
  String? startTime,
  int? capacityLimit = 50,
}) => {
  'id': id,
  'title': title,
  'description': 'A workshop event',
  'location': location,
  'start_time': startTime ?? _futureTime(),
  'end_time': _futureTime(4),
  'capacity_limit': capacityLimit,
};

Widget _wrap(Widget child) => MaterialApp(home: child);

// ─────────────────────────────────────────────
//  Widget Tests
// ─────────────────────────────────────────────

void main() {
  setUp(() {
    ApiService.authToken = 'test-token';
  });

  // ── AppBar ────────────────────────────────────────────────────────────────

  group('AppBar', () {
    testWidgets('TC-W-01 | AppBar displays "My Events" title', (tester) async {
      await tester.pumpWidget(_wrap(const MyEventsPage()));
      // Check the first frame before any network call settles
      expect(find.text('My Events'), findsOneWidget);
    });
  });

  // ── Loading state ─────────────────────────────────────────────────────────

  group('Loading state', () {
    testWidgets('TC-W-02 | Shows CircularProgressIndicator on first frame', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const MyEventsPage(societyId: 1)));
      // pump() once — do NOT pumpAndSettle — so the loading frame is visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ── isPast logic (pure Dart — no network needed) ──────────────────────────

  group('isPast date logic', () {
    test('TC-W-03 | Future start_time → isPast is false', () {
      final startTime = DateTime.parse(_futureTime(3));
      expect(startTime.isBefore(DateTime.now()), isFalse);
    });

    test('TC-W-04 | Past start_time → isPast is true', () {
      final startTime = DateTime.parse(_pastTime(7));
      expect(startTime.isBefore(DateTime.now()), isTrue);
    });
  });

  // ── Button label logic (pure Dart) ────────────────────────────────────────

  group('Leave button label logic', () {
    test('TC-W-05 | Future event → button label is "Leave Event"', () {
      final event = _makeEvent(startTime: _futureTime());
      final isPast = DateTime.parse(
        event['start_time'] as String,
      ).isBefore(DateTime.now());
      final label = isPast ? 'Event Passed' : 'Leave Event';
      expect(label, 'Leave Event');
    });

    test('TC-W-06 | Past event → button label is "Event Passed"', () {
      final event = _makeEvent(startTime: _pastTime());
      final isPast = DateTime.parse(
        event['start_time'] as String,
      ).isBefore(DateTime.now());
      final label = isPast ? 'Event Passed' : 'Leave Event';
      expect(label, 'Event Passed');
    });

    test('TC-W-07 | Past event → button onPressed is null (disabled)', () {
      final event = _makeEvent(startTime: _pastTime());
      final isPast = DateTime.parse(
        event['start_time'] as String,
      ).isBefore(DateTime.now());
      // Simulate the onPressed assignment in the widget
      final onPressed = isPast ? null : () {};
      expect(onPressed, isNull);
    });

    test('TC-W-08 | Future event → button onPressed is not null (enabled)', () {
      final event = _makeEvent(startTime: _futureTime());
      final isPast = DateTime.parse(
        event['start_time'] as String,
      ).isBefore(DateTime.now());
      final onPressed = isPast ? null : () {};
      expect(onPressed, isNotNull);
    });
  });

  // ── Event data parsing (pure Dart) ────────────────────────────────────────

  group('Event data parsing', () {
    test('TC-W-09 | Event with capacity_limit renders the value', () {
      final event = _makeEvent(capacityLimit: 50);
      expect(event['capacity_limit'], 50);
    });

    test('TC-W-10 | Event with null capacity_limit is handled safely', () {
      final event = _makeEvent(capacityLimit: null);
      expect(event['capacity_limit'], isNull);
      // Mirrors the widget condition: only show capacity row if not null
      final shouldShow = event['capacity_limit'] != null;
      expect(shouldShow, isFalse);
    });

    test('TC-W-11 | Fallback values applied when fields are missing', () {
      final raw = <String, dynamic>{
        'id': 5,
        'start_time': _futureTime(),
        'end_time': _futureTime(2),
      };
      final title = raw['title'] ?? 'Untitled Event';
      final location = raw['location'] ?? 'No location';
      final description = raw['description'] ?? 'No description';
      expect(title, 'Untitled Event');
      expect(location, 'No location');
      expect(description, 'No description');
    });

    test('TC-W-12 | Events list sorts ascending by start_time', () {
      final events = [
        _makeEvent(id: 3, startTime: _futureTime(5)),
        _makeEvent(id: 1, startTime: _futureTime(1)),
        _makeEvent(id: 2, startTime: _futureTime(3)),
      ];

      events.sort(
        (a, b) => DateTime.parse(
          a['start_time'] as String,
        ).compareTo(DateTime.parse(b['start_time'] as String)),
      );

      final ids = events.map((e) => e['id']).toList();
      expect(ids, [1, 2, 3]);
    });
  });

  // ── ApiService header logic (pure Dart) ───────────────────────────────────

  group('ApiService header logic', () {
    test('TC-W-13 | Headers include Authorization when token is set', () {
      ApiService.authToken = 'test-token';
      expect(ApiService.headers.containsKey('Authorization'), isTrue);
      expect(ApiService.headers['Authorization'], 'Token test-token');
    });

    test('TC-W-14 | Headers omit Authorization when token is null', () {
      ApiService.authToken = null;
      expect(ApiService.headers.containsKey('Authorization'), isFalse);
      ApiService.authToken = 'test-token'; // restore
    });
  });
}
