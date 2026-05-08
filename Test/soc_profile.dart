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

    // Create mock client - MATCHING YOUR ACTUAL ENDPOINTS
    http.Client createMockClient() {
      return MockClient((request) async {
        final url = request.url.toString();
        print("🔍 Mock request URL: $url");
        
        // Society details endpoint (non-admin)
        if (url.contains('/societies/1/') && !url.contains('/events/') && !url.contains('/admin/') && !url.contains('/check-membership/')) {
          print("✅ Mock returning society data");
          return http.Response(jsonEncode(mockSocietyData), 200);
        }
        
        // Admin society endpoint
        if (url.contains('/societies/1/admin/')) {
          print("✅ Mock returning admin society data");
          return http.Response(jsonEncode(mockSocietyData), 200);
        }
        
        // Society events endpoint
        if (url.contains('/societies/1/events/')) {
          print("✅ Mock returning events list");
          return http.Response(jsonEncode(mockEvents), 200);
        }
        
        // Check membership endpoint
        if (url.contains('/check-membership/')) {
          print("✅ Mock returning membership status");
          return http.Response(jsonEncode({"is_member": false}), 200);
        }
        
        // Check event attendance endpoint
        if (url.contains('/attending/')) {
          print("✅ Mock returning attendance status");
          return http.Response(jsonEncode({"is_attending": false}), 200);
        }
        
        // Join event endpoint
        if (url.contains('/join/') && url.contains('/events/')) {
          print("✅ Mock returning join event response");
          return http.Response(jsonEncode({"message": "Joined event", "attendee_count": 6}), 200);
        }
        
        // Leave event endpoint
        if (url.contains('/leave/') && url.contains('/events/')) {
          print("✅ Mock returning leave event response");
          return http.Response(jsonEncode({"message": "Left event successfully"}), 200);
        }
        
        // Join society endpoint
        if (url.contains('/society/1/join/')) {
          print("✅ Mock returning join society response");
          return http.Response(jsonEncode({"message": "Joined successfully"}), 201);
        }
        
        // Leave society endpoint
        if (url.contains('/society/1/leave/')) {
          print("✅ Mock returning leave society response");
          return http.Response(jsonEncode({"message": "Successfully left society"}), 200);
        }
        
        print("❌ Mock returning 404 for: $url");
        return http.Response('{"error": "Not found"}', 404);
      });
    }

    // Test 1: Society name is displayed
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

    // Test 2: Join Society button is shown for regular users
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

    // Test 3: Attend Event button is shown
    testWidgets('Attend Event button is shown for non-admin users', (WidgetTester tester) async {
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

    // Test 4: Edit button not shown for regular users
    testWidgets('Edit button not shown for non-admin users', (WidgetTester tester) async {
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
      
      expect(find.byIcon(Icons.edit), findsNothing);
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
    testWidgets('Event title is displayed in carousel', (WidgetTester tester) async {
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

    // Test 7: Capacity limit is displayed
    testWidgets('Capacity limit is displayed when event has capacity', (WidgetTester tester) async {
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
      
      expect(find.text('Capacity: 100'), findsOneWidget);
    });

    // Test 8: Category chip is displayed
    testWidgets('Category chip is displayed when society has category', (WidgetTester tester) async {
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
      
      expect(find.text('Sports'), findsOneWidget);
    });

  });
}