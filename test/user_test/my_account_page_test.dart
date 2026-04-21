import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/my_account_page.dart';

void main() {
  group('MyAccountPage', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyAccountPage(),
        ),
      );

      expect(find.byType(MyAccountPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}