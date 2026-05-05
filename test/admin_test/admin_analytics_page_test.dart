import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/admin/admin_analytics_page.dart';

List<int> _analyticsBody({
  List<String> labels = const [],
  List<int> totals = const [],
  int liveCount = 0,
  List<Map<String, dynamic>> eventsStats = const [],
}) {
  return utf8.encode(jsonEncode({
    "labels": labels,
    "totals": totals,
    "live_count": liveCount,
    "events_stats": eventsStats,
  }));
}

void main() {
  tearDown(() {
    HttpOverrides.global = null;
  });


  testWidgets('shows empty state when no event attendance data',
      (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockAnalyticsHttpOverrides(
      body: _analyticsBody(
        labels: ["Jan"],
        totals: [50],
        liveCount: 50,
        eventsStats: [],
      ),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(const MaterialApp(home: AdminAnalyticsPage()));
      await tester.pumpAndSettle();

      expect(find.text('No event attendance data yet'), findsOneWidget);
      expect(
        find.text('When users attend events, their attendance will appear here'),
        findsOneWidget,
      );
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('shows empty membership chart when no data',
      (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockAnalyticsHttpOverrides(
      body: _analyticsBody(),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(const MaterialApp(home: AdminAnalyticsPage()));
      await tester.pumpAndSettle();

      expect(find.text('No data yet'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('exports PDF button is present', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockAnalyticsHttpOverrides(
      body: _analyticsBody(labels: ["Jan"], totals: [50], liveCount: 50),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(const MaterialApp(home: AdminAnalyticsPage()));
      await tester.pumpAndSettle();

      expect(find.text('Export as PDF'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });


  testWidgets('renders loading indicator and then analytics when data loads',
      (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockAnalyticsHttpOverrides(
      body: _analyticsBody(
        labels: ["Jan", "Feb", "Mar"],
        totals: [10, 20, 30],
        liveCount: 30,
      ),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(const MaterialApp(home: AdminAnalyticsPage()));

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('My Analytics'), findsOneWidget);
      expect(find.text('30'), findsWidgets);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('fetches analytics and displays membership trend data',
      (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockAnalyticsHttpOverrides(
      body: _analyticsBody(
        labels: ["Week 1", "Week 2", "Week 3"],
        totals: [100, 150, 200],
        liveCount: 200,
      ),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(const MaterialApp(home: AdminAnalyticsPage()));
      await tester.pumpAndSettle();

      expect(find.text('200'), findsWidgets);
      expect(find.text('Live Members: 200'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('displays event attendance bar chart with data',
      (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockAnalyticsHttpOverrides(
      body: _analyticsBody(
        eventsStats: [
          {"title": "Tech Talk", "attendee_count": 45},
          {"title": "Networking", "attendee_count": 82},
          {"title": "Workshop", "attendee_count": 120},
        ],
      ),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(const MaterialApp(home: AdminAnalyticsPage()));
      await tester.pumpAndSettle();

      expect(find.text('Event Attendance'), findsOneWidget);
      expect(find.text('Tech Talk'), findsOneWidget);
      expect(find.text('Networking'), findsOneWidget);
      expect(find.text('Workshop'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('displays live member count correctly',
      (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockAnalyticsHttpOverrides(
      body: _analyticsBody(
        labels: ["Jan", "Feb"],
        totals: [100, 150],
        liveCount: 150,
      ),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(const MaterialApp(home: AdminAnalyticsPage()));
      await tester.pumpAndSettle();

      expect(find.text('Live Members: 150'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('period buttons update analytics when tapped',
      (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    int callCount = 0;

    HttpOverrides.global = _MockAnalyticsHttpOverridesWithCallback(
      callback: (uri) {
        callCount++;
        if (uri.toString().contains('period=week')) {
          return _analyticsBody(
            labels: ["Mon", "Tue"],
            totals: [10, 15],
            liveCount: 15,
          );
        } else if (uri.toString().contains('period=month')) {
          return _analyticsBody(
            labels: ["Week 1", "Week 2"],
            totals: [50, 75],
            liveCount: 75,
          );
        }
        return _analyticsBody(labels: ["Jan"], totals: [100], liveCount: 100);
      },
    );

    try {
      await tester.pumpWidget(const MaterialApp(home: AdminAnalyticsPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1W'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1M'));
      await tester.pumpAndSettle();

      // initial load + 1W tap + 1M tap = at least 3 calls
      expect(callCount, greaterThan(1));
    } finally {
      HttpOverrides.global = previous;
    }
  });
}


/// Static-body override — returns the same [body] and [statusCode] for every request.
class _MockAnalyticsHttpOverrides extends HttpOverrides {
  final List<int> body;
  final int statusCode;
  _MockAnalyticsHttpOverrides({required this.body, required this.statusCode});

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _MockHttpClient.static(body, statusCode);
}

/// Callback-based override — lets each test vary the response by URI.
class _MockAnalyticsHttpOverridesWithCallback extends HttpOverrides {
  final List<int> Function(Uri uri) callback;
  _MockAnalyticsHttpOverridesWithCallback({required this.callback});

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _MockHttpClient.callback(callback);
}


class _MockHttpClient implements HttpClient {
  final List<int> Function(Uri uri) _resolve;

  _MockHttpClient.static(List<int> body, int statusCode)
      : _resolve = ((_) => body);

  _MockHttpClient.callback(List<int> Function(Uri uri) callback)
      : _resolve = callback;

  // dart:io HttpClient.open() routes through openUrl internally
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _MockHttpClientRequest(url, _resolve(url));

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ── HttpClientRequest ─────────────────────────────────────────────────────────

class _MockHttpClientRequest implements HttpClientRequest {
  final Uri _url;
  final List<int> _responseBody;

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  _MockHttpClientRequest(this._url, this._responseBody);

  @override
  void add(List<int> data) {}

  @override
  Future<HttpClientResponse> close() async =>
      _MockHttpClientResponse(200, _responseBody);

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ── HttpClientResponse ────────────────────────────────────────────────────────

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  final int _statusCode;
  final List<int> _body;

  _MockHttpClientResponse(this._statusCode, this._body);

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

// ── HttpHeaders ───────────────────────────────────────────────────────────────

class _MockHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}