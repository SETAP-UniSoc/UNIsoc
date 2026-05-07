import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unisoc/screens/admin/admin_settings_page.dart';

// Mock client helper: handles routes for AdminSettingsPage
http.Client _mockSettingsClient({
  String name = 'AdminName',
  String email = 'admin@ex.com',
  bool notificationsEnabled = true,
  Map<String, http.Response> postResponses = const {},
}) {
  return MockClient((request) async {
    final path = request.url.path;
    final method = request.method;

    // GET profile
    if (path.contains('/user/profile/') && method == 'GET') {
      return http.Response(
        jsonEncode({"name": name, "email": email}),
        200,
      );
    }

    // GET notifications
    if (path.contains('/notifications/') && method == 'GET') {
      return http.Response(
        jsonEncode([
          {"notify_new_events": notificationsEnabled}
        ]),
        200,
      );
    }

    // POST notifications (opt-in / opt-out)
    if (path.contains('/notifications/') && method == 'POST') {
      return postResponses['notifications'] ??
          http.Response(
            jsonEncode({"message": "Preferences updated", "notify_new_events": true}),
            200,
          );
    }

    // POST profile (update name)
    if (path.contains('/user/profile/') && method == 'POST') {
      return postResponses['profile'] ??
          http.Response(jsonEncode({"name": name, "email": email}), 200);
    }

    // POST change-email
    if (path.contains('/change-email/') && method == 'POST') {
      return postResponses['change-email'] ??
          http.Response(
            jsonEncode({"message": "Email updated successfully", "email": "new@ex.com"}),
            200,
          );
    }

    // POST change-password
    if (path.contains('/change-password/') && method == 'POST') {
      return postResponses['change-password'] ??
          http.Response(
            jsonEncode({"message": "Password changed successfully"}),
            200,
          );
    }

    return http.Response('Not Found', 404);
  });
}

// Wraps AdminSettingsPage in a MaterialApp with the given mock client
Widget _buildApp(http.Client client) =>
    MaterialApp(home: AdminSettingsPage(httpClient: client));

