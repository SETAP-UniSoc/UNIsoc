import 'package:flutter/material.dart';
import 'admin_hompage.dart';
import 'admin_events_page.dart';
import 'admin_analytics_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 1; // Default = Home

  final List<Widget> _pages = const [
    AdminAnalyticsPage(),
    AdminHomepage(),
    AdminEventsPage(societyId: 1), // Replace 1 with actual society ID
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UNISOC"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "settings") {
                // TODO: Navigate to settings page
              } else if (value == "logout") {
                Navigator.pop(context); // or navigate to login
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "settings",
                child: Text("Settings"),
              ),
              PopupMenuItem(
                value: "logout",
                child: Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          )
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Analytics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Events",
          ),
        ],
      ),
    );
  }
}