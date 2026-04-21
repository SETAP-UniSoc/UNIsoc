import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/my_events_page.dart';

void main() {
  group('MyEventsPage', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyEventsPage(),
        ),
      );

      expect(find.byType(MyEventsPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}