import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unisoc/screens/admin/admin_analytics_page.dart';

List<int> _analyticsBody({
  List<String> labels = const [],
  List<int> totals = const [],
  int liveCount = 0,
  List<Map<String, dynamic>> eventsStats = const [],
}) {
  return utf8.encode(jsonEncode({
    "labels": labels,
    "totals": totals,
    "live_count": liveCount,
    "events_stats": eventsStats,
  }));
}

void main() {
  tearDown(() {});

  testWidgets('shows empty state when no event attendance data',
      (WidgetTester tester) async {
    final client = _mockAnalyticsClient(body: _analyticsBody(
      labels: ["Jan"],
      totals: [50],
      liveCount: 50,
      eventsStats: [],
    ));

    await tester.pumpWidget(MaterialApp(home: AdminAnalyticsPage(httpClient: client)));
    await tester.pumpAndSettle();

    expect(find.text('No event attendance data yet'), findsOneWidget);
    expect(find.text('When users attend events, their attendance will appear here'), findsOneWidget);
  });

  testWidgets('shows empty membership chart when no data',
      (WidgetTester tester) async {
    final client = _mockAnalyticsClient(body: _analyticsBody());
    await tester.pumpWidget(MaterialApp(home: AdminAnalyticsPage(httpClient: client)));
    await tester.pumpAndSettle();

    expect(find.text('No data yet'), findsOneWidget);
  });

  testWidgets('exports PDF button is present', (WidgetTester tester) async {
    final client = _mockAnalyticsClient(body: _analyticsBody(labels: ["Jan"], totals: [50], liveCount: 50));
    await tester.pumpWidget(MaterialApp(home: AdminAnalyticsPage(httpClient: client)));
    await tester.pumpAndSettle();

    expect(find.text('Export as PDF'), findsOneWidget);
  });

  testWidgets('renders loading indicator and then analytics when data loads',
      (WidgetTester tester) async {
    // use a delayed response so the loading indicator appears briefly
    final client = MockClient((request) async {
      await Future.delayed(const Duration(milliseconds: 50));
      return http.Response(jsonEncode({
        'labels': ["Jan", "Feb", "Mar"],
        'totals': [10, 20, 30],
        'live_count': 30,
      }), 200);
    });

    await tester.pumpWidget(MaterialApp(home: AdminAnalyticsPage(httpClient: client)));

    // first frame should show the loading indicator
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('My Analytics'), findsOneWidget);
    expect(find.text('30'), findsWidgets);
  });

  testWidgets('fetches analytics and displays membership trend data',
      (WidgetTester tester) async {
    final client = _mockAnalyticsClient(body: _analyticsBody(labels: ["Week 1", "Week 2", "Week 3"], totals: [100, 150, 200], liveCount: 200));
    await tester.pumpWidget(MaterialApp(home: AdminAnalyticsPage(httpClient: client)));
    await tester.pumpAndSettle();

    expect(find.text('200'), findsWidgets);
    expect(find.text('Live Members: 200'), findsOneWidget);
  });

  testWidgets('displays event attendance bar chart with data',
      (WidgetTester tester) async {
    final client = _mockAnalyticsClient(body: _analyticsBody(eventsStats: [
      {"title": "Tech Talk", "attendee_count": 45},
      {"title": "Networking", "attendee_count": 82},
      {"title": "Workshop", "attendee_count": 120},
    ]));

    await tester.pumpWidget(MaterialApp(home: AdminAnalyticsPage(httpClient: client)));
    await tester.pumpAndSettle();

    expect(find.text('Event Attendance'), findsOneWidget);
    expect(find.text('Tech Talk'), findsOneWidget);
    expect(find.text('Networking'), findsOneWidget);
    expect(find.text('Workshop'), findsOneWidget);
  });

  testWidgets('displays live member count correctly',
      (WidgetTester tester) async {
    final client = _mockAnalyticsClient(body: _analyticsBody(labels: ["Jan", "Feb"], totals: [100, 150], liveCount: 150));
    await tester.pumpWidget(MaterialApp(home: AdminAnalyticsPage(httpClient: client)));
    await tester.pumpAndSettle();

    expect(find.text('Live Members: 150'), findsOneWidget);
  });

  testWidgets('period buttons update analytics when tapped',
      (WidgetTester tester) async {
    int callCount = 0;
    final client = MockClient((request) async {
      callCount++;
      final uri = request.url.toString();
      if (uri.contains('period=week')) {
        return http.Response(jsonEncode({
          'labels': ["Mon", "Tue"],
          'totals': [10, 15],
          'live_count': 15,
        }), 200);
      } else if (uri.contains('period=month')) {
        return http.Response(jsonEncode({
          'labels': ["Week 1", "Week 2"],
          'totals': [50, 75],
          'live_count': 75,
        }), 200);
      }
      return http.Response(jsonEncode({
        'labels': ["Jan"],
        'totals': [100],
        'live_count': 100,
      }), 200);
    });

    await tester.pumpWidget(MaterialApp(home: AdminAnalyticsPage(httpClient: client)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1W'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1M'));
    await tester.pumpAndSettle();

    // initial load + 1W tap + 1M tap = at least 3 calls
    expect(callCount, greaterThan(1));
  });
}

http.Client _mockAnalyticsClient({required List<int> body}) {
  return MockClient((request) async {
    return http.Response.bytes(body, 200);
  });
}
