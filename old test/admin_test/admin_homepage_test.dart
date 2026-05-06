import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unisoc/screens/admin/admin_hompage.dart';

http.Client mockHttp({
  required String societiesJson,
  required String eventsJson,
  required String searchJson,
}) {
  return MockClient((request) async {
    final url = request.url.toString();

    if (url.contains('/societies/') && url.contains('?q=')) {
      return http.Response(searchJson, 200);
    }

    if (url.contains('/societies/') && !url.contains('/events/')) {
      return http.Response(societiesJson, 200);
    }

    if (url.contains('/events/all/')) {
      return http.Response(eventsJson, 200);
    }

    if (url.contains('/search')) {
      return http.Response(searchJson, 200);
    }

    return http.Response('Not Found', 404);
  });
}
void main() {
  tearDown(() {
    HttpOverrides.global = null;
  });
  testWidgets('renders header and sections when APIs return empty lists',
      (WidgetTester tester) async {
    final client = mockHttp(
      societiesJson: jsonEncode([]),
      eventsJson: jsonEncode([]),
      searchJson: jsonEncode([]),
    );

    await tester.pumpWidget(MaterialApp(home: AdminHomepage(httpClient: client)));
    await tester.pumpAndSettle();

    expect(find.text('UniSoc'), findsOneWidget);
    expect(find.text('Top Societies'), findsOneWidget);
    expect(find.text('Browse Societies'), findsOneWidget);
    expect(find.text('Upcoming Events'), findsOneWidget);
  });

  testWidgets('loads societies and events from API and shows items',
      (WidgetTester tester) async {
    final client = mockHttp(
      societiesJson: jsonEncode([
        {"id": 1, "name": "TestSoc", "category": "Academic", "member_count": 10}
      ]),
      eventsJson: jsonEncode([
        {
          "title": "Event1",
          "start_time": "2025-01-01T10:00:00Z",
          "location": "Hall",
          "society_id": 1,
          "capacity_limit": 50
        }
      ]),
      searchJson: jsonEncode([]),
    );

    await tester.pumpWidget(MaterialApp(home: AdminHomepage(httpClient: client)));
    await tester.pumpAndSettle();

    expect(find.text('TestSoc'), findsWidgets);
    expect(find.text('Event1'), findsWidgets);
  });

  testWidgets('typing in search shows dropdown results (debounced)',
      (WidgetTester tester) async {
    final client = mockHttp(
      societiesJson: jsonEncode([]),
      eventsJson: jsonEncode([]),
      searchJson: jsonEncode([
        {"id": 2, "name": "FoundSoc", "type": "society"}
      ]),
    );
    await tester.pumpWidget(MaterialApp(home: AdminHomepage(httpClient: client)));
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField).first;
    await tester.enterText(searchField, 'Found');

    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('FoundSoc'), findsOneWidget);
  });
}

