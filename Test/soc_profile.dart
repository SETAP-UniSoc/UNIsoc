import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:unisoc/screens/society_profile_page.dart';

void main() {
  group('Society Profile Page - Simple Load Tests', () {

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
        "description": "Big match",
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
        
        if (url.contains('/societies/') && url.contains('/events/')) {
          return http.Response(jsonEncode(mockEvents), 200);
        }
        if (url.contains('/societies/')) {
          return http.Response(jsonEncode(mockSocietyData), 200);
        }
        if (url.contains('/check-membership/')) {
          return http.Response(jsonEncode({"is_member": false}), 200);
        }
        return http.Response('{}', 200);
      });
    }

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
      
      await tester.pump(const Duration(seconds: 2));
      
      // Just check that something rendered
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // Test 2: Page loads for admin user
    testWidgets('Page loads for admin user', (WidgetTester tester) async {
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
      
      await tester.pump(const Duration(seconds: 2));
      
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // Test 3: Page handles empty events list
    testWidgets('Page handles empty events list', (WidgetTester tester) async {
      final client = MockClient((request) async {
        if (request.url.toString().contains('/events/')) {
          return http.Response(jsonEncode([]), 200);
        }
        return http.Response(jsonEncode(mockSocietyData), 200);
      });
      
      await tester.pumpWidget(
        MaterialApp(
          home: SocietyProfilePage(
            societyId: 1,
            isAdmin: false,
            isOwnSociety: false,
            httpClient: client,
          ),
        ),
      );
      
      await tester.pump(const Duration(seconds: 2));
      
      expect(find.byType(Scaffold), findsOneWidget);
    });

  });
}