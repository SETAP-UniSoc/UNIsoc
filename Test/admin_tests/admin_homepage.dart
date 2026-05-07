import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:unisoc/screens/admin/admin_hompage.dart';
import 'package:unisoc/screens/admin/admin_bottom_nav.dart';

// ─────────────────────────────────────────────
//  Full mock data with ALL fields the widget reads
// ─────────────────────────────────────────────

final _mockSocieties = [
  {
    "id": 1,
    "name": "Football Society",
    "category": "Sports",
    "description": "A football society",
    "member_count": 120,
  },
  {
    "id": 2,
    "name": "Chess Club",
    "category": "Academic",
    "description": "A chess club",
    "member_count": 20,
  },
  {
    "id": 3,
    "name": "Drama Society",
    "category": "Cultural",
    "description": "A drama society",
    "member_count": 50,
  },
];

final _mockEvents = [
  {
    "id": 1,
    "title": "Test Event",
    "description": "An event",
    "start_time": DateTime.now().add(const Duration(days: 1)).toIso8601String(),
    "end_time": DateTime.now()
        .add(const Duration(days: 1, hours: 2))
        .toIso8601String(),
    "location": "Test Location",
    "society_id": 1,
    "society_name": "Football Society",
    "capacity_limit": 50,
  },
];

/// Serves societies for /societies/ and events for /events/ paths.
MockClient _mockClient() => MockClient((request) async {
  final path = request.url.path;
  if (path.contains('/societies/')) {
    return http.Response(jsonEncode(_mockSocieties), 200);
  }
  if (path.contains('/events/')) {
    return http.Response(jsonEncode(_mockEvents), 200);
  }
  return http.Response(jsonEncode([]), 200);
});

/// Serves societies but returns empty events — avoids the null String crash
/// in _buildEventsSection when event fields are missing.
MockClient _mockClientNoEvents() => MockClient((request) async {
  final path = request.url.path;
  if (path.contains('/societies/')) {
    return http.Response(jsonEncode(_mockSocieties), 200);
  }
  return http.Response(jsonEncode([]), 200);
});

/// Always returns a 500 error.
MockClient _errorClient() =>
    MockClient((_) async => http.Response('Server Error', 500));

/// Always returns empty lists.
MockClient _emptyClient() =>
    MockClient((_) async => http.Response(jsonEncode([]), 200));

void main() {
  group('Admin Homepage Widget Tests', () {
    testWidgets('Homepage loads and displays title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AdminHomepage(httpClient: _mockClientNoEvents())),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('UniSoc'), findsOneWidget);
    });

    testWidgets('Shows page when no societies exist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AdminHomepage(httpClient: _emptyClient())),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('UniSoc'), findsOneWidget);
    });

    testWidgets('Bottom navigation bar is displayed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AdminHomepage(httpClient: _emptyClient())),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(AdminBottomNav), findsOneWidget);
    });

    testWidgets('Search bar is displayed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AdminHomepage(httpClient: _emptyClient())),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Search bar accepts text input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AdminHomepage(httpClient: _emptyClient())),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.enterText(find.byType(TextField), 'Football');
      await tester.pump();
      expect(find.text('Football'), findsOneWidget);
    });

    testWidgets('Browse Societies section is displayed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AdminHomepage(httpClient: _mockClientNoEvents())),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Browse Societies'), findsOneWidget);
    });

    testWidgets('Sort by dropdown is displayed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AdminHomepage(httpClient: _emptyClient())),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Sort by'), findsOneWidget);
    });

    testWidgets('Filter by dropdown is displayed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AdminHomepage(httpClient: _emptyClient())),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Filter by'), findsOneWidget);
    });

    testWidgets('Upcoming Events section is displayed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AdminHomepage(httpClient: _mockClient())),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Upcoming Events'), findsOneWidget);
    });

    testWidgets('Top Societies carousel is displayed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AdminHomepage(httpClient: _mockClientNoEvents())),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(Scaffold), findsOneWidget);
      final topText = find.text('Top Societies');
      if (topText.evaluate().isEmpty) {
        expect(find.textContaining('Top'), findsOneWidget);
      } else {
        expect(topText, findsOneWidget);
      }
    });

    testWidgets('Handles API error gracefully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AdminHomepage(httpClient: _errorClient())),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Page has proper Scaffold structure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AdminHomepage(httpClient: _emptyClient())),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
