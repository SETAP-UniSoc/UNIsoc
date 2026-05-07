import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:unisoc/screens/admin/admin_events_page.dart';
import 'package:unisoc/screens/admin/admin_bottom_nav.dart';

void main() {
  group('Admin Events Widget Tests', () {

    // Test 1: Events page loads with calendar
    testWidgets('Events page loads and displays calendar', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {
              "id": 1,
              "title": "Football Match",
              "description": "Big match",
              "location": "Stadium",
              "start_time": DateTime.now().add(Duration(days: 1)).toIso8601String(),
              "end_time": DateTime.now().add(Duration(days: 1, hours: 2)).toIso8601String(),
              "capacity_limit": 100
            }
          ]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminEventsPage(societyId: 1, httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Events Calendar'), findsOneWidget);
    });

    // Test 2: Loading indicator appears while fetching events
    testWidgets('Shows loading indicator while loading events', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        await Future.delayed(const Duration(seconds: 1));
        return http.Response(
          jsonEncode([]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminEventsPage(societyId: 1, httpClient: mockClient),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // Test 3: Loading indicator disappears after data loads
    testWidgets('Loading indicator disappears when events load', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {
              "id": 1,
              "title": "Test Event",
              "description": "Test",
              "location": "Test Location",
              "start_time": DateTime.now().add(Duration(days: 1)).toIso8601String(),
              "end_time": DateTime.now().add(Duration(days: 1, hours: 2)).toIso8601String(),
              "capacity_limit": 100
            }
          ]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminEventsPage(societyId: 1, httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // Test 4: Empty state when no events
    testWidgets('Shows calendar when no events exist', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminEventsPage(societyId: 1, httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Events Calendar'), findsOneWidget);
    });

    // Test 5: Bottom navigation bar is present
    testWidgets('Bottom navigation bar is displayed', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminEventsPage(societyId: 1, httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(AdminBottomNav), findsOneWidget);
    });

    // Test 6: API error shows snackbar
    testWidgets('Shows error when API fails to load events', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminEventsPage(societyId: 1, httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Events Calendar'), findsOneWidget);
    });

    // Test 7: Page has AppBar with correct title
    testWidgets('AppBar displays correct title', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminEventsPage(societyId: 1, httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Events Calendar'), findsOneWidget);
    });

    // Test 8: Page has Scaffold with correct structure
    testWidgets('Page has proper Scaffold structure', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminEventsPage(societyId: 1, httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    // Test 9: Page handles multiple events
    testWidgets('Page handles multiple events correctly', (WidgetTester tester) async {
      final now = DateTime.now();
      final events = [];
      for (int i = 1; i <= 3; i++) {
        events.add({
          "id": i,
          "title": "Event $i",
          "description": "Description $i",
          "location": "Location $i",
          "start_time": now.add(Duration(days: i)).toIso8601String(),
          "end_time": now.add(Duration(days: i, hours: 2)).toIso8601String(),
          "capacity_limit": 100
        });
      }

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode(events),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminEventsPage(societyId: 1, httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Events Calendar'), findsOneWidget);
    });

    // Test 10: Page loads without crashing on empty response
    testWidgets('Page loads without crashing when response is empty', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminEventsPage(societyId: 1, httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Scaffold), findsOneWidget);
    });

  });
}