import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'screens/login_screen.user.dart';
=======
import 'home_page.dart';
>>>>>>> dfe222f (Added First Name saving)


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
<<<<<<< HEAD
      home: LoginScreenUser(),
=======
      home: HomePage(),
>>>>>>> dfe222f (Added First Name saving)
    );
  }
}