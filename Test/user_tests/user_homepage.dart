import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user/user_home_page.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: child,
      ),
    ),
  );
}

void main() {
  group('User Homepage Widget Tests', () {

    // VALID LOAD
    testWidgets(
      'Displays UniSoc header and welcome message when API loads successfully',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            HomePage(
              getSocieties: () async => [
                {
                  "id": 1,
                  "name": "Football Society",
                  "description": "Sports society",
                  "member_count": 10,
                  "category": "Sports"
                }
              ],
              getEventsForJoinedSocieties: () async => [
                {
                  "title": "Football Match",
                  "start_time": "2026-05-10",
                  "location": "Sports Hall",
                  "society_id": 1,
                  "society_name": "Football Society"
                }
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('UniSoc'), findsOneWidget);
        expect(find.textContaining('Welcome'), findsOneWidget);
      },
    );

    // LOADING STATE
    testWidgets(
      'Displays loading indicator while waiting for API response',
      (WidgetTester tester) async {
        final completer = Completer<List<dynamic>>();
        await tester.pumpWidget(
          buildTestApp(
            HomePage(
              getSocieties: () => completer.future,
              getEventsForJoinedSocieties: () async => [],
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsWidgets);
        completer.complete([]);
      },
    );

    // API FAILURE
    testWidgets(
      'Displays error message when API request fails',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            HomePage(
              getSocieties: () async => throw Exception('Server Error'),
              getEventsForJoinedSocieties: () async => [],
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('Error:'), findsOneWidget);
      },
    );

    // SEARCH BAR
    testWidgets(
      'Displays search bar on homepage',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            HomePage(
              getSocieties: () async => [],
              getEventsForJoinedSocieties: () async => [],
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Search events or societies'), findsOneWidget);
      },
    );

    // FEATURED SOCIETIES
    testWidgets(
      'Displays top 5 featured societies',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            HomePage(
              getSocieties: () async => [
                {"id": 1, "name": "Football", "description": "Sports", "member_count": 10, "category": "Sports"},
                {"id": 2, "name": "Chess", "description": "Academic", "member_count": 8, "category": "Academic"},
                {"id": 3, "name": "Drama", "description": "Arts", "member_count": 6, "category": "Cultural"},
                {"id": 4, "name": "Coding", "description": "Tech", "member_count": 5, "category": "Academic"},
                {"id": 5, "name": "Tennis", "description": "Sports", "member_count": 4, "category": "Sports"},
              ],
              getEventsForJoinedSocieties: () async => [],
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Featured Societies'), findsOneWidget);
        expect(find.byType(PageView), findsOneWidget);
      },
    );

    // SORTING A-Z
    testWidgets(
      'Sorts societies A-Z',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            HomePage(
              getSocieties: () async => [
                {"id": 1, "name": "Zebra Society", "description": "", "member_count": 5, "category": "Sports"},
                {"id": 2, "name": "Apple Society", "description": "", "member_count": 3, "category": "Academic"},
                {"id": 3, "name": "Mango Society", "description": "", "member_count": 7, "category": "Cultural"},
              ],
              getEventsForJoinedSocieties: () async => [],
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sort by'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('A-Z'));
        await tester.pumpAndSettle();

        final applePos = tester.getTopLeft(find.text('Apple Society')).dy;
        final mangoPos = tester.getTopLeft(find.text('Mango Society')).dy;
        final zebraPos = tester.getTopLeft(find.text('Zebra Society')).dy;

        expect(applePos < mangoPos, true);
        expect(mangoPos < zebraPos, true);
      },
    );

    // SORTING Z-A
    testWidgets(
      'Sorts societies Z-A',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            HomePage(
              getSocieties: () async => [
                {"id": 1, "name": "Zebra Society", "description": "", "member_count": 5, "category": "Sports"},
                {"id": 2, "name": "Apple Society", "description": "", "member_count": 3, "category": "Academic"},
                {"id": 3, "name": "Mango Society", "description": "", "member_count": 7, "category": "Cultural"},
              ],
              getEventsForJoinedSocieties: () async => [],
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sort by'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Z-A'));
        await tester.pumpAndSettle();

        final applePos = tester.getTopLeft(find.text('Apple Society')).dy;
        final mangoPos = tester.getTopLeft(find.text('Mango Society')).dy;
        final zebraPos = tester.getTopLeft(find.text('Zebra Society')).dy;

        expect(zebraPos < mangoPos, true);
        expect(mangoPos < applePos, true);
      },
    );

    // SORTING MOST MEMBERS
    testWidgets(
      'Sorts societies by most members',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            HomePage(
              getSocieties: () async => [
                {"id": 1, "name": "Small Society", "description": "", "member_count": 2, "category": "Sports"},
                {"id": 2, "name": "Big Society", "description": "", "member_count": 100, "category": "Academic"},
                {"id": 3, "name": "Mid Society", "description": "", "member_count": 50, "category": "Cultural"},
              ],
              getEventsForJoinedSocieties: () async => [],
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sort by'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Most Members'));
        await tester.pumpAndSettle();

        final bigPos = tester.getTopLeft(find.text('Big Society')).dy;
        final midPos = tester.getTopLeft(find.text('Mid Society')).dy;
        final smallPos = tester.getTopLeft(find.text('Small Society')).dy;

        expect(bigPos < midPos, true);
        expect(midPos < smallPos, true);
      },
    );

    // SORTING LEAST MEMBERS
    testWidgets(
      'Sorts societies by least members',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            HomePage(
              getSocieties: () async => [
                {"id": 1, "name": "Small Society", "description": "", "member_count": 2, "category": "Sports"},
                {"id": 2, "name": "Big Society", "description": "", "member_count": 100, "category": "Academic"},
                {"id": 3, "name": "Mid Society", "description": "", "member_count": 50, "category": "Cultural"},
              ],
              getEventsForJoinedSocieties: () async => [],
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sort by'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Least Members'));
        await tester.pumpAndSettle();

        final bigPos = tester.getTopLeft(find.text('Big Society')).dy;
        final midPos = tester.getTopLeft(find.text('Mid Society')).dy;
        final smallPos = tester.getTopLeft(find.text('Small Society')).dy;

        expect(smallPos < midPos, true);
        expect(midPos < bigPos, true);
      },
    );

    // FILTERING BY CATEGORY
    testWidgets(
      'Filters societies by Sports category',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            HomePage(
              getSocieties: () async => [
                {"id": 1, "name": "Football Society", "description": "", "member_count": 10, "category": "Sports"},
                {"id": 2, "name": "Chess Society", "description": "", "member_count": 5, "category": "Academic"},
                {"id": 3, "name": "Tennis Society", "description": "", "member_count": 8, "category": "Sports"},
              ],
              getEventsForJoinedSocieties: () async => [],
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Filter by'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sports'));
        await tester.pumpAndSettle();

        expect(find.text('Football Society'), findsOneWidget);
        expect(find.text('Tennis Society'), findsOneWidget);
        expect(find.text('Chess Society'), findsNothing);
      },
    );

  });
}