import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user_mysoc_page.dart';

void main() {
  group('MySocietyPage', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MySocietyPage(),
        ),
      );

      expect(find.byType(MySocietyPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}