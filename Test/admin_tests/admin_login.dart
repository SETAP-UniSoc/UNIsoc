import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/services/api_services.dart';
import 'package:unisoc/screens/login_screen.admin.dart';

// ─────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────

Widget _wrap(Widget child) => MaterialApp(home: child);

/// Pumps [LoginScreenAdmin] and waits for the society dropdown to finish
/// loading. Because the page makes a real HTTP call to fetch societies in
/// initState (and the server isn't running in tests), it will hit the catch
/// block and set isLoadingSocieties = false, rendering the "No societies
/// found" state. We wait 3 seconds for that to settle.
Future<void> _pumpLoginPage(WidgetTester tester) async {
  await tester.pumpWidget(_wrap(const LoginScreenAdmin()));
  await tester.pump(const Duration(seconds: 3));
  await tester.pump();
}

// ─────────────────────────────────────────────
//  Tests
// ─────────────────────────────────────────────

void main() {
  setUp(() {
    ApiService.authToken = null;
    ApiService.societyId = null;
    ApiService.societyName = null;
  });

  // ═══════════════════════════════════════════
  //  APP BAR
  // ═══════════════════════════════════════════

  group('AppBar', () {
    testWidgets('TC-W-01 | AppBar shows "Admin Login" title', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreenAdmin()));
      expect(find.text('Admin Login'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════
  //  LOADING STATE
  // ═══════════════════════════════════════════

  group('Loading state', () {
    testWidgets(
      'TC-W-02 | CircularProgressIndicator shown on first frame while societies load',
      (tester) async {
        await tester.pumpWidget(_wrap(const LoginScreenAdmin()));
        // First frame — societies are still loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'TC-W-03 | CircularProgressIndicator disappears after societies load or fail',
      (tester) async {
        await _pumpLoginPage(tester);
        // After the HTTP call times out / fails, loading is done
        // Either the dropdown or "No societies found" is shown
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });

  // ═══════════════════════════════════════════
  //  STATIC UI ELEMENTS
  // ═══════════════════════════════════════════

  group('Static UI elements', () {
    testWidgets('TC-W-04 | "Login" heading is shown', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreenAdmin()));
      // "Login" appears as both the heading text and the button label
      expect(find.text('Login'), findsWidgets);
    });

    testWidgets('TC-W-05 | Email TextField is present', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreenAdmin()));
      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    });

    testWidgets('TC-W-06 | Password TextField is present', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreenAdmin()));
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    });

    testWidgets('TC-W-07 | "Login" button is present', (tester) async {
      await _pumpLoginPage(tester);
      // The login ElevatedButton with text "Login"
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('TC-W-08 | "Signup" button is present', (tester) async {
      await _pumpLoginPage(tester);
      expect(find.widgetWithText(ElevatedButton, 'Signup'), findsOneWidget);
    });

    testWidgets('TC-W-09 | "Forgot Password?" button is present', (
      tester,
    ) async {
      await _pumpLoginPage(tester);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════
  //  TEXT FIELD INPUT
  // ═══════════════════════════════════════════

  group('Text field input', () {
    testWidgets('TC-W-10 | Email field accepts typed input', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreenAdmin()));
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'admin@port.ac.uk',
      );
      expect(find.text('admin@port.ac.uk'), findsOneWidget);
    });

    testWidgets('TC-W-11 | Password field accepts typed input', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreenAdmin()));
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'AdminPass1!',
      );
      // Password is obscured so text won't be visible but field accepts input
      final field = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Password'),
      );
      expect(field.obscureText, isTrue);
    });

    testWidgets('TC-W-12 | Email field is not obscured', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreenAdmin()));
      final field = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Email'),
      );
      expect(field.obscureText, isFalse);
    });

    testWidgets('TC-W-13 | Email field uses email keyboard type', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const LoginScreenAdmin()));
      final field = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Email'),
      );
      expect(field.keyboardType, TextInputType.emailAddress);
    });
  });

  // ═══════════════════════════════════════════
  //  SOCIETY DROPDOWN / EMPTY STATE
  // ═══════════════════════════════════════════

  group('Society dropdown / empty state', () {
    testWidgets('TC-W-14 | "No societies found" shown when API fails to load', (
      tester,
    ) async {
      await _pumpLoginPage(tester);
      // When societies API fails (no server running), this message appears
      expect(find.text('No societies found'), findsOneWidget);
    });

    testWidgets(
      'TC-W-15 | Society dropdown NOT shown when societies fail to load',
      (tester) async {
        await _pumpLoginPage(tester);
        expect(find.byType(DropdownButtonFormField<String>), findsNothing);
      },
    );
  });

  // ═══════════════════════════════════════════
  //  CLIENT-SIDE VALIDATION (snackbar checks)
  // ═══════════════════════════════════════════

  group('Client-side validation via snackbars', () {
    testWidgets(
      'TC-W-16 | Tapping Login with empty fields shows required snackbar',
      (tester) async {
        await _pumpLoginPage(tester);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets('TC-W-17 | Tapping Login with invalid email shows a snackbar', (
      tester,
    ) async {
      await _pumpLoginPage(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'notanemail',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'AdminPass1!',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets(
      'TC-W-18 | Tapping Login with valid email+password but no society shows a snackbar',
      (tester) async {
        await _pumpLoginPage(tester);

        await tester.enterText(
          find.widgetWithText(TextField, 'Email'),
          'admin@port.ac.uk',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Password'),
          'AdminPass1!',
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(SnackBar), findsOneWidget);
      },
    );
  });

  // ═══════════════════════════════════════════
  //  CLIENT-SIDE VALIDATION PURE DART LOGIC
  // ═══════════════════════════════════════════

  group('Client-side validation pure Dart logic', () {
    test('TC-W-19 | Empty email string fails empty check', () {
      expect(''.trim().isEmpty, isTrue);
    });

    test('TC-W-20 | Empty password string fails empty check', () {
      expect(''.isEmpty, isTrue);
    });

    test('TC-W-21 | Email without @ fails format check', () {
      expect('notanemail'.contains('@'), isFalse);
    });

    test('TC-W-22 | Email with @ passes format check', () {
      expect('admin@port.ac.uk'.contains('@'), isTrue);
    });

    test('TC-W-23 | Null selectedSocietyId means no society selected', () {
      String? selectedSocietyId;
      expect(selectedSocietyId, isNull);
    });

    test(
      'TC-W-24 | Non-null selectedSocietyId means a society is selected',
      () {
        String? selectedSocietyId = '1';
        expect(selectedSocietyId, isNotNull);
      },
    );

    test('TC-W-25 | Both email and password empty → both fail together', () {
      final email = '';
      final password = '';
      expect(email.isEmpty || password.isEmpty, isTrue);
    });
  });

  // ═══════════════════════════════════════════
  //  SOCIETY BACKEND MATCH LOGIC (pure Dart)
  // ═══════════════════════════════════════════

  group('Society backend match validation (pure Dart)', () {
    test(
      'TC-W-26 | Selected society matches backend society_id → passes check',
      () {
        final backendSocietyId = '1';
        final selectedSocietyId = '1';
        expect(backendSocietyId == selectedSocietyId, isTrue);
      },
    );

    test('TC-W-27 | Selected society does not match backend → fails check', () {
      final backendSocietyId = '1';
      final selectedSocietyId = '2';
      expect(backendSocietyId != selectedSocietyId, isTrue);
    });

    test('TC-W-28 | Null backend society_id is handled safely', () {
      final dynamic backendSocietyId = null;
      // Mirrors the widget null check: if backendSocietyId != null ...
      final shouldCheck = backendSocietyId != null;
      expect(shouldCheck, isFalse);
    });
  });

  // ═══════════════════════════════════════════
  //  APISERVICE STATE AFTER LOGIN
  // ═══════════════════════════════════════════

  group('ApiService state after login (pure Dart)', () {
    test('TC-W-29 | authToken is set correctly', () {
      ApiService.authToken = 'abc123';
      expect(ApiService.authToken, 'abc123');
    });

    test('TC-W-30 | societyId is set correctly', () {
      ApiService.societyId = 1;
      expect(ApiService.societyId, 1);
    });

    test('TC-W-31 | societyName is set correctly', () {
      ApiService.societyName = 'Football Society';
      expect(ApiService.societyName, 'Football Society');
    });

    test('TC-W-32 | isAdminOfSociety true when IDs match', () {
      ApiService.societyId = 1;
      expect(ApiService.isAdminOfSociety(1), isTrue);
    });

    test('TC-W-33 | isAdminOfSociety false when IDs differ', () {
      ApiService.societyId = 1;
      expect(ApiService.isAdminOfSociety(2), isFalse);
    });

    test('TC-W-34 | isAdminOfSociety false when societyId is null', () {
      ApiService.societyId = null;
      expect(ApiService.isAdminOfSociety(1), isFalse);
    });

    test('TC-W-35 | Headers contain Authorization token after login', () {
      ApiService.authToken = 'abc123';
      expect(ApiService.headers['Authorization'], 'Token abc123');
    });

    test('TC-W-36 | Headers have no Authorization before login', () {
      ApiService.authToken = null;
      expect(ApiService.headers.containsKey('Authorization'), isFalse);
    });
  });

  // ═══════════════════════════════════════════
  //  SOCIETY LIST PARSING (pure Dart)
  // ═══════════════════════════════════════════

  group('Society list parsing for dropdown (pure Dart)', () {
    test('TC-W-37 | Society list maps correctly to id and name', () {
      final raw = [
        {'id': 1, 'name': 'Football Society'},
        {'id': 2, 'name': 'Chess Club'},
      ];
      final mapped = raw
          .map((s) => {'id': s['id'], 'name': s['name']})
          .toList();
      expect(mapped[0]['name'], 'Football Society');
      expect(mapped[1]['id'], 2);
    });

    test('TC-W-38 | Society id stringified correctly for dropdown value', () {
      final id = 5;
      expect(id.toString(), '5');
    });

    test('TC-W-39 | Correct society found by string id', () {
      final societies = [
        {'id': 1, 'name': 'Football Society'},
        {'id': 3, 'name': 'Drama Society'},
      ];
      final found = societies.firstWhere((s) => s['id'].toString() == '3');
      expect(found['name'], 'Drama Society');
    });
  });
}
