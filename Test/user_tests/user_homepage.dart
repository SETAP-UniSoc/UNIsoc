import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user/user_home_page.dart';

void main() {
  group('User Homepage Widget Tests - Success State', () {
    
    final mockSocieties = [
      {
        "id": 1,
        "name": "Football Society",
        "category": "Sports",
        "description": "Football club",
        "member_count": 10
      },
      {
        "id": 2,
        "name": "Chess Club",
        "category": "Academic",
        "description": "Chess club",
        "member_count": 5
      },
      {
        "id": 3,
        "name": "Music Society",
        "category": "Cultural",
        "description": "Music club",
        "member_count": 8
      },
    ];
    
    final mockEvents = [
      {
        "id": 1,
        "title": "Football Match",
        "start_time": DateTime.now().add(Duration(days: 1)).toIso8601String(),
        "location": "Stadium",
        "society_id": 1,
        "society_name": "Football Society"
      },
    ];

    Future<List<dynamic>> mockGetSocieties() async => mockSocieties;
    Future<List<dynamic>> mockGetEvents() async => mockEvents;

    testWidgets('HomePage renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockGetSocieties,
            getEventsForJoinedSocieties: mockGetEvents,
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('UniSoc title is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockGetSocieties,
            getEventsForJoinedSocieties: mockGetEvents,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('UniSoc'), findsOneWidget);
    });

    testWidgets('Search bar exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockGetSocieties,
            getEventsForJoinedSocieties: mockGetEvents,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Search bar accepts text input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockGetSocieties,
            getEventsForJoinedSocieties: mockGetEvents,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.enterText(find.byType(TextField), 'Football');
      await tester.pump();
      expect(find.text('Football'), findsOneWidget);
    });

    testWidgets('Featured Societies section is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockGetSocieties,
            getEventsForJoinedSocieties: mockGetEvents,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Featured Societies'), findsOneWidget);
    });

    testWidgets('All Societies (A-Z) section is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockGetSocieties,
            getEventsForJoinedSocieties: mockGetEvents,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('All Societies (A-Z)'), findsOneWidget);
    });

    testWidgets('Sort by dropdown exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockGetSocieties,
            getEventsForJoinedSocieties: mockGetEvents,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Sort by'), findsOneWidget);
    });

    testWidgets('Filter by dropdown exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockGetSocieties,
            getEventsForJoinedSocieties: mockGetEvents,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Filter by'), findsOneWidget);
    });

    testWidgets('Upcoming Events section is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockGetSocieties,
            getEventsForJoinedSocieties: mockGetEvents,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Upcoming Events'), findsOneWidget);
    });

    // Updated: Check that at least one event title appears
    testWidgets('Upcoming Events shows event titles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockGetSocieties,
            getEventsForJoinedSocieties: mockGetEvents,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Football Match'), findsOneWidget);
    });

    // Updated: Use findsAtLeastNWidgets because "Football Society" appears twice
    testWidgets('All Societies list shows societies', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockGetSocieties,
            getEventsForJoinedSocieties: mockGetEvents,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Football Society'), findsAtLeastNWidgets(1));
      expect(find.text('Chess Club'), findsOneWidget);
      expect(find.text('Music Society'), findsOneWidget);
    });

  });

  group('User Homepage Widget Tests - Error State', () {
    
    Future<List<dynamic>> mockErrorSocieties() async {
      throw Exception('Failed to load societies');
    }
    
    Future<List<dynamic>> mockErrorEvents() async {
      throw Exception('Failed to load events');
    }

    testWidgets('Shows error message when API fails', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockErrorSocieties,
            getEventsForJoinedSocieties: mockErrorEvents,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('Content sections hidden during error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockErrorSocieties,
            getEventsForJoinedSocieties: mockErrorEvents,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Featured Societies'), findsNothing);
      expect(find.text('All Societies (A-Z)'), findsNothing);
      expect(find.text('Upcoming Events'), findsNothing);
    });

  });
}