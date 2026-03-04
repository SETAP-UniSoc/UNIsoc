import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';
import 'admin_bottom_nav.dart';
import 'admin_dropdown_menu.dart';

class AdminHomepage extends StatefulWidget {
  const AdminHomepage({super.key});

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
  final CarouselController _societyController = CarouselController();
  final CarouselController _eventController = CarouselController();

  String adminName = "John Smith"; // Later from backend

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
