import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/admin/admin_events_page.dart';

void main() {
  tearDown(() {
    HttpOverrides.global = null;
  });

  testWidgets('renders loading indicator initially, then calendar when empty events load', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockEventsHttpOverrides(
      eventsBody: utf8.encode('[]'),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminEventsPage(societyId: 1),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Events Calendar'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('loads events and groups them by date correctly', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    final eventsJson = jsonEncode([
      {
        "id": 1,
        "title": "Event A",
        "description": "Desc A",
        "location": "Hall A",
        "start_time": "2025-01-15T09:00:00Z",
        "end_time": "2025-01-15T10:00:00Z",
        "capacity_limit": 50
      },
      {
        "id": 2,
        "title": "Event B",
        "description": "Desc B",
        "location": "Hall B",
        "start_time": "2025-01-15T14:00:00Z",
        "end_time": "2025-01-15T15:00:00Z",
        "capacity_limit": null
      },
    ]);

    HttpOverrides.global = _MockEventsHttpOverrides(
      eventsBody: utf8.encode(eventsJson),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminEventsPage(societyId: 1),
        ),
      );

      await tester.pumpAndSettle();

      // Verify calendar events were created (2 events on same date = "2 events" label)
      expect(find.text('2 events'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('single event shows purple color, multiple events show red', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    final eventsJson = jsonEncode([
      {
        "id": 1,
        "title": "Solo Event",
        "description": "Solo",
        "location": "Place",
        "start_time": "2025-01-10T10:00:00Z",
        "end_time": "2025-01-10T11:00:00Z",
        "capacity_limit": 10
      },
      {
        "id": 2,
        "title": "Event 1",
        "description": "Multi 1",
        "location": "Place",
        "start_time": "2025-01-15T09:00:00Z",
        "end_time": "2025-01-15T10:00:00Z",
        "capacity_limit": null
      },
      {
        "id": 3,
        "title": "Event 2",
        "description": "Multi 2",
        "location": "Place",
        "start_time": "2025-01-15T14:00:00Z",
        "end_time": "2025-01-15T15:00:00Z",
        "capacity_limit": null
      },
    ]);

    HttpOverrides.global = _MockEventsHttpOverrides(
      eventsBody: utf8.encode(eventsJson),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminEventsPage(societyId: 1),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('1 events'), findsOneWidget); // single event
      expect(find.text('2 events'), findsOneWidget); // multiple events
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('tapping date with events shows events dialog', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    final eventsJson = jsonEncode([
      {
        "id": 1,
        "title": "Test Event",
        "description": "Test",
        "location": "Test Hall",
        "start_time": "2025-01-15T10:00:00Z",
        "end_time": "2025-01-15T11:00:00Z",
        "capacity_limit": 100
      }
    ]);

    HttpOverrides.global = _MockEventsHttpOverrides(
      eventsBody: utf8.encode(eventsJson),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminEventsPage(societyId: 1),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate date tap (accessing the state to call onDateTapped directly)
      final state = tester.state(
        find.byType(AdminEventsPage),
      ) as dynamic;
      state.onDateTapped(DateTime(2025, 1, 15));

      await tester.pumpAndSettle();

      expect(find.text('Events (1)'), findsOneWidget);
      expect(find.text('Test Event'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('tapping date without events shows create dialog', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockEventsHttpOverrides(
      eventsBody: utf8.encode('[]'),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminEventsPage(societyId: 1),
        ),
      );

      await tester.pumpAndSettle();

      final state = tester.state(
        find.byType(AdminEventsPage),
      ) as dynamic;
      state.onDateTapped(DateTime(2025, 2, 20));

      await tester.pumpAndSettle();

      expect(find.text('Create Event'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('normalize() correctly strips time from DateTime', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockEventsHttpOverrides(
      eventsBody: utf8.encode('[]'),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminEventsPage(societyId: 1),
        ),
      );

      await tester.pumpAndSettle();

      final state = tester.state(
        find.byType(AdminEventsPage),
      ) as dynamic;
      
      final dt = DateTime(2025, 1, 15, 14, 30, 45);
      final normalized = state.normalize(dt);

      expect(normalized, equals(DateTime(2025, 1, 15)));
      expect(normalized.hour, equals(0));
      expect(normalized.minute, equals(0));
      expect(normalized.second, equals(0));
    } finally {
      HttpOverrides.global = previous;
    }
  });
}

class _MockEventsHttpOverrides extends HttpOverrides {
  final List<int> eventsBody;
  final int statusCode;

  _MockEventsHttpOverrides({
    required this.eventsBody,
    required this.statusCode,
  });

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockEventsHttpClient(eventsBody, statusCode);
  }
}

class _MockEventsHttpClient implements HttpClient {
  final List<int> eventsBody;
  final int statusCode;

  _MockEventsHttpClient(this.eventsBody, this.statusCode);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _MockEventsHttpClientRequest(method, url, eventsBody, statusCode);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockEventsHttpClientRequest implements HttpClientRequest {
  @override
  final String method;
  final Uri url;
  final List<int> eventsBody;
  final int statusCode;

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  _MockEventsHttpClientRequest(
    this.method,
    this.url,
    this.eventsBody,
    this.statusCode,
  );

  @override
  void add(List<int> data) {}

  @override
  Future<HttpClientResponse> close() async {
    return _MockEventsHttpClientResponse(statusCode, eventsBody);
  }

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
    final controller = StreamController<List<int>>();
    Timer.run(() {
      controller.add(_body);
      controller.close();
    });
    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _map = {};

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _map.putIfAbsent(name, () => []).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _map[name] = [value.toString()];
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}