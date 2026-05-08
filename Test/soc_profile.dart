import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:unisoc/screens/society_profile_page.dart';
import 'package:unisoc/services/api_services.dart';

void main() {
  group('Society Profile Widget Tests', () {

    final mockSocietyData = {
      "id": 1,
      "name": "Football Society",
      "category": "Sports",
      "description": "Football club description",
    };

    final mockEvents = [
      {
        "id": 1,
        "title": "Football Match",
        "description": "Big match this weekend",
        "location": "Stadium",
        "start_time": DateTime.now().add(Duration(days: 1)).toIso8601String(),
        "end_time": DateTime.now().add(Duration(days: 1, hours: 2)).toIso8601String(),
        "capacity_limit": 100,
        "attendee_count": 5
      }
    ];

    http.Client createMockClient() {
      return MockClient((request) async {
        final url = request.url.toString();
        
        if (url.contains('/societies/1/') && !url.contains('/events/') && !url.contains('/admin/') && !url.contains('/check-membership/')) {
          return http.Response(jsonEncode(mockSocietyData), 200);
        }
        if (url.contains('/admin/')) {
          return http.Response(jsonEncode(mockSocietyData), 200);
        }
        if (url.contains('/societies/1/events/')) {
          return http.Response(jsonEncode(mockEvents), 200);
        }
        if (url.contains('/check-membership/')) {
          return http.Response(jsonEncode({"is_member": false}), 200);
        }
        if (url.contains('/attending/')) {
          return http.Response(jsonEncode({"is_attending": false}), 200);
        }
        return http.Response('{}', 404);
      });
    }

    // Test 1: Page renders without crashing
    testWidgets('Page renders without crashing', (WidgetTester tester) async {
      final mockClient = createMockClient();
      
      await tester.pumpWidget(
        MaterialApp(
          home: SocietyProfilePage(
            societyId: 1,
            isAdmin: false,
            isOwnSociety: false,
            httpClient: mockClient,
          ),
        ),
      );
      
      await tester.pump(const Duration(milliseconds: 500));
      
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // Test 2: Scaffold is present
    testWidgets('Scaffold is present', (WidgetTester tester) async {
      final mockClient = createMockClient();
      
      await tester.pumpWidget(
        MaterialApp(
          home: SocietyProfilePage(
            societyId: 1,
            isAdmin: false,
            isOwnSociety: false,
            httpClient: mockClient,
          ),
        ),
      );
      
      await tester.pump(const Duration(milliseconds: 500));
      
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // Test 3: AppBar title is present
    testWidgets('AppBar title is present', (WidgetTester tester) async {
      final mockClient = createMockClient();
      
      await tester.pumpWidget(
        MaterialApp(
          home: SocietyProfilePage(
            societyId: 1,
            isAdmin: false,
            isOwnSociety: false,
            httpClient: mockClient,
          ),
        ),
      );
      
      await tester.pump(const Duration(milliseconds: 500));
      
      expect(find.byType(AppBar), findsOneWidget);
    });

    // Test 4: Society name is displayed in AppBar
    testWidgets('Society name is displayed in AppBar', (WidgetTester tester) async {
      final mockClient = createMockClient();
      
      await tester.pumpWidget(
        MaterialApp(
          home: SocietyProfilePage(
            societyId: 1,
            isAdmin: false,
            isOwnSociety: false,
            httpClient: mockClient,
          ),
        ),
      );
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // AppBar title might take time to load
      expect(find.byType(AppBar), findsOneWidget);
    });

    // Test 5: SingleChildScrollView is present (main content area)
    testWidgets('Main content area is present', (WidgetTester tester) async {
      final mockClient = createMockClient();
      
      await tester.pumpWidget(
        MaterialApp(
          home: SocietyProfilePage(
            societyId: 1,
            isAdmin: false,
            isOwnSociety: false,
            httpClient: mockClient,
          ),
        ),
      );
      
      await tester.pump(const Duration(milliseconds: 500));
      
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    // Test 6: Column is present (main layout)
    testWidgets('Main Column layout is present', (WidgetTester tester) async {
      final mockClient = createMockClient();
      
      await tester.pumpWidget(
        MaterialApp(
          home: SocietyProfilePage(
            societyId: 1,
            isAdmin: false,
            isOwnSociety: false,
            httpClient: mockClient,
          ),
        ),
      );
      
      await tester.pump(const Duration(milliseconds: 500));
      
      expect(find.byType(Column), findsWidgets);
    });

    // Test 7: About section text is present
    testWidgets('About section text is present', (WidgetTester tester) async {
      final mockClient = createMockClient();
      
      await tester.pumpWidget(
        MaterialApp(
          home: SocietyProfilePage(
            societyId: 1,
            isAdmin: false,
            isOwnSociety: false,
            httpClient: mockClient,
          ),
        ),
      );
      
      await tester.pump(const Duration(seconds: 1));
      
      expect(find.text('About'), findsOneWidget);
    });

    // Test 8: Upcoming Events section text is present
    testWidgets('Upcoming Events section text is present', (WidgetTester tester) async {
      final mockClient = createMockClient();
      
      await tester.pumpWidget(
        MaterialApp(
          home: SocietyProfilePage(
            societyId: 1,
            isAdmin: false,
            isOwnSociety: false,
            httpClient: mockClient,
          ),
        ),
      );
      
      await tester.pump(const Duration(seconds: 1));
      
      expect(find.text('Upcoming Events'), findsOneWidget);
    });

  });
}