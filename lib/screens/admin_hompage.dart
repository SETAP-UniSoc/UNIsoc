//import 'dart:convert';
//import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'login_screen.admin.dart';

// admin homepage with navigation bar in thenavigation banner
class AdminHomepage extends StatelessWidget {
  const AdminHomepage({super.key});

//creating bannaer at top with three line navugation button and title of page
//adding a navigation bar three lines in right corner of navigation banner and adding a title of page in center of navigation banner
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Homepage"),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Handle navigation menu tap

            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          //displays admin name in the center of the page with a welcome message
          
          "Welcome",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}