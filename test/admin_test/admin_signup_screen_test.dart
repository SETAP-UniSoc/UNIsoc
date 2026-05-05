import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/admin_signup_screen.dart';

void main() {
  tearDown(() {
    // ensure no leftover override between tests
    HttpOverrides.global = null;
  });

  testWidgets('renders fields and Signup button', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminSignupScreen()));

    expect(find.text('Signup'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('successful signup shows success SnackBar (mocked HttpClient)', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockHttpOverrides(200, utf8.encode('{"ok":true}'));

    try {
      await tester.pumpWidget(const MaterialApp(home: AdminSignupScreen()));

      await tester.enterText(find.byType(TextField).at(0), 'adminuser');
      await tester.enterText(find.byType(TextField).at(1), 'a@b.com');
      await tester.enterText(find.byType(TextField).at(2), 'password');

      await tester.tap(find.text('Signup'));
      await tester.pumpAndSettle();

      expect(find.text('Signup successful!'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('failed signup shows error SnackBar with status code (mocked HttpClient)', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockHttpOverrides(400, utf8.encode('bad'));

    try {
      await tester.pumpWidget(const MaterialApp(home: AdminSignupScreen()));

      await tester.enterText(find.byType(TextField).at(0), 'adminuser');
      await tester.enterText(find.byType(TextField).at(1), 'a@b.com');
      await tester.enterText(find.byType(TextField).at(2), 'password');

      await tester.tap(find.text('Signup'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Signup failed: 400'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });
}

/// Minimal HttpOverrides / HttpClient implementations to intercept package:http requests
class _MockHttpOverrides extends HttpOverrides {
  final int statusCode;
  final List<int> bodyBytes;

  _MockHttpOverrides(this.statusCode, this.bodyBytes);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(statusCode, bodyBytes);
  }
}

class _MockHttpClient implements HttpClient {
  final int statusCode;
  final List<int> body;

  _MockHttpClient(this.statusCode, this.body);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _MockHttpClientRequest(statusCode, body, method, url);
  }

  // unused members below — implement as no-op / throw if used
  @override noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final int statusCode;
  final List<int> body;
  @override
  final String method;
  final Uri url;
  @override
  final HttpHeaders headers = _MockHttpHeaders();
  final _controller = StreamController<List<int>>();

  _MockHttpClientRequest(this.statusCode, this.body, this.method, this.url);

  @override
  void add(List<int> data) {
    _controller.add(data);
  }

  @override
  Future<HttpClientResponse> close() async {
    // ignore request body and return preset response
    return _MockHttpClientResponse(statusCode, body);
  }

  // implement required members as no-op/defaults
  @override noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
    // push bytes then close
    Timer.run(() {
      controller.add(_body);
      controller.close();
    });
    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  // unused / defaulted members
  @override noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

  // minimal stubs for other members
  @override noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}