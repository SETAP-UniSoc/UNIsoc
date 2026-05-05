import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user_mysoc_page.dart';
//
class MockMySocHttpOverrides extends HttpOverrides {
  final int statusCode;
  final List<int> body;

  MockMySocHttpOverrides({required this.statusCode, required this.body});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient(statusCode: statusCode, body: body);
  }
}

class MockHttpClient implements HttpClient {
  final int statusCode;
  final List<int> body;

  MockHttpClient({required this.statusCode, required this.body});

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return MockHttpClientRequest(statusCode: statusCode, body: body);
  }

  // Unused methods stubbed
  @override noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHttpClientRequest implements HttpClientRequest {
  final int statusCode;
  final List<int> body;

  MockHttpClientRequest({required this.statusCode, required this.body});

  @override
  Future<HttpClientResponse> close() async {
    return MockHttpClientResponse(statusCode: statusCode, body: body);
  }

  @override noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHttpClientResponse implements HttpClientResponse {
  @override
  final int statusCode;
  final List<int> body;

  MockHttpClientResponse({required this.statusCode, required this.body});

  @override
  int get contentLength => body.length;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.fromIterable([body]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError ?? false,
    );
  }

  @override noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestNavigatorObserver extends NavigatorObserver {
  bool pushed = false;

  @override
  void didPush(Route route, Route? previousRoute) {
    pushed = true;
    super.didPush(route, previousRoute);
  }
}

void main() {
  group('MySocietyPage UI Tests', () {
    tearDown(() => HttpOverrides.global = null);

    testWidgets('shows loading indicator while fetching data', (tester) async { //pass
      await tester.pumpWidget(const MaterialApp(home: MySocietyPage()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays societies list after loading', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MySocietyPage()));
      await tester.pumpAndSettle();

      expect(find.text('My Societies'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows empty state when no societies joined', (tester) async {
      HttpOverrides.global = MockMySocHttpOverrides(
        statusCode: 200,
        body: utf8.encode('[]'),
      );

      await tester.pumpWidget(const MaterialApp(home: MySocietyPage()));
      await tester.pumpAndSettle();

      expect(find.text('You have not joined any societies yet.'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('shows error message on API failure', (tester) async {
      HttpOverrides.global = MockMySocHttpOverrides(
        statusCode: 500,
        body: utf8.encode('server error'),
      );

      await tester.pumpWidget(const MaterialApp(home: MySocietyPage()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error:'), findsOneWidget);
      expect(find.textContaining('server error'), findsOneWidget);
    });

    testWidgets('renders society tiles with name + member count', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MySocietyPage()));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsWidgets);
      expect(find.byType(CircleAvatar), findsWidgets);
      expect(find.byIcon(Icons.group), findsWidgets);
    });

    testWidgets('AppBar displays correct title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MySocietyPage()));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('My Societies'), findsOneWidget);
    });
  });

  group('MySocietyPage Data Handling Tests', () {
    tearDown(() => HttpOverrides.global = null);

testWidgets('member count displays singular and plural correctly', (WidgetTester tester) async {
  final previous = HttpOverrides.current;
  HttpOverrides.global = MockMySocHttpOverrides(
    statusCode: 200,
    body: utf8.encode(jsonEncode([
      {"id": 1, "name": "Solo Soc", "member_count": 1, "category": "Sport"},
      {"id": 2, "name": "Big Soc", "member_count": 42, "category": "Academic"},
    ])),
  );

  try {
    await tester.pumpWidget(const MaterialApp(home: MySocietyPage()));
    await tester.pumpAndSettle();

    expect(find.text('1 member'), findsOneWidget);
    expect(find.text('42 members'), findsOneWidget);
  } finally {
    HttpOverrides.global = previous;
  }
});

testWidgets('tapping society navigates to UserSocietyPage', (WidgetTester tester) async {
  final previous = HttpOverrides.current;
  HttpOverrides.global = MockMySocHttpOverrides(
    statusCode: 200,
    body: utf8.encode(jsonEncode([
      {"id": 1, "name": "Tech Society", "member_count": 5, "category": "Academic"}
    ])),
  );

  try {
    await tester.pumpWidget(MaterialApp(
      home: const MySocietyPage(),
      routes: {'/society': (context) => const Scaffold(body: Text('UserSocietyPage'))},
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    expect(find.text('UserSocietyPage'), findsOneWidget);
  } finally {
    HttpOverrides.global = previous;
  }

      final observer = TestNavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
          home: const MySocietyPage(),
          navigatorObservers: [observer],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      expect(observer.pushed, true);
    });
  });
}