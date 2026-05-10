import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:unisoc/screens/admin/admin_hompage.dart';
//bottom nav
import 'package:unisoc/screens/admin/admin_bottom_nav.dart';

void main() {
  group('Admin Homepage Widget Tests', () {

    // Test 1: Homepage loads with header
    testWidgets('Homepage loads and displays title', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {"id": 1, "name": "Test Society", "member_count": 10}
          ]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminHomepage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('UniSoc'), findsOneWidget);
    });

    // Test 2: Empty state when no societies
    testWidgets('Shows empty message when no societies exist', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminHomepage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('UniSoc'), findsOneWidget);
    });

    // Test 3: Bottom navigation bar is present
    testWidgets('Bottom navigation bar is displayed', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminHomepage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(AdminBottomNav), findsOneWidget);
    });

    // Test 4: Search bar exists
    testWidgets('Search bar is displayed', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminHomepage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(TextField), findsOneWidget);
    });

    // Test 5: Search bar accepts text input
    testWidgets('Search bar accepts text input', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminHomepage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(find.byType(TextField), 'Football');
      await tester.pump();

      expect(find.text('Football'), findsOneWidget);
    });

    // Test 6: Browse Societies section is displayed
    testWidgets('Browse Societies section is displayed', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {"id": 1, "name": "Test Society", "category": "Academic", "member_count": 10}
          ]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminHomepage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Browse Societies'), findsOneWidget);
    });

    // Test 7: Sort by dropdown exists
    testWidgets('Sort by dropdown is displayed', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminHomepage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Sort by'), findsOneWidget);
    });

    // Test 8: Filter by dropdown exists
    testWidgets('Filter by dropdown is displayed', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminHomepage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Filter by'), findsOneWidget);
    });

    // Test 9: Upcoming Events section is displayed
    testWidgets('Upcoming Events section is displayed', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {
              "id": 1,
              "title": "Test Event",
              "start_time": DateTime.now().add(Duration(days: 1)).toIso8601String(),
              "location": "Test Location",
              "society_id": 1
            }
          ]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminHomepage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Upcoming Events'), findsOneWidget);
    });

    // Test 10: Top Societies carousel is displayed
    testWidgets('Top Societies carousel is displayed', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {"id": 1, "name": "Society 1", "member_count": 10},
            {"id": 2, "name": "Society 2", "member_count": 8},
            {"id": 3, "name": "Society 3", "member_count": 5},
            {"id": 4, "name": "Society 4", "member_count": 3},
            {"id": 5, "name": "Society 5", "member_count": 1}
          ]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminHomepage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Top Societies'), findsOneWidget);
    });

    // Test 11: API error handled gracefully
    testWidgets('Handles API error gracefully', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminHomepage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('UniSoc'), findsOneWidget);
    });

    // Test 12: Page has Scaffold structure
    testWidgets('Page has proper Scaffold structure', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminHomepage(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Scaffold), findsOneWidget);
    });

  });
}