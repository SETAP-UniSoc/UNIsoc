import 'package:flutter/material.dart';
import 'screens/my_account_page.dart';
import 'screens/login_screen.user.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

//keep entry poin the same
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyAccountPage(),
      home: LoginScreenUser(),
    );
  }
}