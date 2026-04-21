import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/settings_user_page.dart';

void main() {
  group('SettingsPage', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );

      await tester.pump(); // allow initState async tasks to start
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}