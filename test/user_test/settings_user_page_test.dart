// dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user/settings_user_page.dart';

void main() {
  Widget buildTestableWidget() {
    return const MaterialApp(
      home: UserSettingsPage(),
    );
  }

  testWidgets('renders the settings controls', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('Current Password'), findsOneWidget);
    expect(find.text('New Password'), findsOneWidget);
    expect(find.text('Confirm New Password'), findsOneWidget);

    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('Save'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('tapping Save with empty new/confirm shows validation message', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a new password.'), findsOneWidget);
  });

  testWidgets('mismatched new and confirm passwords shows error', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());

    final newField = find.byType(TextField).at(1);
    final confirmField = find.byType(TextField).at(2);

    await tester.enterText(newField, 'password1');
    await tester.enterText(confirmField, 'password2');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match.'), findsOneWidget);
  });

  testWidgets('successful password change shows confirmation and clears fields', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());

    final currentFieldFinder = find.byType(TextField).at(0);
    final newFieldFinder = find.byType(TextField).at(1);
    final confirmFieldFinder = find.byType(TextField).at(2);

    await tester.enterText(currentFieldFinder, 'oldpass');
    await tester.enterText(newFieldFinder, 'newpass');
    await tester.enterText(confirmFieldFinder, 'newpass');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Password change requested.'), findsOneWidget);

    final currentFieldWidget = tester.widget<TextField>(currentFieldFinder);
    final newFieldWidget = tester.widget<TextField>(newFieldFinder);
    final confirmFieldWidget = tester.widget<TextField>(confirmFieldFinder);

    expect(currentFieldWidget.controller?.text, '');
    expect(newFieldWidget.controller?.text, '');
    expect(confirmFieldWidget.controller?.text, '');
  });
}