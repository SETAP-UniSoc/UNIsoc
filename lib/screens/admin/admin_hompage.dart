import 'package:flutter/material.dart';
import 'bottom_navbar.dart';

class AdminHomepage extends StatelessWidget {
  const AdminHomepage({super.key});

//calling bottom nav bar file  bottom_navbar.dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          "UNISOC Admin Dashboard",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }
}
