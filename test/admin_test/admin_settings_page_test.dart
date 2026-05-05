import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/admin/admin_settings_page.dart';
// all fail
void main() {
  testWidgets('loads profile and shows name/email', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockHttpOverrides((uri, method, _) {
      if (uri.path.contains('/user/profile/')) {
        return _MockResponse(200, utf8.encode(jsonEncode({"name": "AdminName", "email": "admin@ex.com"})));
      }
      if (uri.path.contains('/notifications/')) {
        return _MockResponse(200, utf8.encode(jsonEncode([{"notify_new_events": true}])));
      }
      return _MockResponse(200, utf8.encode('[]'));
    });

    try {
      await tester.pumpWidget(const MaterialApp(home: AdminSettingsPage()));
      await tester.pumpAndSettle();

      expect(find.text('My Details'), findsOneWidget);
      expect(find.text('AdminName'), findsOneWidget);
      expect(find.text('admin@ex.com'), findsOneWidget);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('toggling notifications posts update and shows snackbar', (WidgetTester tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockHttpOverrides((uri, method, _) {
      if (uri.path.contains('/user/profile/')) {
        return _MockResponse(200, utf8.encode(jsonEncode({"name": "AdminName", "email": "a@b.com"})));
      }
      if (uri.path.contains('/notifications/') && method == 'GET') {
        return _MockResponse(200, utf8.encode(jsonEncode([{"notify_new_events": true}])));
      }
      if (uri.path.contains('/notifications/') && method == 'POST') {
        return _MockResponse(200, utf8.encode(jsonEncode({"ok": true})));
      }
      return _MockResponse(200, utf8.encode('[]'));
    });

    try {
      await tester.pumpWidget(const MaterialApp(home: AdminSettingsPage()));
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      expect((tester.widget<Switch>(switchFinder)).value, isTrue);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('Notifications disabled'), findsOneWidget);
      expect((tester.widget<Switch>(switchFinder)).value, isFalse);
    } finally {
      HttpOverrides.global = previous;
    }
  });

  testWidgets('change password validates minimum length and shows snackbar', (WidgetTester tester) async {
    // simple overrides returning empty profile so UI loads
    final previous = HttpOverrides.current;
    HttpOverrides.global = _MockHttpOverrides((uri, method, _) {
      if (uri.path.contains('/user/profile/')) {
        return _MockResponse(200, utf8.encode(jsonEncode({"name": "AdminName", "email": "a@b.com"})));
      }
      return _MockResponse(200, utf8.encode('[]'));
    });

    await tester.pumpWidget(const MaterialApp(home: AdminSettingsPage()));
    await tester.pumpAndSettle();

    // Enter short new password (<8)
    final currentPassField = find.byType(TextField).at(2); // current password field
    final newPassField = find.byType(TextField).at(3); // new password field
    final confirmPassField = find.byType(TextField).at(4); // confirm password field

    await tester.enterText(currentPassField, 'currentpass');
    await tester.enterText(newPassField, 'short');
    await tester.enterText(confirmPassField, 'short');

    await tester.tap(find.text('Change Password'));
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    HttpOverrides.global = previous;
  });
}

/// Simple HttpOverrides / HttpClient mocks to intercept package:http calls.
/// The factory callback receives (uri, method, bodyBytes) and returns a _MockResponse.
class _MockHttpOverrides extends HttpOverrides {
  final _ResponseFactory factory;
  _MockHttpOverrides(this.factory);
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient(factory);
}
typedef _ResponseFactory = _MockResponse Function(Uri uri, String method, List<int>? body);

class _MockHttpClient implements HttpClient {
  final _ResponseFactory factory;
  _MockHttpClient(this.factory);
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpClientRequest(factory, url, method);
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final _ResponseFactory factory;
  final Uri url;
  final String method;
  final HttpHeaders headers = _MockHttpHeaders();
  final List<int> _body = [];
  _MockHttpClientRequest(this.factory, this.url, this.method);
  @override
  void add(List<int> data) => _body.addAll(data);
  @override
  Future<HttpClientResponse> close() async {
    return factory(url, method, _body);
  }
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockResponse implements HttpClientResponse {
  final int statusCode;
  final List<int> body;
  _MockResponse(this.statusCode, this.body);
  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    final controller = StreamController<List<int>>();
    Timer.run(() {
      controller.add(body);
      controller.close();
    });
    return controller.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
  @override noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _map = {};
  @override void add(String name, Object value, {bool preserveHeaderCase = false}) => _map.putIfAbsent(name, () => []).add(value.toString());
  @override void set(String name, Object value, {bool preserveHeaderCase = false}) => _map[name] = [value.toString()];
  @override noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}