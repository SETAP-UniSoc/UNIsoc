import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/login_screen.admin.dart';

//testing admin login screen

//testing UI rendering of admin login screen
void main() {
  testWidgets('Admin Login Screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreenAdmin()));

    // Check for name, email and password fields
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('Society Name'), findsOneWidget);
    expect(find.text('email'), findsOneWidget);
    expect(find.text('password'), findsOneWidget);

    // Check for login button
    expect(find.text('Login'), findsOneWidget);
  });

//testing if email field accepts an input

  testWidgets('Admin Login Screen name input', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreenAdmin()));

    final nameField = find.byType(TextField).at(0);
    await tester.enterText(nameField, 'UniSoc');
    expect(find.text('UniSoc'), findsOneWidget);
  });

  testWidgets('Admin Login Screen email input', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreenAdmin()));

    final emailField = find.byType(TextField).at(1);
    await tester.enterText(emailField, 'admin@example.com');
    expect(find.text('admin@example.com'), findsOneWidget);
  });

//testing if password field accepts an input
  testWidgets('Admin Login Screen password input', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreenAdmin()));

    final passwordField = find.byType(TextField).last;
    await tester.enterText(passwordField, 'password123');
    expect(find.text('password123'), findsOneWidget);
  });  

//testing incorrect login credentials empty fields
  testWidgets('Admin Login Screen empty credentials', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreenAdmin()));

    final loginButton = find.text('Login');
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Please enter all fields'), findsOneWidget);
  });
}
