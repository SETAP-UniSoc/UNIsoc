import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user_mysoc_page.dart';

void main() {
  testWidgets('shows loading indicator while fetching societies', (tester) async {
    final completer = Completer<List<dynamic>>();

    await tester.pumpWidget(
      MaterialApp(
        home: MySocietyPage(mySocietiesFetcher: () => completer.future),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays societies list after loading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MySocietyPage(
          mySocietiesFetcher: () async => [
            {
              'id': 1,
              'name': 'Chess Club',
              'description': 'Strategy and games',
              'member_count': 10,
            },
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('My Societies'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Chess Club'), findsOneWidget);
    expect(find.textContaining('10 members'), findsOneWidget);
  });

  testWidgets('shows empty state when no societies joined', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MySocietyPage(mySocietiesFetcher: () async => []),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('You have not joined any societies yet.'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('shows error message on fetch failure', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MySocietyPage(
          mySocietiesFetcher: () async {
            throw Exception('server error');
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Error:'), findsOneWidget);
    expect(find.textContaining('server error'), findsOneWidget);
  });

  testWidgets('AppBar displays correct title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MySocietyPage(mySocietiesFetcher: () async => []),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('My Societies'), findsOneWidget);
  });
}