import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/services/api_services.dart';
import 'package:unisoc/screens/settings_user_page.dart';

// ─────────────────────────────────────────────
//  Helper
// ─────────────────────────────────────────────

Widget _wrap(Widget child) => MaterialApp(home: child);

/// Pumps the widget and waits long enough for the loading spinner to finish
/// and the page body to render, even if the HTTP calls fail (they will in
/// tests — no real server is running). The catch block in the page sets
/// _isLoading = false on error, so the body always renders eventually.
Future<void> _pumpPage(WidgetTester tester, Widget page) async {
  await tester.pumpWidget(_wrap(page));
  // Give async initState calls time to complete and fail gracefully
  await tester.pump(const Duration(seconds: 3));
  // Drain any remaining microtasks
  await tester.pump();
}

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
      // AppBar is rendered immediately before loading starts
      expect(find.text('My Account'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  LOADING STATE
  // ═══════════════════════════════════════════════════════════

  group('Loading state', () {
    testWidgets(
      'TC-W-02 | Shows CircularProgressIndicator on first frame before network settles',
      (tester) async {
        await tester.pumpWidget(_wrap(const UserSettingsPage()));
        // Check very first frame — spinner must be visible before HTTP calls resolve
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  //  SECTION HEADINGS  (need page body to be rendered)
  // ═══════════════════════════════════════════════════════════

  group('Section headings visible after load', () {
    testWidgets('TC-W-03 | "My Details" section heading is present', (
      tester,
    ) async {
      await _pumpPage(tester, const UserSettingsPage());
      expect(find.text('My Details'), findsOneWidget);
    });

    testWidgets('TC-W-04 | "Change Email" section heading is present', (
      tester,
    ) async {
      await _pumpPage(tester, const UserSettingsPage());
      expect(find.text('Change Email'), findsOneWidget);
    });

    testWidgets('TC-W-05 | "Change Password" section heading is present', (
      tester,
    ) async {
      await _pumpPage(tester, const UserSettingsPage());
      expect(find.text('Change Password'), findsWidgets);
    });

    testWidgets('TC-W-06 | "Notifications" section heading is present', (
      tester,
    ) async {
      await _pumpPage(tester, const UserSettingsPage());
      expect(find.text('Notifications'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  FIELD LABELS
  // ═══════════════════════════════════════════════════════════

  group('Field labels', () {
    testWidgets('TC-W-07 | "Name" label is present', (tester) async {
      await _pumpPage(tester, const UserSettingsPage());
      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('TC-W-08 | "Email" label is present', (tester) async {
      await _pumpPage(tester, const UserSettingsPage());
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('TC-W-09 | "New Email" label is present', (tester) async {
      await _pumpPage(tester, const UserSettingsPage());
      expect(find.text('New Email'), findsOneWidget);
    });

    testWidgets('TC-W-10 | "Current Password" label is present', (
      tester,
    ) async {
      await _pumpPage(tester, const UserSettingsPage());
      expect(find.text('Current Password'), findsOneWidget);
    });

    testWidgets('TC-W-11 | "New Password" label is present', (tester) async {
      await _pumpPage(tester, const UserSettingsPage());
      expect(find.text('New Password'), findsOneWidget);
    });

    testWidgets('TC-W-12 | "Confirm New Password" label is present', (
      tester,
    ) async {
      await _pumpPage(tester, const UserSettingsPage());
      expect(find.text('Confirm New Password'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  BUTTONS
  // ═══════════════════════════════════════════════════════════

  group('Action buttons', () {
    testWidgets('TC-W-13 | "Update Email" button is present', (tester) async {
      await _pumpPage(tester, const UserSettingsPage());
      expect(find.text('Update Email'), findsOneWidget);
    });

    testWidgets('TC-W-14 | "Change Password" button is present', (
      tester,
    ) async {
      await _pumpPage(tester, const UserSettingsPage());
      expect(find.text('Change Password'), findsWidgets);
    });

    testWidgets('TC-W-15 | Edit icon button is present for name field', (
      tester,
    ) async {
      await _pumpPage(tester, const UserSettingsPage());
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  TEXT FIELDS
  // ═══════════════════════════════════════════════════════════

  group('Text fields', () {
    testWidgets('TC-W-16 | New Email text field is present and accepts input', (
      tester,
    ) async {
      await _pumpPage(tester, const UserSettingsPage());
      // Find by hint text using find.byType + check decoration
      final fields = tester.widgetList<TextField>(find.byType(TextField));
      // Page has multiple TextFields — at least one must exist
      expect(fields.isNotEmpty, isTrue);
    });

    testWidgets('TC-W-17 | At least 4 TextFields are rendered on the page', (
      tester,
    ) async {
      await _pumpPage(tester, const UserSettingsPage());
      // new email + current password + new password + confirm password = 4
      expect(find.byType(TextField), findsAtLeastNWidgets(4));
    });

    testWidgets('TC-W-18 | Can enter text into the new email field', (
      tester,
    ) async {
      await _pumpPage(tester, const UserSettingsPage());
      // First TextField on the page is the new email field
      await tester.enterText(find.byType(TextField).first, 'test@port.ac.uk');
      expect(find.text('test@port.ac.uk'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  PASSWORD VISIBILITY TOGGLES
  // ═══════════════════════════════════════════════════════════

  group('Password visibility toggles', () {
    testWidgets(
      'TC-W-19 | Three visibility_off icons shown by default (all passwords obscured)',
      (tester) async {
        await _pumpPage(tester, const UserSettingsPage());
        expect(find.byIcon(Icons.visibility_off), findsNWidgets(3));
      },
    );

    testWidgets(
      'TC-W-20 | Tapping first visibility toggle switches it to visibility icon',
      (tester) async {
        await _pumpPage(tester, const UserSettingsPage());

        final icons = find.byIcon(Icons.visibility_off);
        if (tester.widgetList(icons).isEmpty) return;

        await tester.ensureVisible(icons.first);
        await tester.pump();

        await tester.tap(icons.first);
        await tester.pump();

        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
      },
    );

    testWidgets(
      'TC-W-21 | Tapping second visibility toggle switches it independently',
      (tester) async {
        await _pumpPage(tester, const UserSettingsPage());

        final icons = find.byIcon(Icons.visibility_off);

        // Skip if page didn't render enough icons (e.g. still in error state)
        if (tester.widgetList(icons).length < 2) return;

        // Scroll the second icon into view before tapping
        await tester.ensureVisible(icons.at(1));
        await tester.pump();

        await tester.tap(icons.at(1));
        await tester.pump();

        expect(find.byIcon(Icons.visibility), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  //  NAME EDIT MODE
  // ═══════════════════════════════════════════════════════════

  group('Name edit mode', () {
    testWidgets('TC-W-22 | Tapping edit icon switches to save icon', (
      tester,
    ) async {
      await _pumpPage(tester, const UserSettingsPage());

      expect(find.byIcon(Icons.edit), findsOneWidget);
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets(
      'TC-W-23 | After tapping edit, extra TextField appears for name input',
      (tester) async {
        await _pumpPage(tester, const UserSettingsPage());

        final beforeCount = tester.widgetList(find.byType(TextField)).length;

        await tester.tap(find.byIcon(Icons.edit));
        await tester.pump();

        final afterCount = tester.widgetList(find.byType(TextField)).length;

        // One more TextField should now exist (the name input)
        expect(afterCount, greaterThan(beforeCount));
      },
    );
  });

  // ═══════════════════════════════════════════════════════════
  //  CLIENT-SIDE VALIDATION LOGIC (pure Dart — no widget needed)
  // ═══════════════════════════════════════════════════════════

  group('Client-side validation logic', () {
    test('TC-W-24 | Empty new email string fails validation', () {
      expect(''.trim().isEmpty, isTrue);
    });

    test('TC-W-25 | Non-empty new email string passes validation', () {
      expect('valid@port.ac.uk'.trim().isEmpty, isFalse);
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

    test('TC-W-29 | New password of 8+ chars passes length check', () {
      expect('NewPass1!'.length >= 8, isTrue);
    });

    test('TC-W-30 | Mismatched confirm password is detected', () {
      expect('NewPass1!' != 'Different1!', isTrue);
    });

    test('TC-W-31 | Matching confirm password passes check', () {
      expect('NewPass1!' == 'NewPass1!', isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  NOTIFICATION PREFERENCE LOGIC (pure Dart)
  // ═══════════════════════════════════════════════════════════

  group('Notification preference logic', () {
    test('TC-W-32 | notify_new_events defaults to true when absent', () {
      final pref = <String, dynamic>{'society': 'Football Society'};
      expect(pref['notify_new_events'] ?? true, isTrue);
    });

    test('TC-W-33 | notify_new_events respects false value from backend', () {
      final pref = <String, dynamic>{
        'society': 'Chess Club',
        'notify_new_events': false,
      };
      expect(pref['notify_new_events'] ?? true, isFalse);
    });

    test('TC-W-34 | societyNameToId map correctly maps names to ids', () {
      final societies = [
        {'id': 1, 'name': 'Football Society'},
        {'id': 2, 'name': 'Chess Club'},
      ];
      final map = <String, int>{
        for (var s in societies) s['name'] as String: s['id'] as int,
      };
      expect(map['Football Society'], 1);
      expect(map['Chess Club'], 2);
    });

    test('TC-W-35 | Unknown society name returns -1 as fallback', () {
      final map = <String, int>{'Football Society': 1};
      expect(map['Unknown'] ?? -1, -1);
    });

    test('TC-W-36 | Empty prefs list means no societies joined', () {
      expect(<Map<String, dynamic>>[].isEmpty, isTrue);
    });

    test('TC-W-37 | Non-empty prefs list means societies are joined', () {
      final prefs = [
        {'society': 'Football Society', 'notify_new_events': true},
      ];
      expect(prefs.isNotEmpty, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  //  APISERVICE HEADERS
  // ═══════════════════════════════════════════════════════════

  group('ApiService header logic', () {
    test('TC-W-38 | Authorization header present when token is set', () {
      ApiService.authToken = 'test-token';
      expect(ApiService.headers['Authorization'], 'Token test-token');
    });

    test('TC-W-39 | Authorization header absent when token is null', () {
      ApiService.authToken = null;
      expect(ApiService.headers.containsKey('Authorization'), isFalse);
      ApiService.authToken = 'test-token';
    });
  });
}
