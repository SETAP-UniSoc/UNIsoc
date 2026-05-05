import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user/my_account_page.dart';
import 'package:unisoc/user_profile_state.dart';

void main() {
  Widget buildTestableWidget() {
    return const MaterialApp(
      home: MyAccountPage(),
    );
  }

  testWidgets('empty first name field shows error on save', (WidgetTester tester) async {
  await tester.pumpWidget(buildTestableWidget());

  final firstNameField = find.byType(TextField).first;
  await tester.enterText(firstNameField, '');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();

  expect(find.textContaining('name'), findsOneWidget);
});

testWidgets('invalid email format shows error on save', (WidgetTester tester) async {
  await tester.pumpWidget(buildTestableWidget());

  // Email is the 3rd TextField (index 2)
  final emailField = find.byType(TextField).at(2);
  await tester.enterText(emailField, 'notanemail');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();

  expect(find.textContaining('email'), findsOneWidget);
});

  setUp(() {
    UserProfileState.firstName.value = 'John';
  });

  testWidgets('renders my account page fields', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('My Account'), findsOneWidget);
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Last Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Current Password'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);

    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('first name field is initialized from user profile state',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('John'), findsOneWidget);

    final firstNameField = find.byType(TextField).first;
    await tester.enterText(firstNameField, 'Jane');
    await tester.pump();

    expect(find.text('Jane'), findsOneWidget);
  });

testWidgets('change password button navigates to settings page',
    (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: const MyAccountPage(),
    routes: {'/settings': (context) => const Scaffold(body: Text('UserSettingsPage'))},
  ));

  await tester.tap(find.text('Change Password'));
  await tester.pumpAndSettle();

  expect(find.text('UserSettingsPage'), findsOneWidget);
});

  testWidgets('current password field is obscured', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());

    final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
    final currentPasswordField = fields.last;

    expect(currentPasswordField.obscureText, isTrue);
  });
}