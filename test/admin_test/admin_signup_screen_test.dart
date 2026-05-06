import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unisoc/screens/admin_signup_screen.dart';

void main() {
  testWidgets('renders fields and Signup button', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminSignupScreen()));

    expect(find.text('Signup'), findsWidgets);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.widgetWithText(ElevatedButton, 'Signup'), findsOneWidget);
  });

  testWidgets('successful signup shows success SnackBar', (WidgetTester tester) async {
    final client = _mockSignupClient(statusCode: 200, body: '{"ok":true}');

    await tester.pumpWidget(MaterialApp(home: AdminSignupScreen(httpClient: client)));

    await tester.enterText(find.byType(TextField).at(0), 'adminuser');
    await tester.enterText(find.byType(TextField).at(1), 'a@b.com');
    await tester.enterText(find.byType(TextField).at(2), 'password');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Signup'));
    await tester.pumpAndSettle();

    expect(find.text('Signup successful!'), findsOneWidget);
  });

  testWidgets('failed signup shows error SnackBar with status code', (WidgetTester tester) async {
    final client = _mockSignupClient(statusCode: 400, body: 'bad');

    await tester.pumpWidget(MaterialApp(home: AdminSignupScreen(httpClient: client)));

    await tester.enterText(find.byType(TextField).at(0), 'adminuser');
    await tester.enterText(find.byType(TextField).at(1), 'a@b.com');
    await tester.enterText(find.byType(TextField).at(2), 'password');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Signup'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Signup failed: 400'), findsOneWidget);
  });
}

http.Client _mockSignupClient({required int statusCode, required String body}) {
  return MockClient((request) async {
    if (request.method == 'POST' && request.url.path.contains('/api/admin/signup')) {
      return http.Response(body, statusCode);
    }
    return http.Response('Not Found', 404);
  });
}
