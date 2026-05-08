// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:unisoc/screens/user/settings_user_page.dart';
// import 'package:unisoc/screens/user/my_account_page.dart';
// import 'package:unisoc/user_profile_state.dart';

// class TestNavigatorObserver extends NavigatorObserver {
//   bool pushed = false;

//   @override
//   void didPush(Route route, Route? previousRoute) {
//     pushed = true;
//     super.didPush(route, previousRoute);
//   }
// }

// void main() {
//   Widget buildTestableWidget() {
//     return const MaterialApp(
//       home: MyAccountPage(),
//     );
//   }

//   testWidgets('first name and email fields accept input', (WidgetTester tester) async {
//     await tester.pumpWidget(buildTestableWidget());

//     final firstNameField = find.byType(TextField).first;
//     final emailField = find.byType(TextField).at(2);

//     await tester.enterText(firstNameField, 'Jane');
//     await tester.enterText(emailField, 'jane@example.com');
//     await tester.pump();

//     expect(find.text('Jane'), findsOneWidget);
//     expect(find.text('jane@example.com'), findsOneWidget);
//   });

//   setUp(() {
//     UserProfileState.firstName.value = 'John';
//   });

//   testWidgets('renders my account page fields', (WidgetTester tester) async { // pass
//     await tester.pumpWidget(buildTestableWidget());

//     expect(find.text('My Account'), findsOneWidget);
//     expect(find.text('First Name'), findsOneWidget);
//     expect(find.text('Last Name'), findsOneWidget);
//     expect(find.text('Email Address'), findsOneWidget);
//     expect(find.text('Current Password'), findsOneWidget);
//     expect(find.text('Change Password'), findsOneWidget);

//     expect(find.byType(TextField), findsNWidgets(4));
//     expect(find.byType(ElevatedButton), findsOneWidget);
//   });

//   testWidgets('first name field is initialized from user profile state', // pass
//       (WidgetTester tester) async {
//     await tester.pumpWidget(buildTestableWidget());

//     expect(find.text('John'), findsOneWidget);

//     final firstNameField = find.byType(TextField).first;
//     await tester.enterText(firstNameField, 'Jane');
//     await tester.pump();

//     expect(find.text('Jane'), findsOneWidget);
//   });

//   testWidgets('change password button navigates to settings page', (tester) async {
//     final observer = TestNavigatorObserver();

//     await tester.pumpWidget(
//       MaterialApp(
//         home: const MyAccountPage(),
//         navigatorObservers: [observer],
//       ),
//     );

//     await tester.tap(find.text('Change Password'));
//     await tester.pumpAndSettle();

//     expect(observer.pushed, isTrue);
//     expect(find.byType(UserSettingsPage), findsOneWidget);
//   });

//   testWidgets('current password field is obscured', (WidgetTester tester) async { // pass
//     await tester.pumpWidget(buildTestableWidget());

//     final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
//     final currentPasswordField = fields.last;

//     expect(currentPasswordField.obscureText, isTrue);
//   });
// }