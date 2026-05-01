import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user/user_home_page.dart';

void main() {
  testWidgets('HomeHeader shows loading indicator initially', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeHeader()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('UniSoc'), findsNothing);
  });
}