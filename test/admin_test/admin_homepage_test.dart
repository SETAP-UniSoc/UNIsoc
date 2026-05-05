import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/admin/admin_hompage.dart';

void main() {
  tearDown(() {
    HttpOverrides.global = null;
  });

  testWidgets('renders header and sections when APIs return empty lists', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockHttpOverrides(
      societiesBody: utf8.encode('[]'),
      eventsBody: utf8.encode('[]'),
      searchBody: utf8.encode('[]'),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(const MaterialApp(home: AdminHomepage()));
      // allow post-frame loadData to run
      await tester.pumpAndSettle();

      expect(find.text('UniSoc'), findsOneWidget);
      expect(find.text('Top Societies'), findsOneWidget);
      expect(find.text('Browse Societies'), findsOneWidget);
      expect(find.text('Upcoming Events'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('loads societies and events from API and shows items', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    final societiesJson = jsonEncode([
      {"id": 1, "name": "TestSoc", "category": "Academic", "member_count": 10}
    ]);
    final eventsJson = jsonEncode([
      {
        "title": "Event1",
        "start_time": "2025-01-01T10:00:00Z",
        "location": "Hall",
        "society_id": 1,
        "capacity_limit": 50
      }
    ]);

    HttpOverrides.global = _MockHttpOverrides(
      societiesBody: utf8.encode(societiesJson),
      eventsBody: utf8.encode(eventsJson),
      searchBody: utf8.encode('[]'),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(const MaterialApp(home: AdminHomepage()));
      await tester.pumpAndSettle();

      expect(find.text('TestSoc'), findsWidgets); // may appear in multiple places
      expect(find.text('Event1'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('typing in search shows dropdown results (debounced)', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    final searchJson = jsonEncode([
      {"id": 2, "name": "FoundSoc", "type": "society"}
    ]);

    // Return empty lists for initial loads, but provide search result for search endpoint.
    HttpOverrides.global = _MockHttpOverrides(
      societiesBody: utf8.encode('[]'),
      eventsBody: utf8.encode('[]'),
      searchBody: utf8.encode(searchJson),
      statusCode: 200,
    );

    try {
      await tester.pumpWidget(const MaterialApp(home: AdminHomepage()));
      await tester.pumpAndSettle();

      // Enter text into the search TextField (first TextField in widget)
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Found');
      // advance past debounce (300ms) and allow async GET to finish
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('FoundSoc'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });
}

/// Minimal HttpOverrides / HttpClient mocks to intercept package:http requests
class _MockHttpOverrides extends HttpOverrides {
  final List<int> societiesBody;
  final List<int> eventsBody;
  final List<int> searchBody;
  final int statusCode;

  _MockHttpOverrides({
    required this.societiesBody,
    required this.eventsBody,
    required this.searchBody,
    required this.statusCode,
  });

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(societiesBody, eventsBody, searchBody, statusCode);
  }
}

class _MockHttpClient implements HttpClient {
  final List<int> societiesBody;
  final List<int> eventsBody;
  final List<int> searchBody;
  final int statusCode;

  _MockHttpClient(this.societiesBody, this.eventsBody, this.searchBody, this.statusCode);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _MockHttpClientRequest(method, url, societiesBody, eventsBody, searchBody, statusCode);
  }

  // other members unused
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final String method;
  final Uri url;
  final List<int> societiesBody;
  final List<int> eventsBody;
  final List<int> searchBody;
  final int statusCode;

  final HttpHeaders headers = _MockHttpHeaders();
  final _controller = StreamController<List<int>>();

  _MockHttpClientRequest(this.method, this.url, this.societiesBody, this.eventsBody, this.searchBody, this.statusCode);

  @override
  void add(List<int> data) {
    _controller.add(data);
  }

  @override
  Future<HttpClientResponse> close() async {
    // Choose body based on URL
    final uriStr = url.toString();
    List<int> body = utf8.encode('[]');
    if (uriStr.contains('/societies/')) {
      body = societiesBody;
    } else if (uriStr.contains('/events/all/')) {
      body = eventsBody;
    } else if (uriStr.contains('/search')) {
      body = searchBody;
    }
    return _MockHttpClientResponse(statusCode, body);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  final int _statusCode;
  final List<int> _body;

  _MockHttpClientResponse(this._statusCode, this._body);

  @override
  int get statusCode => _statusCode;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    final controller = StreamController<List<int>>();
    Timer.run(() {
      controller.add(_body);
      controller.close();
    });
    return controller.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
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