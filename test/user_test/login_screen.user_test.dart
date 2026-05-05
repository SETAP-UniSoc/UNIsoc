import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user/login_screen.user.dart';

class _MockLoginHttpOverrides extends HttpOverrides {
  final int statusCode;
  final List<int> responseBody;

  _MockLoginHttpOverrides(this.statusCode, this.responseBody);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(statusCode, responseBody);
  }
}

class _MockHttpClient implements HttpClient {
  final int statusCode;
  final List<int> responseBody;

  _MockHttpClient(this.statusCode, this.responseBody);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _MockHttpClientRequest(statusCode, responseBody);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final int statusCode;
  final List<int> responseBody;

  _MockHttpClientRequest(this.statusCode, this.responseBody);

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse(statusCode, responseBody);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  final int statusCode;
  final List<int> responseBody;

  _MockHttpClientResponse(this.statusCode, this.responseBody);

  @override
  int get contentLength => responseBody.length;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {bool? cancelOnError, void Function()? onDone, Function? onError}) {
    return Stream.value(responseBody).listen(onData,
        cancelOnError: cancelOnError, onDone: onDone, onError: onError);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget buildTestableWidget() {
    return const MaterialApp(
      home: LoginScreenUser(),
    );
  }

testWidgets('invalid credentials shows error message', (WidgetTester tester) async {
  final previous = HttpOverrides.current;
  HttpOverrides.global = _MockLoginHttpOverrides(401, utf8.encode('{"error":"invalid upnumber or password"}'));

  try {
    await tester.pumpWidget(buildTestableWidget());

    await tester.enterText(find.byType(TextField).first, '1234567');
    await tester.enterText(find.byType(TextField).last, 'wrongpass');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.textContaining('invalid'), findsOneWidget);
  } finally {
    HttpOverrides.global = previous;
  }
});

  testWidgets('renders the login screen controls', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Signup'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsNWidgets(3));
    expect(find.byType(TextButton), findsOneWidget);
  });

  testWidgets('UP number field allows only 7 digits', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestableWidget());

    final upField = find.byType(TextField).first;
    await tester.enterText(upField, '1234567890');
    await tester.pump();

    expect(find.text('1234567'), findsOneWidget);
    expect(find.text('1234567890'), findsNothing);
  });

  testWidgets('tapping Login with empty fields shows validation message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestableWidget());

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Please enter all fields'), findsOneWidget);
  });
}