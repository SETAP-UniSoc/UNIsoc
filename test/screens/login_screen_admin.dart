import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/main.dart';
import 'package:unisoc/screens/login_screen.admin.dart';

//testing admin login screen

//testing UI rendering of admin login screen
void main() {
  testWidgets('Admin Login Screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreenAdmin()));

    // Check for email and password fields
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('email'), findsOneWidget);
    expect(find.text('password'), findsOneWidget);

    // Check for login button
    expect(find.text('Login'), findsOneWidget);
  });
}

//testing if email field accepts input



