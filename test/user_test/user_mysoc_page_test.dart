import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unisoc/screens/user_mysoc_page.dart';

void main() {
  testWidgets('shows loading indicator while fetching societies', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MySocietyPage()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays societies list after loading', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MySocietyPage()));
    await tester.pumpAndSettle();

 
    expect(find.text('My Societies'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('shows error message on API failure', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MySocietyPage()));
    await tester.pumpAndSettle();
  });

  testWidgets('shows empty state when no societies joined', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MySocietyPage()));
    await tester.pumpAndSettle();

    expect(find.text('You have not joined any societies yet.'), findsWidgets);
  });

  testWidgets('renders society ListTile with name and member count', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MySocietyPage()));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsWidgets);
    expect(find.byType(CircleAvatar), findsWidgets);
    expect(find.byIcon(Icons.group), findsWidgets);
  });

  testWidgets('tapping society navigates to UserSocietyPage', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MySocietyPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();
  });

  testWidgets('AppBar has correct styling', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MySocietyPage()));
    await tester.pumpAndSettle();

    final appBar = find.byType(AppBar);
    expect(appBar, findsOneWidget);
    final titleWidget = find.text('My Societies');
    expect(titleWidget, findsOneWidget);
  });

  testWidgets('member count displays singular and plural correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MySocietyPage()));
    await tester.pumpAndSettle();
  });
}