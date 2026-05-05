import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/admin/admin_analytics_page.dart';

void main() {
  tearDown(() {
    HttpOverrides.global = null;
  });

  testWidgets('renders loading indicator and then analytics when data loads', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockAnalyticsHttpOverrides(
      analyticsBody: utf8.encode(jsonEncode({
        "labels": ["Jan", "Feb", "Mar"],
        "totals": [10, 20, 30],
        "live_count": 30,
        "events_stats": []
      })),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(
        const MaterialApp(home: AdminAnalyticsPage()),
      );

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('My Analytics'), findsOneWidget);
      expect(find.text('30'), findsWidgets); // live count and last value
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('fetches analytics and displays membership trend data', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockAnalyticsHttpOverrides(
      analyticsBody: utf8.encode(jsonEncode({
        "labels": ["Week 1", "Week 2", "Week 3"],
        "totals": [100, 150, 200],
        "live_count": 200,
        "events_stats": []
      })),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(
        const MaterialApp(home: AdminAnalyticsPage()),
      );

      await tester.pumpAndSettle();

      expect(find.text('200'), findsWidgets);
      expect(find.text('Live Members: 200'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('displays event attendance bar chart with data', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockAnalyticsHttpOverrides(
      analyticsBody: utf8.encode(jsonEncode({
        "labels": [],
        "totals": [],
        "live_count": 0,
        "events_stats": [
          {"title": "Tech Talk", "attendee_count": 45},
          {"title": "Networking", "attendee_count": 82},
          {"title": "Workshop", "attendee_count": 120},
        ]
      })),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(
        const MaterialApp(home: AdminAnalyticsPage()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Event Attendance'), findsOneWidget);
      expect(find.text('Tech Talk'), findsOneWidget);
      expect(find.text('Networking'), findsOneWidget);
      expect(find.text('Workshop'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('shows empty state when no event attendance data', (WidgetTester tester) async { //pass
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockAnalyticsHttpOverrides(
      analyticsBody: utf8.encode(jsonEncode({
        "labels": ["Jan"],
        "totals": [50],
        "live_count": 50,
        "events_stats": []
      })),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(
        const MaterialApp(home: AdminAnalyticsPage()),
      );

      await tester.pumpAndSettle();

      expect(find.text('No event attendance data yet'), findsOneWidget);
      expect(find.text('When users attend events, their attendance will appear here'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('period buttons update analytics when tapped', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    
    // Create a mock that returns different data per period
    int callCount = 0;
    HttpOverrides.global = _MockAnalyticsHttpOverridesWithCallback(
      callback: (uri) {
        callCount++;
        if (uri.toString().contains('period=week')) {
          return utf8.encode(jsonEncode({
            "labels": ["Mon", "Tue"],
            "totals": [10, 15],
            "live_count": 15,
            "events_stats": []
          }));
        } else if (uri.toString().contains('period=month')) {
          return utf8.encode(jsonEncode({
            "labels": ["Week 1", "Week 2"],
            "totals": [50, 75],
            "live_count": 75,
            "events_stats": []
          }));
        }
        return utf8.encode(jsonEncode({
          "labels": ["Jan"],
          "totals": [100],
          "live_count": 100,
          "events_stats": []
        }));
      },
    );

    try {
      await tester.pumpWidget(
        const MaterialApp(home: AdminAnalyticsPage()),
      );

      await tester.pumpAndSettle();

      // Tap "1W" button
      await tester.tap(find.text('1W'));
      await tester.pumpAndSettle();

      // Tap "1M" button
      await tester.tap(find.text('1M'));
      await tester.pumpAndSettle();

      expect(callCount, greaterThan(1)); // at least 2 calls
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('displays live member count correctly', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockAnalyticsHttpOverrides(
      analyticsBody: utf8.encode(jsonEncode({
        "labels": ["Jan", "Feb"],
        "totals": [100, 150],
        "live_count": 150,
        "events_stats": []
      })),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(
        const MaterialApp(home: AdminAnalyticsPage()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Live Members: 150'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('shows empty membership chart when no data', (WidgetTester tester) async { //pass
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockAnalyticsHttpOverrides(
      analyticsBody: utf8.encode(jsonEncode({
        "labels": [],
        "totals": [],
        "live_count": 0,
        "events_stats": []
      })),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(
        const MaterialApp(home: AdminAnalyticsPage()),
      );

      await tester.pumpAndSettle();

      expect(find.text('No data yet'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('exports PDF button is present', (WidgetTester tester) async { //pass
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockAnalyticsHttpOverrides(
      analyticsBody: utf8.encode(jsonEncode({
        "labels": ["Jan"],
        "totals": [50],
        "live_count": 50,
        "events_stats": []
      })),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(
        const MaterialApp(home: AdminAnalyticsPage()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Export as PDF'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });
}

/// HttpOverrides mock for analytics with static response body
class _MockAnalyticsHttpOverrides extends HttpOverrides { 
  final List<int> analyticsBody;
  final int statusCode;

  _MockAnalyticsHttpOverrides({
    required this.analyticsBody,
    required this.statusCode,
  });

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockAnalyticsHttpClient(analyticsBody, statusCode);
  }
}

/// HttpOverrides mock for analytics with callback
class _MockAnalyticsHttpOverridesWithCallback extends HttpOverrides {
  final List<int> Function(Uri uri) callback;

  _MockAnalyticsHttpOverridesWithCallback({required this.callback});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockAnalyticsHttpClientWithCallback(callback);
  }
}

class _MockAnalyticsHttpClient implements HttpClient {
  final List<int> analyticsBody;
  final int statusCode;

  _MockAnalyticsHttpClient(this.analyticsBody, this.statusCode);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _MockAnalyticsHttpClientRequest(method, url, analyticsBody, statusCode);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockAnalyticsHttpClientWithCallback implements HttpClient {
  final List<int> Function(Uri uri) callback;

  _MockAnalyticsHttpClientWithCallback(this.callback);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _MockAnalyticsHttpClientRequestWithCallback(method, url, callback);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockAnalyticsHttpClientRequest implements HttpClientRequest {
  final String method;
  final Uri url;
  final List<int> analyticsBody;
  final int statusCode;

  final HttpHeaders headers = _MockHttpHeaders();

  _MockAnalyticsHttpClientRequest(
    this.method,
    this.url,
    this.analyticsBody,
    this.statusCode,
  );

  @override
  void add(List<int> data) {}

  @override
  Future<HttpClientResponse> close() async {
    return _MockAnalyticsHttpClientResponse(statusCode, analyticsBody);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockAnalyticsHttpClientRequestWithCallback implements HttpClientRequest {
  final String method;
  final Uri url;
  final List<int> Function(Uri uri) callback;

  final HttpHeaders headers = _MockHttpHeaders();

  _MockAnalyticsHttpClientRequestWithCallback(this.method, this.url, this.callback);

  @override
  void add(List<int> data) {}

  @override
  Future<HttpClientResponse> close() async {
    return _MockAnalyticsHttpClientResponse(200, callback(url));
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockAnalyticsHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  final int _statusCode;
  final List<int> _body;

  _MockAnalyticsHttpClientResponse(this._statusCode, this._body);

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