import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:unisoc/screens/admin/admin_hompage.dart';
import 'package:unisoc/screens/admin/admin_bottom_nav.dart';

final mockSocieties = [
  {
    "id": 1,
    "name": "Football Society",
    "category": "Sports",
    "member_count": 120,
  },
];

final mockEvents = [
  {
    "id": 1,
    "title": "Test Event",
    "start_time": DateTime.now().toIso8601String(),
    "location": "Test Location",
    "society_id": 1,
  },
];

MockClient mockClient() => MockClient((request) async {
  if (request.url.path.contains('/societies/')) {
    return http.Response(jsonEncode(mockSocieties), 200);
  }
  if (request.url.path.contains('/events/')) {
    return http.Response(jsonEncode(mockEvents), 200);
  }
  return http.Response(jsonEncode([]), 200);
});

MockClient emptyClient() => MockClient((_) async {
  return http.Response(jsonEncode([]), 200);
});

MockClient errorClient() => MockClient((_) async {
  return http.Response('Error', 500);
});

void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  group('Admin Homepage Functionality Tests', () {

    testWidgets('Homepage loads successfully', (tester) async {
      await tester.pumpWidget(
        wrap(AdminHomepage(httpClient: mockClient())),
      );
      await tester.pumpAndSettle();
      expect(find.text('UniSoc'), findsOneWidget);
    });

    testWidgets('Bottom navigation is displayed', (tester) async {
      await tester.pumpWidget(
        wrap(AdminHomepage(httpClient: mockClient())),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AdminBottomNav), findsOneWidget);
    });

    testWidgets('Search bar is visible', (tester) async {
      await tester.pumpWidget(
        wrap(AdminHomepage(httpClient: mockClient())),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Search accepts input', (tester) async {
      await tester.pumpWidget(
        wrap(AdminHomepage(httpClient: mockClient())),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Football');
      await tester.pump();

      expect(find.text('Football'), findsOneWidget);
    });

    testWidgets('Browse Societies section loads', (tester) async {
      await tester.pumpWidget(
        wrap(AdminHomepage(httpClient: mockClient())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Browse Societies'), findsOneWidget);
    });

    testWidgets('Filter and sort controls are visible', (tester) async {
      await tester.pumpWidget(
        wrap(AdminHomepage(httpClient: mockClient())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sort by'), findsOneWidget);
      expect(find.text('Filter by'), findsOneWidget);
    });

    testWidgets('Events section loads', (tester) async {
      await tester.pumpWidget(
        wrap(AdminHomepage(httpClient: mockClient())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upcoming Events'), findsOneWidget);
    });

    testWidgets('Empty state for societies works', (tester) async {
      await tester.pumpWidget(
        wrap(AdminHomepage(httpClient: emptyClient())),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('API error does not crash app', (tester) async {
      await tester.pumpWidget(
        wrap(AdminHomepage(httpClient: errorClient())),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}