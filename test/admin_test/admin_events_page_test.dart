import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  tearDown(() {
    HttpOverrides.global = null;
  });

  // ── 1. Loading indicator → calendar ───────────────────────────────────────
  testWidgets(
      'renders loading indicator initially, then calendar when empty events load',
      (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global =
        _MockEventsHttpOverrides(body: _eventsBody([]), statusCode: 200);

    try {
      await tester.pumpWidget(
          const MaterialApp(home: AdminEventsPage(societyId: 1)));

      // Spinner visible before async loadEvents() completes
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Events Calendar'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  // ── 2. Two events on same date grouped as "2 events" ─────────────────────
  testWidgets('loads events and groups them by date correctly',
      (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockEventsHttpOverrides(
      body: _eventsBody([
        _event(id: 1, title: 'Event A', startTime: '2025-01-15T09:00:00Z'),
        _event(id: 2, title: 'Event B', startTime: '2025-01-15T14:00:00Z'),
      ]),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(
          const MaterialApp(home: AdminEventsPage(societyId: 1)));
      await tester.pumpAndSettle();

      expect(find.text('2 events'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  // ── 3. Single event = "1 events", two on same day = "2 events" ───────────
  testWidgets('single event and multiple events labelled correctly',
      (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockEventsHttpOverrides(
      body: _eventsBody([
        _event(id: 1, title: 'Solo Event', startTime: '2025-01-10T10:00:00Z'),
        _event(id: 2, title: 'Event 1', startTime: '2025-01-15T09:00:00Z'),
        _event(id: 3, title: 'Event 2', startTime: '2025-01-15T14:00:00Z'),
      ]),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(
          const MaterialApp(home: AdminEventsPage(societyId: 1)));
      await tester.pumpAndSettle();

      expect(find.text('1 events'), findsOneWidget);
      expect(find.text('2 events'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  // ── 4. Tapping a date that has events shows the events dialog ─────────────
  testWidgets('tapping date with events shows events dialog',
      (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockEventsHttpOverrides(
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

    try {
      await tester.pumpWidget(
          const MaterialApp(home: AdminEventsPage(societyId: 1)));
      await tester.pumpAndSettle();

      // Call onDateTapped directly on the state (avoids needing to tap the
      // calendar widget which is a third-party package)
      final state =
          tester.state(find.byType(AdminEventsPage)) as dynamic;
      state.onDateTapped(DateTime(2025, 1, 15));
      await tester.pumpAndSettle();

      expect(find.text('Events (1)'), findsOneWidget);
      expect(find.text('Test Event'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  // ── 5. Tapping a date with no events shows create dialog ──────────────────
  testWidgets('tapping date without events shows create dialog',
      (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global =
        _MockEventsHttpOverrides(body: _eventsBody([]), statusCode: 200);

    try {
      await tester.pumpWidget(
          const MaterialApp(home: AdminEventsPage(societyId: 1)));
      await tester.pumpAndSettle();

      final state =
          tester.state(find.byType(AdminEventsPage)) as dynamic;
      state.onDateTapped(DateTime(2025, 2, 20));
      await tester.pumpAndSettle();

      expect(find.text('Create Event'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  // ── 6. getDateOnly() strips time component ────────────────────────────────
  // NOTE: the production method is getDateOnly(), NOT normalize().
  // normalize() does not exist in AdminEventsPage — this test was rewritten
  // to call the correct method name from the source code.
  testWidgets('getDateOnly() correctly strips time from DateTime',
      (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global =
        _MockEventsHttpOverrides(body: _eventsBody([]), statusCode: 200);

    try {
      await tester.pumpWidget(
          const MaterialApp(home: AdminEventsPage(societyId: 1)));
      await tester.pumpAndSettle();

      final state =
          tester.state(find.byType(AdminEventsPage)) as dynamic;

      // getDateOnly() converts to local first, then strips time
      final dt = DateTime(2025, 1, 15, 14, 30, 45);
      final result = state.getDateOnly(dt) as DateTime;

      // Should equal the date-only version of the local representation
      final expected = DateTime(dt.toLocal().year, dt.toLocal().month, dt.toLocal().day);
      expect(result, equals(expected));
      expect(result.hour, equals(0));
      expect(result.minute, equals(0));
      expect(result.second, equals(0));
    } finally {
      HttpOverrides.global = previous;
    }
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock infrastructure  (same pattern as admin_analytics_test.dart)
// ─────────────────────────────────────────────────────────────────────────────

class _MockEventsHttpOverrides extends HttpOverrides {
  final List<int> body;
  final int statusCode;
  _MockEventsHttpOverrides({required this.body, required this.statusCode});

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _MockEventsHttpClient(body, statusCode);
}

class _MockEventsHttpClient implements HttpClient {
  final List<int> _body;
  final int _statusCode;
  _MockEventsHttpClient(this._body, this._statusCode);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _MockEventsHttpClientRequest(_body, _statusCode);

  // ← THIS LINE IS THE FIX — must be explicitly overridden
  @override
  void close({bool force = false}) {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockEventsHttpClientRequest implements HttpClientRequest {
  final List<int> _body;
  final int _statusCode;

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  _MockEventsHttpClientRequest(this._body, this._statusCode);

  @override
  void add(List<int> data) {}

  @override
  Future<HttpClientResponse> close() async =>
      _MockEventsHttpClientResponse(_statusCode, _body);

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockEventsHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  final int _statusCode;
  final List<int> _body;
  _MockEventsHttpClientResponse(this._statusCode, this._body);

  @override
  int get statusCode => _statusCode;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final c = StreamController<List<int>>();
    Timer.run(() {
      c.add(_body);
      c.close();
    });
    return c.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}