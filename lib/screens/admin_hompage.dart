import 'package:flutter/material.dart';
import 'admin_events_page.dart';
import 'admin_analytics_page.dart';

class AdminHomepage extends StatelessWidget {
  const AdminHomepage({super.key});

  @override
// add top banner that says uniso in the center then say welcome then the name of admin from sign up gae in the database 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UNISOC"),
        centerTitle: true,
      ),

      body: const SizedBox.shrink(),

      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home),
                  SizedBox(width: 6),
                  //Text("Home"),
                ],
              ),
            ),
            TextButton(
               onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminEventsPage()),
                  );
                },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 6),
                  Text("Events"),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminAnalyticsPage()),
                  );
                },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.analytics),
                  SizedBox(width: 6),
                  Text("Analytics"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

              
        
