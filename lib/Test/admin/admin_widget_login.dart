import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/login_screen.admin.dart';
import 'package:unisoc/services/api_services.dart';

void main() {
  setUp(() {
    ApiService.authToken = null;
    ApiService.societyId = null;
    ApiService.societyName = null;
  });

  Widget wrap(Widget child) => MaterialApp(home: child);

  group('Society Profile Page UI Tests', () {

    testWidgets('AppBar displays Admin Login title | Admin Login text is shown in AppBar', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreenAdmin()));
      expect(find.text('Admin Login'), findsOneWidget);
    });

    testWidgets('Login heading displayed | Login text is shown on screen', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreenAdmin()));
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Email field displayed | Email input field is visible', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreenAdmin()));
      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    });

    testWidgets('Password field displayed | Password input field is visible', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreenAdmin()));
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    });

    testWidgets('Login button displayed | Login button is visible', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreenAdmin()));
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('Signup button displayed | Signup button is visible', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreenAdmin()));
      expect(find.widgetWithText(ElevatedButton, 'Signup'), findsOneWidget);
    });

    testWidgets('Forgot password link displayed | Forgot Password text is visible', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreenAdmin()));
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('Email input accepts text | User can type email into field', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreenAdmin()));
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'admin@port.ac.uk');
      expect(find.text('admin@port.ac.uk'), findsOneWidget);
    });

    testWidgets('Password input accepts text | Password field accepts input and is obscured', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreenAdmin()));
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'AdminPass1!');
      final field = tester.widget<TextField>(find.widgetWithText(TextField, 'Password'));
      expect(field.obscureText, isTrue);
    });

    testWidgets('Email keyboard type correct | Email field uses email keyboard', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreenAdmin()));
      final field = tester.widget<TextField>(find.widgetWithText(TextField, 'Email'));
      expect(field.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('Loading indicator shown initially | CircularProgressIndicator visible while loading societies', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreenAdmin()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('No societies message shown | "No societies found" displayed when API fails', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreenAdmin()));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(find.text('No societies found'), findsOneWidget);
    });

    testWidgets('Empty login shows snackbar | Snackbar appears when login pressed with empty fields', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreenAdmin()));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Invalid email shows snackbar | Snackbar appears for invalid email format', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreenAdmin()));
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'invalidemail');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'AdminPass1!');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('No society selected shows snackbar | Snackbar appears when society not selected', (tester) async {
      await tester.pumpWidget(wrap(const LoginScreenAdmin()));
      await tester.enterText(find.widgetWithText(TextField, 'Email'), 'admin@port.ac.uk');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'AdminPass1!');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}