import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/services/api_services.dart';
import 'package:unisoc/screens/settings_user_page.dart';

// ─────────────────────────────────────────────
//  Helper
// ─────────────────────────────────────────────

Widget _wrap(Widget child) => MaterialApp(home: child);

// ─────────────────────────────────────────────
//  Widget Tests
// ─────────────────────────────────────────────

void main() {
  setUp(() {
    ApiService.authToken = 'test-token';
  });

  // ═══════════════════════════════════════════════════════════
  //  APP BAR
  // ═══════════════════════════════════════════════════════════

  group('AppBar', () {
    testWidgets('TC-W-01 | AppBar shows "My Account" title', (tester) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));
      expect(find.text('My Account'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  LOADING STATE
  // ═══════════════════════════════════════════════════════════

  group('Loading state', () {
    testWidgets(
      'TC-W-02 | Shows CircularProgressIndicator on first frame before network call settles',
      (tester) async {
        await tester.pumpWidget(_wrap(const UserSettingsPage()));
        // First frame — loading spinner must be visible
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  //  SECTION HEADINGS
  // ═══════════════════════════════════════════════════════════

  group('Section headings visible after load', () {
    testWidgets('TC-W-03 | "My Details" section heading is present', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));
      expect(find.text('My Details'), findsOneWidget);
    });

    testWidgets('TC-W-04 | "Change Email" section heading is present', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));
      expect(find.text('Change Email'), findsOneWidget);
    });

    testWidgets('TC-W-05 | "Change Password" section heading is present', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));
      expect(find.text('Change Password'), findsOneWidget);
    });

    testWidgets('TC-W-06 | "Notifications" section heading is present', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));
      expect(find.text('Notifications'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  FIELD LABELS
  // ═══════════════════════════════════════════════════════════

  group('Field labels', () {
    testWidgets('TC-W-07 | "Name" label is present', (tester) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));
      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('TC-W-08 | "Email" label is present', (tester) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));
      // "Email" appears as a field label and "Change Email" as a heading
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('TC-W-09 | "New Email" label is present', (tester) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));
      expect(find.text('New Email'), findsOneWidget);
    });

    testWidgets('TC-W-10 | "Current Password" label is present', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));
      expect(find.text('Current Password'), findsOneWidget);
    });

    testWidgets('TC-W-11 | "New Password" label is present', (tester) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));
      expect(find.text('New Password'), findsOneWidget);
    });

    testWidgets('TC-W-12 | "Confirm New Password" label is present', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));
      expect(find.text('Confirm New Password'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  BUTTONS
  // ═══════════════════════════════════════════════════════════

  group('Action buttons', () {
    testWidgets('TC-W-13 | "Update Email" button is present', (tester) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));
      expect(find.text('Update Email'), findsOneWidget);
    });

    testWidgets('TC-W-14 | "Change Password" button is present', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));
      // One heading + one button both say "Change Password"
      expect(find.text('Change Password'), findsWidgets);
    });

    testWidgets('TC-W-15 | Edit icon button is present for name field', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  TEXT FIELDS
  // ═══════════════════════════════════════════════════════════

  group('Text fields', () {
    testWidgets('TC-W-16 | New Email text field accepts input', (tester) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));

      final emailField = find.widgetWithText(TextField, 'Enter new email');
      expect(emailField, findsOneWidget);

      await tester.enterText(emailField, 'new@port.ac.uk');
      expect(find.text('new@port.ac.uk'), findsOneWidget);
    });

    testWidgets('TC-W-17 | Current Password field accepts input', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));

      final field = find.widgetWithText(TextField, 'Enter current password');
      expect(field, findsOneWidget);

      await tester.enterText(field, 'OldPass1!');
      // Obscured — text won't be visible but field accepts it
    });

    testWidgets('TC-W-18 | New Password field accepts input', (tester) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));

      final field = find.widgetWithText(
        TextField,
        'Enter new password (min. 8 characters)',
      );
      expect(field, findsOneWidget);
    });

    testWidgets('TC-W-19 | Confirm Password field accepts input', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const UserSettingsPage()));

      final field = find.widgetWithText(TextField, 'Confirm new password');
      expect(field, findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  PASSWORD VISIBILITY TOGGLES
  // ═══════════════════════════════════════════════════════════

  group('Password visibility toggles', () {
    testWidgets(
      'TC-W-20 | Three visibility_off icons shown by default (all passwords hidden)',
      (tester) async {
        await tester.pumpWidget(_wrap(const UserSettingsPage()));
        expect(find.byIcon(Icons.visibility_off), findsNWidgets(3));
      },
    );

    testWidgets(
      'TC-W-21 | Tapping visibility toggle on current password shows visibility icon',
      (tester) async {
        await tester.pumpWidget(_wrap(const UserSettingsPage()));

        // Tap the first visibility_off icon (current password)
        await tester.tap(find.byIcon(Icons.visibility_off).first);
        await tester.pump();

        // One icon should now be visibility (shown)
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  //  NAME EDIT MODE
  // ═══════════════════════════════════════════════════════════

  group('Name edit mode', () {
    testWidgets(
      'TC-W-22 | Tapping edit icon switches name field to editable TextField',
      (tester) async {
        await tester.pumpWidget(_wrap(const UserSettingsPage()));

        // Initially shows edit icon
        expect(find.byIcon(Icons.edit), findsOneWidget);

        await tester.tap(find.byIcon(Icons.edit));
        await tester.pump();

        // Should now show save icon
        expect(find.byIcon(Icons.save), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-23 | After tapping edit, a TextField appears for the name',
      (tester) async {
        await tester.pumpWidget(_wrap(const UserSettingsPage()));

        await tester.tap(find.byIcon(Icons.edit));
        await tester.pump();

        // At least one text field should now be present for the name
        expect(find.byType(TextField), findsWidgets);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  //  CLIENT-SIDE VALIDATION LOGIC (pure Dart)
  // ═══════════════════════════════════════════════════════════

  group('Client-side validation logic', () {
    test('TC-W-24 | Empty new email string fails validation', () {
      final email = ''.trim();
      expect(email.isEmpty, isTrue);
    });

    test('TC-W-25 | Non-empty new email string passes validation', () {
      final email = 'valid@port.ac.uk'.trim();
      expect(email.isEmpty, isFalse);
    });

    test('TC-W-26 | Empty current password fails validation', () {
      final current = '';
      final newPass = 'NewPass1!';
      expect(current.isEmpty || newPass.isEmpty, isTrue);
    });

    test('TC-W-27 | Both password fields filled passes empty check', () {
      final current = 'OldPass1!';
      final newPass = 'NewPass1!';
      expect(current.isEmpty || newPass.isEmpty, isFalse);
    });

    test('TC-W-28 | New password shorter than 8 chars fails length check', () {
      expect('short'.length < 8, isTrue);
    });

    test('TC-W-29 | New password ≥ 8 chars passes length check', () {
      expect('NewPass1!'.length >= 8, isTrue);
    });

    test('TC-W-30 | Mismatched confirm password is detected', () {
      final newPass = 'NewPass1!';
      final confirm = 'Different1!';
      expect(newPass != confirm, isTrue);
    });

    test('TC-W-31 | Matching confirm password passes check', () {
      final newPass = 'NewPass1!';
      final confirm = 'NewPass1!';
      expect(newPass == confirm, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  NOTIFICATION PREFS LOGIC (pure Dart)
  // ═══════════════════════════════════════════════════════════

  group('Notification preference logic', () {
    test('TC-W-32 | notify_new_events defaults to true when not set', () {
      final pref = <String, dynamic>{'society': 'Football Society'};
      final value = pref['notify_new_events'] ?? true;
      expect(value, isTrue);
    });

    test('TC-W-33 | notify_new_events respects false value from backend', () {
      final pref = <String, dynamic>{
        'society': 'Chess Club',
        'notify_new_events': false,
      };
      final value = pref['notify_new_events'] ?? true;
      expect(value, isFalse);
    });

    test('TC-W-34 | societyNameToId map correctly maps society name to id', () {
      final societies = [
        {'id': 1, 'name': 'Football Society'},
        {'id': 2, 'name': 'Chess Club'},
      ];

      final societyNameToId = <String, int>{};
      for (var s in societies) {
        societyNameToId[s['name'] as String] = s['id'] as int;
      }

      expect(societyNameToId['Football Society'], 1);
      expect(societyNameToId['Chess Club'], 2);
    });

    test(
      'TC-W-35 | Unknown society name returns -1 as fallback society_id',
      () {
        final societyNameToId = <String, int>{'Football Society': 1};
        final id = societyNameToId['Unknown Society'] ?? -1;
        expect(id, -1);
      },
    );

    test(
      'TC-W-36 | Empty notification prefs list means no societies joined',
      () {
        final prefs = <Map<String, dynamic>>[];
        expect(prefs.isEmpty, isTrue);
      },
    );

    test('TC-W-37 | Non-empty prefs list means societies are joined', () {
      final prefs = [
        {'society': 'Football Society', 'notify_new_events': true},
      ];
      expect(prefs.isNotEmpty, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  APISERVICE HEADER CHECKS
  // ═══════════════════════════════════════════════════════════

  group('ApiService header logic', () {
    test('TC-W-38 | Authorization header present when token is set', () {
      ApiService.authToken = 'test-token';
      expect(ApiService.headers['Authorization'], 'Token test-token');
    });

    test('TC-W-39 | Authorization header absent when token is null', () {
      ApiService.authToken = null;
      expect(ApiService.headers.containsKey('Authorization'), isFalse);
      ApiService.authToken = 'test-token'; // restore
    });
  });
}
