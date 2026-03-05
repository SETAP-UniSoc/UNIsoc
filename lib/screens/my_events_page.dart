import 'package:flutter/material.dart';

class MyEventsPage extends StatelessWidget {
  const MyEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: const Text('My Events'),
        backgroundColor: const Color(0xFF4A235A),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EventCard(
            day: '25',
            month: 'FEB',
            eventName: 'Varsity Wednesday',
          ),
          EventCard(
            day: '24',
            month: 'FEB',
            eventName: 'Goose & Gander Pop Up',
          ),
          EventCard(
            day: '25',
            month: 'FEB',
            eventName: 'Winter Pop-Up Pantry',
          ),
          EventCard(
            day: '25',
            month: 'FEB',
            eventName: 'Board Games Cafe',
          ),
          EventCard(
            day: '26',
            month: 'FEB',
            eventName: 'Handmade with Pride',
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String day;
  final String month;
  final String eventName;

  const EventCard({
    super.key,
    required this.day,
    required this.month,
    required this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF4A235A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    month,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              eventName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
=======
      appBar: AppBar(title: const Text('My Events')),
      body: const Center(child: Text('My Events Page')),
    );
  }
}
>>>>>>> Maya-up2266552
