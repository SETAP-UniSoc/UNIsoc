import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user_mysoc_page.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    home: child,
  );
}

void main() {
  group('MySocietyPage Widget Tests', () {

    // valid load
    testWidgets('Displays societies when data loads',
        (WidgetTester tester) async {

      await tester.pumpWidget(
        buildTestApp(
          MySocietyPage(
            mySocietiesFetcher: () async => [
              {
                "id": 1,
                "name": "Football",
                "description": "Sports club",
                "member_count": 10
              }
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Football'), findsOneWidget);
      expect(find.textContaining('Sports club'), findsOneWidget);
    });

    // loading state
    testWidgets('Shows loading indicator while fetching',
        (WidgetTester tester) async {

      await tester.pumpWidget(
        buildTestApp(
          MySocietyPage(
            mySocietiesFetcher: () async {
              await Future.delayed(const Duration(seconds: 1));
              return [];
            },
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // 🔵 ERROR STATE
    testWidgets('Displays error message on failure',
        (WidgetTester tester) async {

      await tester.pumpWidget(
        buildTestApp(
          MySocietyPage(
            mySocietiesFetcher: () async => throw Exception('Failed'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Error:'), findsOneWidget);
    });

    // 🔵 EMPTY STATE
    testWidgets('Displays empty message when no societies',
        (WidgetTester tester) async {

      await tester.pumpWidget(
        buildTestApp(
          MySocietyPage(
            mySocietiesFetcher: () async => [],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('You have not joined any societies yet.'),
        findsOneWidget,
      );
    });

    // 🔵 NAVIGATION
    testWidgets('Navigates to society page on tap',
        (WidgetTester tester) async {

      await tester.pumpWidget(
        buildTestApp(
          MySocietyPage(
            mySocietiesFetcher: () async => [
              {
                "id": 1,
                "name": "Football",
                "description": "Sports club",
                "member_count": 10
              }
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Football'));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

  });
}