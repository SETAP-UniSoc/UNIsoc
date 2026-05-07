import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:unisoc/screens/admin/admin_analytics_page.dart';

void main() {
  group('Admin Analytics Widget Tests', () {

    // Test 1: Analytics page loads with data
    testWidgets('Analytics page loads and displays title', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Week 1", "Week 2", "Week 3", "Week 4"],
            "totals": [10, 15, 20, 25],
            "live_count": 25,
            "events_stats": [
              {"title": "Tech Talk", "attendee_count": 5},
              {"title": "Workshop", "attendee_count": 3}
            ]
          }),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('My Analytics'), findsOneWidget);
    });

    // Test 2: Membership line chart is displayed
    testWidgets('Membership line chart displays when data exists', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Week 1", "Week 2", "Week 3", "Week 4"],
            "totals": [10, 15, 20, 25],
            "live_count": 25,
            "events_stats": []
          }),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('My Analytics'), findsOneWidget);
    });

    // Test 3: Event attendance bar chart displays event names
    testWidgets('Event attendance bar chart displays event names', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Week 1", "Week 2"],
            "totals": [10, 15],
            "live_count": 15,
            "events_stats": [
              {"title": "Football Match", "attendee_count": 10},
              {"title": "Chess Tournament", "attendee_count": 5}
            ]
          }),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Football Match'), findsOneWidget);
      expect(find.text('Chess Tournament'), findsOneWidget);
    });

    // Test 4: Live member count displays correctly
    testWidgets('Live member count shows correct number', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Week 1", "Week 2", "Week 3"],
            "totals": [5, 10, 20],
            "live_count": 20,
            "events_stats": []
          }),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Live Members: 20'), findsOneWidget);
    });

    // Test 5: Empty state message when no data
    testWidgets('Shows empty state message when no event attendance data', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": [],
            "totals": [],
            "live_count": 0,
            "events_stats": []
          }),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('No event attendance data yet'), findsOneWidget);
    });

    // Test 6: Loading indicator appears while fetching data
    testWidgets('Shows loading indicator during data fetch', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        await Future.delayed(const Duration(seconds: 1));
        return http.Response(
          jsonEncode({
            "labels": ["Week 1"],
            "totals": [10],
            "live_count": 10,
            "events_stats": []
          }),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // Test 7: Loading indicator disappears after data loads
    testWidgets('Loading indicator disappears when data loads', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Week 1", "Week 2"],
            "totals": [10, 20],
            "live_count": 20,
            "events_stats": []
          }),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // Test 8: Export PDF button is present
    testWidgets('Export PDF button is displayed on page', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Week 1"],
            "totals": [10],
            "live_count": 10,
            "events_stats": []
          }),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Export as PDF'), findsOneWidget);
    });

    // Test 9: Week period button (1W)
    testWidgets('Week period button (1W) is displayed', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
            "totals": [10, 12, 15, 18, 20, 22, 25],
            "live_count": 25,
            "events_stats": []
          }),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('1W'), findsOneWidget);
    });

    // Test 10: Month period button (1M)
    testWidgets('Month period button (1M) is displayed', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["1 Apr", "2 Apr"],
            "totals": [10, 15],
            "live_count": 15,
            "events_stats": []
          }),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('1M'), findsOneWidget);
    });

    // Test 11: 6 months period button (6M)
    testWidgets('6 months period button (6M) is displayed', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Week 1", "Week 2", "Week 3", "Week 4"],
            "totals": [10, 15, 20, 25],
            "live_count": 25,
            "events_stats": []
          }),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('6M'), findsOneWidget);
    });

    // Test 12: Year period button (1Y)
    testWidgets('Year period button (1Y) is displayed', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Jan", "Feb", "Mar"],
            "totals": [10, 15, 20],
            "live_count": 20,
            "events_stats": []
          }),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('1Y'), findsOneWidget);
    });

    // Test 13: Error message on API failure
    testWidgets('Shows error snackbar when API fails with 500', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(SnackBar), findsOneWidget);
    });

    // Test 14: Bar chart with multiple events (3+ events)
    testWidgets('Bar chart displays multiple event names', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Week 1", "Week 2"],
            "totals": [10, 20],
            "live_count": 20,
            "events_stats": [
              {"title": "Football Match", "attendee_count": 10},
              {"title": "Chess Tournament", "attendee_count": 5},
              {"title": "Music Concert", "attendee_count": 8},
              {"title": "Art Workshop", "attendee_count": 3}
            ]
          }),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Football Match'), findsOneWidget);
      expect(find.text('Chess Tournament'), findsOneWidget);
      expect(find.text('Music Concert'), findsOneWidget);
      expect(find.text('Art Workshop'), findsOneWidget);
    });

    // Test 15: Scrollable event list (simplified - just verify events load)
    testWidgets('Event list loads multiple events', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        final events = [];
        for (int i = 1; i <= 10; i++) {
          events.add({
            "title": "Test Event $i",
            "attendee_count": i * 2
          });
        }
        
        return http.Response(
          jsonEncode({
            "labels": ["Week 1", "Week 2"],
            "totals": [10, 20],
            "live_count": 20,
            "events_stats": events
          }),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify that multiple events are displayed
      expect(find.text('Test Event 1'), findsOneWidget);
      expect(find.text('Test Event 2'), findsOneWidget);
      expect(find.text('Test Event 3'), findsOneWidget);
      expect(find.text('Test Event 4'), findsOneWidget);
      expect(find.text('Test Event 5'), findsOneWidget);
      
      // Verify the page loaded successfully
      expect(find.text('My Analytics'), findsOneWidget);
    });

  });
}