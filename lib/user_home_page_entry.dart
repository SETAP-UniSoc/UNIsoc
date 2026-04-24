import 'package:flutter/material.dart';

import 'screens/user/user_home_page.dart';

void main() {
  runApp(const _UserHomePageEntryApp());
}

class _UserHomePageEntryApp extends StatelessWidget {
  const _UserHomePageEntryApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
