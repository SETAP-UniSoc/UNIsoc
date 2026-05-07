import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:unisoc/screens/admin/admin_analytics_page.dart';
import 'package:unisoc/services/api_services.dart';

void main() {
  group('Admin Analytics Widget Tests', () {

    // Valid load - page displays data
    testWidgets('Analytics page displays membership data when loaded', (WidgetTester tester) async {
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
      expect(find.text('Live Members: 25'), findsOneWidget);
      expect(find.text('Event Attendance'), findsOneWidget);
    });

    // Empty state - no data
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

    // Loading indicator
    testWidgets('Shows loading indicator while fetching data', (WidgetTester tester) async {
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

      // Immediately after build, loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // Export PDF button
    testWidgets('Export PDF button is present', (WidgetTester tester) async {
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

      expect(find.text('Export as PDF'), findsOneWidget);
    });

    // Period buttons exist
    testWidgets('Period selector buttons (1W, 1M, 6M, 1Y) are displayed', (WidgetTester tester) async {
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

      expect(find.text('1W'), findsOneWidget);
      expect(find.text('1M'), findsOneWidget);
      expect(find.text('6M'), findsOneWidget);
      expect(find.text('1Y'), findsOneWidget);
    });

    // Event attendance list shows event names
    testWidgets('Event attendance list displays event names when data exists', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "labels": ["Week 1"],
            "totals": [10],
            "live_count": 10,
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

      expect(find.text('Tech Talk'), findsOneWidget);
      expect(find.text('Workshop'), findsOneWidget);
    });

    // API failure shows error
    testWidgets('Shows error message when API fails', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminAnalyticsPage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Error snackbar should appear
      expect(find.byType(SnackBar), findsOneWidget);
    });

  });
}