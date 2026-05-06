import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unisoc/screens/admin/admin_settings_page.dart';

void main() {
  Widget buildApp(http.Client client) {
    return MaterialApp(home: AdminSettingsPage(httpClient: client));
  }

  testWidgets('loads profile and shows name/email', (WidgetTester tester) async {
    final client = _mockSettingsClient(
      profileJson: jsonEncode({"name": "AdminName", "email": "admin@ex.com"}),
      notificationsJson: jsonEncode([
        {"notify_new_events": true}
      ]),
    );

    await tester.pumpWidget(buildApp(client));
    await tester.pumpAndSettle();

    expect(find.text('My Details'), findsOneWidget);
    expect(find.text('AdminName'), findsOneWidget);
    expect(find.text('admin@ex.com'), findsOneWidget);
  });

  testWidgets('toggling notifications posts update and shows snackbar',
      (WidgetTester tester) async {
    final client = _mockSettingsClient(
      profileJson: jsonEncode({"name": "AdminName", "email": "a@b.com"}),
      notificationsJson: jsonEncode([
        {"notify_new_events": true}
      ]),
      postResponses: {
        'notifications': http.Response(jsonEncode({"ok": true}), 200),
      },
    );

    await tester.pumpWidget(buildApp(client));
    await tester.pumpAndSettle();

    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    expect(tester.widget<Switch>(switchFinder).value, isTrue);

    await tester.ensureVisible(switchFinder);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(find.text('Notifications disabled'), findsOneWidget);
    expect(tester.widget<Switch>(switchFinder).value, isFalse);
  });

  testWidgets('change password validates minimum length',
      (WidgetTester tester) async {
    final client = _mockSettingsClient(
      profileJson: jsonEncode({"name": "AdminName", "email": "a@b.com"}),
      notificationsJson: jsonEncode([
        {"notify_new_events": true}
      ]),
    );

    await tester.pumpWidget(buildApp(client));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(2), 'currentpass');
    await tester.enterText(find.byType(TextField).at(3), 'short');
    await tester.enterText(find.byType(TextField).at(4), 'short');

    final changePasswordButton = find.widgetWithText(ElevatedButton, 'Change Password');
    await tester.ensureVisible(changePasswordButton);
    await tester.tap(changePasswordButton);
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
  });

  testWidgets('update name shows success snackbar', (WidgetTester tester) async {
    final client = _mockSettingsClient(
      profileJson: jsonEncode({"name": "OldName", "email": "a@b.com"}),
      notificationsJson: jsonEncode([
        {"notify_new_events": true}
      ]),
      postResponses: {
        'profile': http.Response(jsonEncode({"name": "Marissa"}), 200),
      },
    );

    await tester.pumpWidget(buildApp(client));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Marissa');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(find.text('Name updated successfully'), findsOneWidget);
  });

  testWidgets('update name shows empty warning when blank',
      (WidgetTester tester) async {
    final client = _mockSettingsClient(
      profileJson: jsonEncode({"name": "AdminName", "email": "a@b.com"}),
      notificationsJson: jsonEncode([
        {"notify_new_events": true}
      ]),
    );

    await tester.pumpWidget(buildApp(client));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(find.text('Name cannot be empty'), findsOneWidget);
  });

  testWidgets('update email shows success snackbar', (WidgetTester tester) async {
    final client = _mockSettingsClient(
      profileJson: jsonEncode({"name": "AdminName", "email": "old@b.com"}),
      notificationsJson: jsonEncode([
        {"notify_new_events": true}
      ]),
      postResponses: {
        'change-email': http.Response(jsonEncode({"email": "marissa@gmail.com"}), 200),
      },
    );

    await tester.pumpWidget(buildApp(client));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'old@b.com');
    await tester.enterText(find.byType(TextField).at(1), 'marissa@gmail.com');

    final updateEmailBtn = find.widgetWithText(ElevatedButton, 'Update Email');
    await tester.ensureVisible(updateEmailBtn);
    await tester.tap(updateEmailBtn);
    await tester.pumpAndSettle();

    expect(find.text('Email updated successfully'), findsOneWidget);
  });

  testWidgets('update email shows missing fields warning',
      (WidgetTester tester) async {
    final client = _mockSettingsClient(
      profileJson: jsonEncode({"name": "AdminName", "email": "a@b.com"}),
      notificationsJson: jsonEncode([
        {"notify_new_events": true}
      ]),
    );

    await tester.pumpWidget(buildApp(client));
    await tester.pumpAndSettle();

    final updateEmailBtn = find.widgetWithText(ElevatedButton, 'Update Email');
    await tester.ensureVisible(updateEmailBtn);
    await tester.tap(updateEmailBtn);
    await tester.pumpAndSettle();

    expect(find.text('Please fill in both email fields'), findsOneWidget);
  });

  testWidgets('change password shows missing fields warning',
      (WidgetTester tester) async {
    final client = _mockSettingsClient(
      profileJson: jsonEncode({"name": "AdminName", "email": "a@b.com"}),
      notificationsJson: jsonEncode([
        {"notify_new_events": true}
      ]),
    );

    await tester.pumpWidget(buildApp(client));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(2), 'myCurrentPass1*');

    final changePwBtn = find.widgetWithText(ElevatedButton, 'Change Password');
    await tester.ensureVisible(changePwBtn);
    await tester.tap(changePwBtn);
    await tester.pumpAndSettle();

    expect(find.text('Please fill in both password fields'), findsOneWidget);
  });

  testWidgets('change password shows mismatch warning',
      (WidgetTester tester) async {
    final client = _mockSettingsClient(
      profileJson: jsonEncode({"name": "AdminName", "email": "a@b.com"}),
      notificationsJson: jsonEncode([
        {"notify_new_events": true}
      ]),
    );

    await tester.pumpWidget(buildApp(client));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(2), 'OldPass1*');
    await tester.enterText(find.byType(TextField).at(3), 'NewPass1*');
    await tester.enterText(find.byType(TextField).at(4), 'DifferentPass1*');

    final changePwBtn = find.widgetWithText(ElevatedButton, 'Change Password');
    await tester.ensureVisible(changePwBtn);
    await tester.tap(changePwBtn);
    await tester.pumpAndSettle();

    expect(find.text("New passwords don't match"), findsOneWidget);
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