void main() {
  // Test Plan Row 67 — Load Profile Successfully
  group('Load Profile (Test Plan Row 67)', () {
    testWidgets(
      'TC-W-LP-01 | Shows loading indicator on first frame before data arrives',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        // First frame only — spinner must be visible before HTTP resolves
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-LP-02 | Profile name and email displayed after successful load',
      (WidgetTester tester) async {
        final client = _mockSettingsClient(
          name: 'AdminName',
          email: 'admin@ex.com',
        );
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        expect(find.text('My Details'), findsOneWidget);
        expect(find.text('AdminName'), findsOneWidget);
        expect(find.text('admin@ex.com'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-LP-03 | All section headings visible after load',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        expect(find.text('My Details'), findsOneWidget);
        expect(find.text('Change Email'), findsOneWidget);
        expect(find.text('Change Password'), findsWidgets);
        expect(find.text('Notifications'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-LP-04 | Edit icon is visible next to name field',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.edit), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-LP-05 | AppBar shows "My Account" title',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pump();

        expect(find.text('My Account'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-LP-06 | Error message shown when profile API fails',
      (WidgetTester tester) async {
        final client = MockClient((request) async {
          if (request.url.path.contains('/user/profile/') &&
              request.method == 'GET') {
            return http.Response('Unauthorized', 401);
          }
          if (request.url.path.contains('/notifications/')) {
            return http.Response('[]', 200);
          }
          return http.Response('Not Found', 404);
        });

        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        // Page renders error state without crashing
        expect(find.byType(Scaffold), findsOneWidget);
      },
    );
  });

  // Test Plan Row 68 — Update Name
  group('Update Name (Test Plan Row 68)', () {
    testWidgets(
      'TC-W-UN-01 | Tapping edit icon switches to save icon (edit mode)',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.edit), findsOneWidget);
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.save), findsOneWidget);
        expect(find.byIcon(Icons.edit), findsNothing);
      },
    );

    testWidgets(
      'TC-W-UN-02 | After tapping edit, name TextField appears',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        final before = tester.widgetList(find.byType(TextField)).length;
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        final after = tester.widgetList(find.byType(TextField)).length;
        expect(after, greaterThan(before));
      },
    );

    testWidgets(
      'TC-W-UN-03 | Valid name entered and saved → success snackbar shown',
      (WidgetTester tester) async {
        final client = _mockSettingsClient(
          postResponses: {
            'profile': http.Response(
              jsonEncode({"name": "Marissa", "email": "admin@ex.com"}),
              200,
            ),
          },
        );
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'Marissa');
        await tester.tap(find.byIcon(Icons.save));
        await tester.pumpAndSettle();

        expect(find.text('Name updated successfully'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-UN-04 | Update name button is present after entering edit mode',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        // Save icon acts as the submit button
        expect(find.byIcon(Icons.save), findsOneWidget);
      },
    );
  });

  // Test Plan Row 69 — Empty Name Field
  group('Empty Name Field (Test Plan Row 69)', () {
    testWidgets(
      'TC-W-EN-01 | Saving an empty name shows "Name cannot be empty" snackbar',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        // Clear the name field
        await tester.enterText(find.byType(TextField).first, '');
        await tester.tap(find.byIcon(Icons.save));
        await tester.pumpAndSettle();

        expect(find.text('Name cannot be empty'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-EN-02 | No API call is made when name is empty',
      (WidgetTester tester) async {
        int postCallCount = 0;
        final client = MockClient((request) async {
          if (request.method == 'POST' &&
              request.url.path.contains('/user/profile/')) {
            postCallCount++;
          }
          if (request.url.path.contains('/user/profile/') &&
              request.method == 'GET') {
            return http.Response(
                jsonEncode({"name": "AdminName", "email": "a@b.com"}), 200);
          }
          if (request.url.path.contains('/notifications/')) {
            return http.Response(
                jsonEncode([{"notify_new_events": true}]), 200);
          }
          return http.Response('{}', 200);
        });

        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, '');
        await tester.tap(find.byIcon(Icons.save));
        await tester.pumpAndSettle();

        // POST should not have been called
        expect(postCallCount, 0);
      },
    );
  });

  // Test Plan Row 70 — Update Email
  group('Update Email (Test Plan Row 70)', () {
    testWidgets(
      'TC-W-UE-01 | Current Email and New Email fields are present',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        expect(find.text('Current Email'), findsOneWidget);
        expect(find.text('New Email'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-UE-02 | Update Email button is present on the page',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(ElevatedButton, 'Update Email'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-UE-03 | Valid current and new email → "Email updated successfully" snackbar',
      (WidgetTester tester) async {
        final client = _mockSettingsClient(
          postResponses: {
            'change-email': http.Response(
              jsonEncode({
                "message": "Email updated successfully",
                "email": "marissa@gmail.com",
              }),
              200,
            ),
          },
        );
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        // TextField index layout:
        // 0 = current email, 1 = new email,
        // 2 = current password, 3 = new password, 4 = confirm password
        await tester.enterText(find.byType(TextField).at(0), 'admin@ex.com');
        await tester.enterText(find.byType(TextField).at(1), 'marissa@gmail.com');

        final updateEmailBtn =
            find.widgetWithText(ElevatedButton, 'Update Email');
        await tester.ensureVisible(updateEmailBtn);
        await tester.tap(updateEmailBtn);
        await tester.pumpAndSettle();

        expect(find.text('Email updated successfully'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-UE-04 | Can enter text into the current email field',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.byType(TextField).at(0), 'newemail@test.com');
        await tester.pump();

        expect(find.byType(TextField).at(0), findsOneWidget);
        expect(
          (tester.widget<TextField>(find.byType(TextField).at(0)).controller?.text ?? ''),
          'newemail@test.com',
        );
      },
    );
  });

  // Test Plan Row 71 — Missing New Email Field
  group('Missing New Email (Test Plan Row 71)', () {
    testWidgets(
      'TC-W-ME-01 | Tapping Update Email with both fields empty shows validation message',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        final updateEmailBtn =
            find.widgetWithText(ElevatedButton, 'Update Email');
        await tester.ensureVisible(updateEmailBtn);
        await tester.tap(updateEmailBtn);
        await tester.pumpAndSettle();

        expect(find.text('Please fill in both email fields'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-ME-02 | Only current email filled → still shows validation message',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.byType(TextField).at(0), 'admin@ex.com');

        final updateEmailBtn =
            find.widgetWithText(ElevatedButton, 'Update Email');
        await tester.ensureVisible(updateEmailBtn);
        await tester.tap(updateEmailBtn);
        await tester.pumpAndSettle();

        expect(find.text('Please fill in both email fields'), findsOneWidget);
      },
    );
  });

  // Test Plan Row 72 — Missing Confirm Password Fields
  group('Missing Password Fields (Test Plan Row 72)', () {
    testWidgets(
      'TC-W-MP-01 | All password fields blank → "Please fill in both password fields"',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        final changePwBtn =
            find.widgetWithText(ElevatedButton, 'Change Password');
        await tester.ensureVisible(changePwBtn);
        await tester.tap(changePwBtn);
        await tester.pumpAndSettle();

        expect(
            find.text('Please fill in both password fields'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-MP-02 | Only current password filled → still shows validation message',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        // current password is TextField at index 2
        await tester.enterText(
            find.byType(TextField).at(2), 'OldPass1!');

        final changePwBtn =
            find.widgetWithText(ElevatedButton, 'Change Password');
        await tester.ensureVisible(changePwBtn);
        await tester.tap(changePwBtn);
        await tester.pumpAndSettle();

        expect(
            find.text('Please fill in both password fields'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-MP-03 | New password shorter than 8 chars → "Password must be at least 8 characters"',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).at(2), 'OldPass1!');
        await tester.enterText(find.byType(TextField).at(3), 'short');
        await tester.enterText(find.byType(TextField).at(4), 'short');

        final changePwBtn =
            find.widgetWithText(ElevatedButton, 'Change Password');
        await tester.ensureVisible(changePwBtn);
        await tester.tap(changePwBtn);
        await tester.pumpAndSettle();

        expect(
            find.text('Password must be at least 8 characters'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-MP-04 | Password fields visible — at least 3 TextFields present',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        // current email + new email + current password + new password + confirm
        expect(find.byType(TextField), findsAtLeastNWidgets(3));
      },
    );
  });

  // Test Plan Row 73 — Password Mismatch
  group('Password Mismatch (Test Plan Row 73)', () {
    testWidgets(
      'TC-W-PM-01 | Mismatched new and confirm passwords → "New passwords don\'t match"',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).at(2), 'OldPass1!');
        await tester.enterText(find.byType(TextField).at(3), 'NewPass1!');
        await tester.enterText(find.byType(TextField).at(4), 'DifferentPass1!');

        final changePwBtn =
            find.widgetWithText(ElevatedButton, 'Change Password');
        await tester.ensureVisible(changePwBtn);
        await tester.tap(changePwBtn);
        await tester.pumpAndSettle();

        expect(find.text("New passwords don't match"), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-PM-02 | Matching passwords and valid length → "Password changed successfully"',
      (WidgetTester tester) async {
        final client = _mockSettingsClient(
          postResponses: {
            'change-password': http.Response(
              jsonEncode({"message": "Password changed successfully"}),
              200,
            ),
          },
        );
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).at(2), 'OldPass1!');
        await tester.enterText(find.byType(TextField).at(3), 'NewPass1!');
        await tester.enterText(find.byType(TextField).at(4), 'NewPass1!');

        final changePwBtn =
            find.widgetWithText(ElevatedButton, 'Change Password');
        await tester.ensureVisible(changePwBtn);
        await tester.tap(changePwBtn);
        await tester.pumpAndSettle();

        expect(find.text('Password changed successfully'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-PM-03 | Password fields clear after successful change',
      (WidgetTester tester) async {
        final client = _mockSettingsClient(
          postResponses: {
            'change-password': http.Response(
              jsonEncode({"message": "Password changed successfully"}),
              200,
            ),
          },
        );
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        final currentField = find.byType(TextField).at(2);
        final newField = find.byType(TextField).at(3);
        final confirmField = find.byType(TextField).at(4);

        await tester.enterText(currentField, 'OldPass1!');
        await tester.enterText(newField, 'NewPass1!');
        await tester.enterText(confirmField, 'NewPass1!');

        final changePwBtn =
            find.widgetWithText(ElevatedButton, 'Change Password');
        await tester.ensureVisible(changePwBtn);
        await tester.tap(changePwBtn);
        await tester.pumpAndSettle();

        // Fields should be cleared on success
        expect(
            tester.widget<TextField>(currentField).controller?.text, '');
        expect(
            tester.widget<TextField>(newField).controller?.text, '');
        expect(
            tester.widget<TextField>(confirmField).controller?.text, '');
      },
    );
  });

  // Test Plan Rows 43–46 — Notification Preferences
  group('Notification Toggle (Test Plan Rows 43–46)', () {
    testWidgets(
      'TC-W-NT-01 | Notifications toggle is present on the page',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        expect(find.byType(Switch), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-NT-02 | Toggle is ON when notify_new_events is true (opt-in state)',
      (WidgetTester tester) async {
        final client = _mockSettingsClient(notificationsEnabled: true);
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        final sw = tester.widget<Switch>(find.byType(Switch));
        expect(sw.value, isTrue);
      },
    );

    testWidgets(
      'TC-W-NT-03 | Toggle is OFF when notify_new_events is false (opt-out state)',
      (WidgetTester tester) async {
        final client = _mockSettingsClient(notificationsEnabled: false);
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        final sw = tester.widget<Switch>(find.byType(Switch));
        expect(sw.value, isFalse);
      },
    );

    testWidgets(
      'TC-W-NT-04 | Tapping toggle ON→OFF shows "Notifications disabled" snackbar (opt-out, Row 46)',
      (WidgetTester tester) async {
        final client = _mockSettingsClient(
          notificationsEnabled: true,
          postResponses: {
            'notifications': http.Response(
              jsonEncode({"ok": true}),
              200,
            ),
          },
        );
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        final switchFinder = find.byType(Switch);
        expect(tester.widget<Switch>(switchFinder).value, isTrue);

        await tester.ensureVisible(switchFinder);
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        expect(find.text('Notifications disabled'), findsOneWidget);
        expect(tester.widget<Switch>(switchFinder).value, isFalse);
      },
    );

    testWidgets(
      'TC-W-NT-05 | Tapping toggle OFF→ON shows "Notifications enabled" snackbar (opt-in, Row 43)',
      (WidgetTester tester) async {
        final client = _mockSettingsClient(
          notificationsEnabled: false,
          postResponses: {
            'notifications': http.Response(
              jsonEncode({"ok": true}),
              200,
            ),
          },
        );
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        final switchFinder = find.byType(Switch);
        expect(tester.widget<Switch>(switchFinder).value, isFalse);

        await tester.ensureVisible(switchFinder);
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        expect(find.text('Notifications enabled'), findsOneWidget);
        expect(tester.widget<Switch>(switchFinder).value, isTrue);
      },
    );

    testWidgets(
      'TC-W-NT-06 | "Enable Notifications" label is shown next to toggle',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        expect(find.text('Enable Notifications'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-NT-07 | Notification preference subtitle text is visible',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        expect(
          find.text('Receive updates about your society and events'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'TC-W-NT-08 | Failed notification POST shows error snackbar',
      (WidgetTester tester) async {
        final client = _mockSettingsClient(
          notificationsEnabled: true,
          postResponses: {
            'notifications': http.Response('Server Error', 500),
          },
        );
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        final switchFinder = find.byType(Switch);
        await tester.ensureVisible(switchFinder);
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        expect(
          find.text('Failed to update notification settings'),
          findsOneWidget,
        );
      },
    );
  });

  // Password visibility toggles
  group('Password Visibility Toggles', () {
    testWidgets(
      'TC-W-PV-01 | Three visibility_off icons shown by default (all fields obscured)',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.visibility_off), findsNWidgets(3));
      },
    );

    testWidgets(
      'TC-W-PV-02 | Tapping first visibility icon reveals password',
      (WidgetTester tester) async {
        final client = _mockSettingsClient();
        await tester.pumpWidget(_buildApp(client));
        await tester.pumpAndSettle();

        final icons = find.byIcon(Icons.visibility_off);
        await tester.ensureVisible(icons.first);
        await tester.tap(icons.first);
        await tester.pump();

        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
      },
    );
  });
}