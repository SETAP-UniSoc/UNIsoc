import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unisoc/screens/admin/admin_events_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

List<int> _eventsBody(List<Map<String, dynamic>> events) =>
    utf8.encode(jsonEncode(events));

Map<String, dynamic> _event({
  required int id,
  required String title,
  required String startTime,
  String description = 'Desc',
  String location = 'Hall',
  String? endTime,
  int? capacity,
}) =>
    {
      "id": id,
      "title": title,
      "description": description,
      "location": location,
      "start_time": startTime,
      "end_time": endTime ?? startTime,
      "capacity_limit": capacity,
    };

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── 1. Loading indicator → calendar ───────────────────────────────────────
  testWidgets(
      'renders loading indicator initially, then calendar when empty events load',
      (WidgetTester tester) async {
    final client = _mockEventsClient(body: _eventsBody([]), statusCode: 200);

    await tester.pumpWidget(
        MaterialApp(home: AdminEventsPage(societyId: 1, httpClient: client)));

    // Spinner visible before async loadEvents() completes
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Events Calendar'), findsOneWidget);
  });

  // ── 2. Two events on same date grouped as "2 events" ─────────────────────
  testWidgets('loads events and groups them by date correctly',
      (WidgetTester tester) async {
    final client = _mockEventsClient(
      body: _eventsBody([
        _event(id: 1, title: 'Event A', startTime: '2025-01-15T09:00:00Z'),
        _event(id: 2, title: 'Event B', startTime: '2025-01-15T14:00:00Z'),
      ]),
      statusCode: 200,
    );

    await tester.pumpWidget(
        MaterialApp(home: AdminEventsPage(societyId: 1, httpClient: client)));
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(AdminEventsPage)) as dynamic;
    expect((state.calendarEvents as List).length, 1);
    expect((state.calendarEvents as List).first.eventName, '2 events');
  });

  // ── 3. Single event = "1 events", two on same day = "2 events" ───────────
  testWidgets('single event and multiple events labelled correctly',
      (WidgetTester tester) async {
    final client = _mockEventsClient(
      body: _eventsBody([
        _event(id: 1, title: 'Solo Event', startTime: '2025-01-10T10:00:00Z'),
        _event(id: 2, title: 'Event 1', startTime: '2025-01-15T09:00:00Z'),
        _event(id: 3, title: 'Event 2', startTime: '2025-01-15T14:00:00Z'),
      ]),
      statusCode: 200,
    );

    await tester.pumpWidget(
        MaterialApp(home: AdminEventsPage(societyId: 1, httpClient: client)));
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(AdminEventsPage)) as dynamic;
    final names = (state.calendarEvents as List).map((e) => e.eventName).toList();

    expect(names, contains('1 events'));
    expect(names, contains('2 events'));
  });

  // ── 4. Tapping a date that has events shows the events dialog ─────────────
  testWidgets('tapping date with events shows events dialog',
      (WidgetTester tester) async {
    final client = _mockEventsClient(
      body: _eventsBody([
        _event(
          id: 1,
          title: 'Test Event',
          startTime: '2025-01-15T10:00:00Z',
          endTime: '2025-01-15T11:00:00Z',
          location: 'Test Hall',
          capacity: 100,
        ),
      ]),
      statusCode: 200,
    );

    await tester.pumpWidget(
        MaterialApp(home: AdminEventsPage(societyId: 1, httpClient: client)));
    await tester.pumpAndSettle();

    // Call onDateTapped directly on the state (avoids needing to tap the
    // calendar widget which is a third-party package)
    final state = tester.state(find.byType(AdminEventsPage)) as dynamic;
    state.onDateTapped(DateTime(2025, 1, 15));
    await tester.pumpAndSettle();

    expect(find.text('Events (1)'), findsOneWidget);
    expect(find.text('Test Event'), findsOneWidget);
  });

  // ── 5. Tapping a date with no events shows create dialog ──────────────────
  testWidgets('tapping date without events shows create dialog',
      (WidgetTester tester) async {
    final client = _mockEventsClient(body: _eventsBody([]), statusCode: 200);

    await tester.pumpWidget(
        MaterialApp(home: AdminEventsPage(societyId: 1, httpClient: client)));
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(AdminEventsPage)) as dynamic;
    state.onDateTapped(DateTime(2025, 2, 20));
    await tester.pumpAndSettle();

    expect(find.text('Create Event'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });

  // ── 6. getDateOnly() strips time component ────────────────────────────────
  // NOTE: the production method is getDateOnly(), NOT normalize().
  // normalize() does not exist in AdminEventsPage — this test was rewritten
  // to call the correct method name from the source code.
  testWidgets('getDateOnly() correctly strips time from DateTime',
      (WidgetTester tester) async {
    final client = _mockEventsClient(body: _eventsBody([]), statusCode: 200);

    await tester.pumpWidget(
        MaterialApp(home: AdminEventsPage(societyId: 1, httpClient: client)));
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(AdminEventsPage)) as dynamic;

    // getDateOnly() converts to local first, then strips time
    final dt = DateTime(2025, 1, 15, 14, 30, 45);
    final result = state.getDateOnly(dt) as DateTime;

    // Should equal the date-only version of the local representation
    final expected = DateTime(dt.toLocal().year, dt.toLocal().month, dt.toLocal().day);
    expect(result, equals(expected));
    expect(result.hour, equals(0));
    expect(result.minute, equals(0));
    expect(result.second, equals(0));
  });
}

http.Client _mockEventsClient({required List<int> body, required int statusCode}) {
  return MockClient((request) async {
    if (request.url.path.endsWith('/events/')) {
      return http.Response.bytes(body, statusCode);
    }
    return http.Response('Not Found', 404);
  });
}