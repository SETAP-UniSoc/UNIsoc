import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user/user_home_page.dart';

Widget buildHeaderTestApp(HomeHeader header) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: header,
      ),
    ),
  );
}

void main() {
  testWidgets('HomeHeader shows loading indicator initially',
      (WidgetTester tester) async {
    final completer = Completer<List<dynamic>>();

    await tester.pumpWidget(
      buildHeaderTestApp(
        HomeHeader(
          getSocieties: () => completer.future,
          getEventsForJoinedSocieties: () async => <dynamic>[],
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('UniSoc'), findsNothing);
  });

  testWidgets('HomeHeader shows error text when data loading fails',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildHeaderTestApp(
        HomeHeader(
          getSocieties: () async => throw Exception('boom'),
          getEventsForJoinedSocieties: () async => <dynamic>[],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Error:'), findsOneWidget);
  });
}
