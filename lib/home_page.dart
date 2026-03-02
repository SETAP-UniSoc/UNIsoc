import 'package:flutter/material.dart';
import 'navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: const [
            // Header with navbar + "UniSoc" + "Welcome Student"
            HomeHeader(),

            // Main content placeholder
            Expanded(child: Center(child: Text('Home content here'))),
          ],
        ),
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeNavbar();
  }
}
