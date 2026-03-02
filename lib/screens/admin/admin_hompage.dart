import 'package:flutter/material.dart';
import 'admin_events_page.dart';
import 'admin_analytics_page.dart';

class AdminHomepage extends StatelessWidget {
  const AdminHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UNISOC"),
        centerTitle: true,
      ),

      body: const SizedBox.shrink(),

      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [

              // Analytics
              IconButton(
                icon: const Icon(Icons.analytics),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminAnalyticsPage(),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Homepage (centered)
              IconButton(
                icon: const Icon(
                  Icons.home,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminHomepage(),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Events page
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminEventsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}