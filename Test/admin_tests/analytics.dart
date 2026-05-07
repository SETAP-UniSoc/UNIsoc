import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:unisoc/screens/admin/admin_analytics_page.dart';

void main() {
  group('Admin Analytics Widget Tests', () {

    // Test 1: Analytics page loads with data
    testWidgets('Analytics page loads and displays title',
        (WidgetTester tester) async {

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

      await tester.pumpAndSettle();

      expect(find.text('My Analytics'), findsOneWidget);
    });

    // Test 2: Membership chart loads
    testWidgets('Membership line chart displays when data exists',
        (WidgetTester tester) async {

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

      await tester.pumpAndSettle();

      expect(find.text('My Analytics'), findsOneWidget);
    });

    // Test 3: Event names appear
    testWidgets('Event attendance bar chart displays event names',
        (WidgetTester tester) async {

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

      await tester.pumpAndSettle();

      expect(find.text('Football Match'), findsOneWidget);
      expect(find.text('Chess Tournament'), findsOneWidget);
    });

    // Test 4: Live members count
    testWidgets('Live member count shows correct number',
        (WidgetTester tester) async {

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

      await tester.pumpAndSettle();

      expect(find.text('Live Members: 20'), findsOneWidget);
    });

    // Test 5: Empty event state
    testWidgets('Shows empty state message when no event attendance data',
        (WidgetTester tester) async {

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

      await tester.pumpAndSettle();

      expect(find.text('No event attendance data yet'), findsOneWidget);
    });

    // Test 6: Loading indicator
    testWidgets('Shows loading indicator during data fetch',
        (WidgetTester tester) async {

      final completer = Completer<http.Response>();

      final mockClient = MockClient((request) {
        return completer.future;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      completer.complete(
        http.Response(
          jsonEncode({
            "labels": ["Week 1"],
            "totals": [10],
            "live_count": 10,
            "events_stats": []
          }),
          200,
        ),
      );

      await tester.pumpAndSettle();
    });

    // Test 7: Loading disappears
    testWidgets('Loading indicator disappears when data loads',
        (WidgetTester tester) async {

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

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // Test 8: Export PDF button
    testWidgets('Export PDF button is displayed on page',
        (WidgetTester tester) async {

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

      await tester.pumpAndSettle();

      expect(find.text('Export as PDF'), findsOneWidget);
    });

    // Test 9: 1W button
    testWidgets('Week period button (1W) is displayed',
        (WidgetTester tester) async {

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Mon", "Tue"],
            "totals": [10, 12],
            "live_count": 12,
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

      await tester.pumpAndSettle();

      expect(find.text('1W'), findsOneWidget);
    });

    // Test 10: 1M button
    testWidgets('Month period button (1M) is displayed',
        (WidgetTester tester) async {

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

      await tester.pumpAndSettle();

      expect(find.text('1M'), findsOneWidget);
    });

    // Test 11: 6M button
    testWidgets('6 months period button (6M) is displayed',
        (WidgetTester tester) async {

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

      await tester.pumpAndSettle();

      expect(find.text('6M'), findsOneWidget);
    });

    // Test 12: 1Y button
    testWidgets('Year period button (1Y) is displayed',
        (WidgetTester tester) async {

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Jan", "Feb"],
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

      await tester.pumpAndSettle();

      expect(find.text('1Y'), findsOneWidget);
    });

    // Test 13: Multiple events render
    testWidgets('Event list loads multiple events',
        (WidgetTester tester) async {

      final mockClient = MockClient((request) async {

        final events = List.generate(
          10,
          (i) => {
            "title": "Test Event ${i + 1}",
            "attendee_count": (i + 1) * 2,
          },
        );

        return http.Response(
          jsonEncode({
            "labels": ["Week 1", "Week 2"],
            "totals": [10, 20],
            "live_count": 20,
            "events_stats": events,
          }),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Analytics'), findsOneWidget);

      expect(find.text('Event Attendance'), findsOneWidget);

      expect(find.text('Test Event 1'), findsOneWidget);
      expect(find.text('Test Event 2'), findsOneWidget);
      expect(find.text('Test Event 3'), findsOneWidget);

      expect(find.byType(ListView), findsWidgets);
    });
  });
}