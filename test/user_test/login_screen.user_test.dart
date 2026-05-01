import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user/login_screen.user.dart';

void main() {
  Widget buildTestableWidget() {
    return const MaterialApp(
      home: LoginScreenUser(),
    );
  }

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