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

    setUp(() {
      ApiService.authToken = 'test-token';
    });

    // Test 1: Page loads without crashing
    testWidgets('Page loads without crashing', (WidgetTester tester) async {
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
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // Test 2: Loading indicator is shown initially
    testWidgets('Loading indicator is shown while data loads', (WidgetTester tester) async {
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
      
      // Check for loading indicator on first frame
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // Test 3: Loading indicator disappears after data loads
    testWidgets('Loading indicator disappears after data loads', (WidgetTester tester) async {
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
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // Test 4: Society name appears in AppBar
    testWidgets('Society name appears in AppBar after load', (WidgetTester tester) async {
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
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.text('Football Society'), findsOneWidget);
    });

    // Test 5: Page loads for admin user (no errors)
    testWidgets('Page loads for admin user without crashing', (WidgetTester tester) async {
      final mockClient = createMockClient();
      
      await tester.pumpWidget(
        MaterialApp(
          home: SocietyProfilePage(
            societyId: 1,
            isAdmin: true,
            isOwnSociety: true,
            httpClient: mockClient,
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // Test 6: Edit button appears for admin on own society
    testWidgets('Edit button appears for admin on own society', (WidgetTester tester) async {
      ApiService.societyId = 1;
      final mockClient = createMockClient();
      
      await tester.pumpWidget(
        MaterialApp(
          home: SocietyProfilePage(
            societyId: 1,
            isAdmin: true,
            isOwnSociety: true,
            httpClient: mockClient,
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.byIcon(Icons.edit), findsOneWidget);
      
      ApiService.societyId = null;
    });

    // Test 7: Join Society button appears for non-admin users
    testWidgets('Join Society button appears for non-admin users', (WidgetTester tester) async {
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
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.text('Join Society'), findsOneWidget);
    });

    // Test 8: Upcoming Events section appears
    testWidgets('Upcoming Events section appears', (WidgetTester tester) async {
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
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.text('Upcoming Events'), findsOneWidget);
    });

  });
}