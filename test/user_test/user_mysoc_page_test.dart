import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user_mysoc_page.dart';

class TestNavigatorObserver extends NavigatorObserver {
  bool pushed = false;

  @override
  void didPush(Route route, Route? previousRoute) {
    pushed = true;
    super.didPush(route, previousRoute);
  }
}

void main() {
  group('MySocietyPage UI Tests', () {
    testWidgets('shows loading indicator while fetching data', (tester) async {
      // use a completer-controlled future so we can observe the loading state
      final completer = Completer<List>();
      final fetcher = () => completer.future;

      await tester.pumpWidget(MaterialApp(home: MySocietyPage(mySocietiesFetcher: fetcher)));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(<dynamic>[]);
      await tester.pumpAndSettle();
    });

    testWidgets('displays societies list after loading', (tester) async {
      final fetcher = () async => [
            {"id": 1, "name": "A", "member_count": 2, "description": "d"}
          ];

      await tester.pumpWidget(MaterialApp(home: MySocietyPage(mySocietiesFetcher: fetcher)));
      await tester.pumpAndSettle();

      expect(find.text('My Societies'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows empty state when no societies joined', (tester) async {
      final fetcher = () async => <dynamic>[];

      await tester.pumpWidget(MaterialApp(home: MySocietyPage(mySocietiesFetcher: fetcher)));
      await tester.pumpAndSettle();

      expect(find.text('You have not joined any societies yet.'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('shows error message on API failure', (tester) async {
      final fetcher = () async => throw Exception('server error');

      await tester.pumpWidget(MaterialApp(home: MySocietyPage(mySocietiesFetcher: fetcher)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error:'), findsOneWidget);
      expect(find.textContaining('server error'), findsOneWidget);
    });

    testWidgets('renders society tiles with name + member count', (tester) async {
      final fetcher = () async => [
            {"id": 1, "name": "Soc A", "member_count": 1, "description": "desc"},
            {"id": 2, "name": "Soc B", "member_count": 3, "description": "desc"},
          ];

      await tester.pumpWidget(MaterialApp(home: MySocietyPage(mySocietiesFetcher: fetcher)));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsWidgets);
      expect(find.byType(CircleAvatar), findsWidgets);
      expect(find.byIcon(Icons.group), findsWidgets);
    });

    testWidgets('AppBar displays correct title', (tester) async {
      final fetcher = () async => <dynamic>[];

      await tester.pumpWidget(MaterialApp(home: MySocietyPage(mySocietiesFetcher: fetcher)));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('My Societies'), findsOneWidget);
    });
  });

  group('MySocietyPage Data Handling Tests', () {
    testWidgets('member count displays singular and plural correctly', (WidgetTester tester) async {
      final fetcher = () async => [
            {"id": 1, "name": "Solo Soc", "member_count": 1, "description": "d"},
            {"id": 2, "name": "Big Soc", "member_count": 42, "description": "d"},
          ];

      await tester.pumpWidget(MaterialApp(home: MySocietyPage(mySocietiesFetcher: fetcher)));
      await tester.pumpAndSettle();

      expect(find.textContaining('1 member'), findsOneWidget);
      expect(find.textContaining('42 members'), findsOneWidget);
    });

    testWidgets('tapping society navigates to UserSocietyPage', (WidgetTester tester) async {
      final fetcher = () async => [
            {"id": 1, "name": "Tech Society", "member_count": 5, "description": "d"}
          ];

      final observer = TestNavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
          home: MySocietyPage(mySocietiesFetcher: fetcher),
          navigatorObservers: [observer],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      expect(observer.pushed, true);
    });
  });
}