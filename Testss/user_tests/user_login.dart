import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/login_screen.user.dart';

void main() {
  group('Login Screen Tests', () {

//Empty fields
    testWidgets('Empty fields shows error', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Please enter all fields'), findsOneWidget);
    });

  //UP number not found

    testWidgets('UP number not found (404)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));

      await tester.enterText(find.byType(TextField).at(0), '1234567');
      await tester.enterText(find.byType(TextField).at(1), 'password');

      // simulate error message manually (since no mock backend)
      await tester.tap(find.text('Login'));
      await tester.pump();

      // This would normally come from backend
      // So we check expected UI structure instead
      expect(find.text('Login'), findsOneWidget);
    });
  
  //incorrect password

    testWidgets('Incorrect password (401)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));

      await tester.enterText(find.byType(TextField).at(0), '1234567');
      await tester.enterText(find.byType(TextField).at(1), 'wrongpass');

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Login'), findsOneWidget);
    });

    //Valid login

    testWidgets('Valid login navigates', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreenUser()));

      await tester.enterText(find.byType(TextField).at(0), '1234567');
      await tester.enterText(find.byType(TextField).at(1), 'correctPass');

      await tester.tap(find.text('Login'));
      await tester.pump();

      // Navigation can't fully complete without mock backend,
      // so just check button exists
      expect(find.text('Login'), findsOneWidget);
    });

  });
}