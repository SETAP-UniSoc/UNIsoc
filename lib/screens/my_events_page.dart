import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  late Future<List> _futureMyEvents;

  @override
  void initState() {
    super.initState();
    _futureMyEvents = _loadMyEvents();
  }

  Future<List> _loadMyEvents() async {
    try {
      // Fetch the societies the user has joined
      final societies = await ApiService.getMySocieties();

      // Fetch events for each society
      List events = [];
      for (var society in societies) {
        final societyEvents = await ApiService.getSocietyEvents(society['id']);
        events.addAll(societyEvents);
      }

      return events;
    } catch (e) {
      throw Exception("Failed to load events: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        backgroundColor: const Color(0xFF4A235A),
      ),
      body: FutureBuilder<List>(
        future: _futureMyEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return const Center(
              child: Text(
                'You have no upcoming events.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index] as Map<String, dynamic>;
              final day = event['date'].split('-')[2]; // Extract day from date
              final month = event['date'].split(
                '-',
              )[1]; // Extract month from date
              final eventName = event['title'] as String? ?? '';

              return EventCard(day: day, month: month, eventName: eventName);
            },
          );
        },
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
