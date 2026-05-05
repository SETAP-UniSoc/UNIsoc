import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unisoc/screens/admin/admin_settings_page.dart';

void main() {
  testWidgets('loads profile and shows name/email', (WidgetTester tester) async {
    final client = _mockSettingsClient(
      profileJson: jsonEncode({"name": "AdminName", "email": "admin@ex.com"}),
      notificationsJson: jsonEncode([{"notify_new_events": true}]),
    );

    await tester.pumpWidget(MaterialApp(home: AdminSettingsPage(httpClient: client)));
    await tester.pumpAndSettle();

    expect(find.text('My Details'), findsOneWidget);
    expect(find.text('AdminName'), findsOneWidget);
    expect(find.text('admin@ex.com'), findsOneWidget);
  });

  testWidgets('toggling notifications posts update and shows snackbar', (WidgetTester tester) async {
    final client = _mockSettingsClient(
      profileJson: jsonEncode({"name": "AdminName", "email": "a@b.com"}),
      notificationsJson: jsonEncode([{"notify_new_events": true}]),
      postResponses: {
        'notifications': http.Response(jsonEncode({"ok": true}), 200),
      },
    );

    await tester.pumpWidget(MaterialApp(home: AdminSettingsPage(httpClient: client)));
    await tester.pumpAndSettle();

    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    expect((tester.widget<Switch>(switchFinder)).value, isTrue);

    await tester.ensureVisible(switchFinder);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(find.text('Notifications disabled'), findsOneWidget);
    expect((tester.widget<Switch>(switchFinder)).value, isFalse);
  });

  testWidgets('change password validates minimum length and shows snackbar', (WidgetTester tester) async {
    final client = _mockSettingsClient(
      profileJson: jsonEncode({"name": "AdminName", "email": "a@b.com"}),
      notificationsJson: jsonEncode([{"notify_new_events": true}]),
    );

    await tester.pumpWidget(MaterialApp(home: AdminSettingsPage(httpClient: client)));
    await tester.pumpAndSettle();

    final currentPassField = find.byType(TextField).at(2);
    final newPassField = find.byType(TextField).at(3);
    final confirmPassField = find.byType(TextField).at(4);

    await tester.enterText(currentPassField, 'currentpass');
    await tester.enterText(newPassField, 'short');
    await tester.enterText(confirmPassField, 'short');

    final changePasswordButton = find.widgetWithText(ElevatedButton, 'Change Password');
    await tester.ensureVisible(changePasswordButton);
    await tester.tap(changePasswordButton);
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
  });
}

http.Client _mockSettingsClient({
  required String profileJson,
  required String notificationsJson,
  Map<String, http.Response> postResponses = const {},
}) {
  return MockClient((request) async {
    final path = request.url.path;
    final method = request.method;

    if (path.contains('/user/profile/') && method == 'GET') {
      return http.Response(profileJson, 200);
    }

    if (path.contains('/notifications/') && method == 'GET') {
      return http.Response(notificationsJson, 200);
    }

    if (path.contains('/notifications/') && method == 'POST') {
      return postResponses['notifications'] ?? http.Response('{}', 200);
    }

    if (path.contains('/user/profile/') && method == 'POST') {
      return postResponses['profile'] ?? http.Response(profileJson, 200);
    }

    if (path.contains('/change-email/') && method == 'POST') {
      return postResponses['change-email'] ?? http.Response('{}', 200);
    }

    if (path.contains('/change-password/') && method == 'POST') {
      return postResponses['change-password'] ?? http.Response('{}', 200);
    }

    return http.Response('Not Found', 404);
  });
}