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
        if (url.contains('/societies/1/admin/')) {
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

    // Test 1: Page loads
    testWidgets('Page loads successfully', (WidgetTester tester) async {
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
      
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // Test 2: Society name is displayed
    testWidgets('Society name is displayed', (WidgetTester tester) async {
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
      
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      expect(find.text('Football Society'), findsOneWidget);
    });

    // Test 3: Join Society button is shown
    testWidgets('Join Society button is shown for non-admin users', (WidgetTester tester) async {
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
      
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      expect(find.text('Join Society'), findsOneWidget);
    });

    // Test 4: Attend Event button is shown
    testWidgets('Attend Event button is shown', (WidgetTester tester) async {
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
      
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      expect(find.text('Attend Event'), findsOneWidget);
    });

    // Test 5: Upcoming Events section is displayed
    testWidgets('Upcoming Events section is displayed', (WidgetTester tester) async {
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
      
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      expect(find.text('Upcoming Events'), findsOneWidget);
    });

    // Test 6: Event title is displayed
    testWidgets('Event title is displayed', (WidgetTester tester) async {
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
      
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      expect(find.text('Football Match'), findsOneWidget);
    });

  });
}