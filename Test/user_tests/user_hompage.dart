import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user/user_home_page.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: child),
    ),
  );
}

void main() {
  group('User Homepage Widget Tests (Partition Based)', () {

    // valid load
    testWidgets('HomeHeader displays UI when data loads successfully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          HomeHeader(
            getSocieties: () async => [
              {"name": "Football"}
            ],
            getEventsForJoinedSocieties: () async => [
              {"title": "Match"}
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('UniSoc'), findsOneWidget);
    });

    // loading
    testWidgets('HomeHeader shows CircularProgressIndicator during loading',
        (WidgetTester tester) async {
      final completer = Completer<List<dynamic>>();

      await tester.pumpWidget(
        buildTestApp(
          HomeHeader(
            getSocieties: () => completer.future,
            getEventsForJoinedSocieties: () async => [],
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // api error
    testWidgets('HomeHeader shows error text when API fails',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          HomeHeader(
            getSocieties: () async => throw Exception('Error'),
            getEventsForJoinedSocieties: () async => [],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Error:'), findsOneWidget);
    });

    // search bar valid input
    testWidgets('Search bar accepts valid query input',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const HomePage()));

      await tester.enterText(find.byType(TextField), 'Football');
      await tester.pump();

      expect(find.text('Football'), findsOneWidget);
    });

    // featured societies display
    testWidgets('Featured societies section is displayed',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const HomePage()));

      expect(find.text('Featured Societies'), findsOneWidget);
    });

    // sorting A-Z
    testWidgets('Sort dropdown exists for A-Z sorting',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const HomePage()));

      expect(find.text('Sort by'), findsOneWidget);
    });

    // filtering by category
    testWidgets('Filter dropdown exists for category filtering',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const HomePage()));

      expect(find.text('Filter by'), findsOneWidget);
    });

    // events section display
    testWidgets('Events section is displayed',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const HomePage()));

      expect(find.text('Upcoming Events'), findsOneWidget);
    });

    // welcome header default
    testWidgets('Displays default welcome message when no name provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const HomePage()));

      expect(find.text('Welcome Student'), findsOneWidget);
    });

  });
}