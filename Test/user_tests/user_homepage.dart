import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user/user_home_page.dart';

void main() {
  group('User Homepage Widget Tests - Success State', () {
    
    // Mock data for successful API responses
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
      {
        "id": 4,
        "name": "Drama Society",
        "category": "Cultural",
        "description": "Drama club",
        "member_count": 12
      },
      {
        "id": 5,
        "name": "Basketball Club",
        "category": "Sports",
        "description": "Basketball club",
        "member_count": 7
      }
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
      {
        "id": 2,
        "title": "Chess Tournament",
        "start_time": DateTime.now().add(Duration(days: 3)).toIso8601String(),
        "location": "Room 101",
        "society_id": 2,
        "society_name": "Chess Club"
      }
    ];

    // Mock functions
    Future<List<dynamic>> mockGetSocieties() async {
      return mockSocieties;
    }
    
    Future<List<dynamic>> mockGetEvents() async {
      return mockEvents;
    }

    testWidgets('HomePage renders successfully with mock data', (WidgetTester tester) async {
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

    testWidgets('Welcome message is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockGetSocieties,
            getEventsForJoinedSocieties: mockGetEvents,
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.textContaining('Welcome'), findsOneWidget);
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

    testWidgets('Featured Societies carousel shows society names', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockGetSocieties,
            getEventsForJoinedSocieties: mockGetEvents,
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Check that society names appear in the carousel
      expect(find.text('Football Society'), findsOneWidget);
      expect(find.text('Chess Club'), findsOneWidget);
      expect(find.text('Music Society'), findsOneWidget);
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
      expect(find.text('Chess Tournament'), findsOneWidget);
    });

    testWidgets('All Societies list shows all societies', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockGetSocieties,
            getEventsForJoinedSocieties: mockGetEvents,
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Check that society names appear in the list
      expect(find.text('Football Society'), findsOneWidget);
      expect(find.text('Chess Club'), findsOneWidget);
      expect(find.text('Music Society'), findsOneWidget);
      expect(find.text('Drama Society'), findsOneWidget);
      expect(find.text('Basketball Club'), findsOneWidget);
    });

  });

  group('User Homepage Widget Tests - Error State', () {
    
    // Mock functions that throw errors
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
      
      // Error message should be shown
      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('Content sections are hidden during error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockErrorSocieties,
            getEventsForJoinedSocieties: mockErrorEvents,
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // These sections should NOT be visible
      expect(find.text('Featured Societies'), findsNothing);
      expect(find.text('All Societies (A-Z)'), findsNothing);
      expect(find.text('Upcoming Events'), findsNothing);
    });

    testWidgets('Search bar still exists during error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockErrorSocieties,
            getEventsForJoinedSocieties: mockErrorEvents,
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Search bar should still be visible even on error
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('UniSoc title still visible during error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            getSocieties: mockErrorSocieties,
            getEventsForJoinedSocieties: mockErrorEvents,
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.text('UniSoc'), findsOneWidget);
    });

  });
}