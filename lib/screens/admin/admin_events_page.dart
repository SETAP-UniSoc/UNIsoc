import 'package:flutter/material.dart';
import 'package:flutter_calenders/flutter_calenders.dart';
import 'package:unisoc/services/api_services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:unisoc/screens/admin/admin_bottom_nav.dart';

class AdminEventsPage extends StatefulWidget {
  final int societyId;

  const AdminEventsPage({super.key, required this.societyId});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  List<Event> calendarEvents = [];
  List eventData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  // 🔥 NORMALIZE DATE (FIXES YOUR ISSUE)
  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> loadEvents() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/events/"),
        headers: ApiService.headers,
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        print("RAW EVENTS: $data");

        setState(() {
          eventData = data;

          calendarEvents = data.map((e) {
  final parsed = DateTime.parse(e["start_time"]).toLocal();

  final normalized = DateTime(
    parsed.year,
    parsed.month,
    parsed.day,
  );

  return Event(
    eventName: e["title"],
    dates: [normalized],
    color: const Color(0xFF8B5CF6),
  );
}).toList();

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  void onDateTapped(DateTime date) {
    final selectedDate = normalizeDate(date);

    final eventsOnDate = eventData.where((e) {
      final parsed = DateTime.parse(e["start_time"]).toLocal();
      final normalized = normalizeDate(parsed);
      return normalized == selectedDate;
    }).toList();

    print("Tapped: $selectedDate → Found: ${eventsOnDate.length}");

    if (eventsOnDate.isNotEmpty) {
      _showMultipleEventsDialog(eventsOnDate);
    } else {
      _showCreateEventDialog(date);
    }
  }

  void _showMultipleEventsDialog(List eventsOnDate) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Events"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: eventsOnDate.length,
            itemBuilder: (context, index) {
              final event = eventsOnDate[index];

              return ListTile(
                title: Text(event["title"]),
                subtitle: Text(event["location"] ?? ""),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _deleteEvent(event["id"]);
                    loadEvents();
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showCreateEventDialog(DateTime selectedDate) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Event"),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: "Title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final start = normalizeDate(selectedDate);

              await _createEvent(
                title: titleController.text,
                startTime: start.toIso8601String(),
                endTime: start.add(const Duration(hours: 1)).toIso8601String(),
              );

              Navigator.pop(context);
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  Future<void> _createEvent({
    required String title,
    required String startTime,
    required String endTime,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/events/"),
      headers: ApiService.headers,
      body: jsonEncode({
        "title": title,
        "start_time": startTime,
        "end_time": endTime,
      }),
    );

    print("CREATE STATUS: ${response.statusCode}");
    print("CREATE BODY: ${response.body}");

    if (response.statusCode == 201) {
      loadEvents();
    }
  }

  Future<void> _deleteEvent(int id) async {
    final response = await http.delete(
      Uri.parse("${ApiService.baseUrl}/events/$id/delete/"),
      headers: ApiService.headers,
    );

    print("DELETE STATUS: ${response.statusCode}");

    if (response.statusCode == 204) {
      loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendar")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : EventBasedCalender(
              events: calendarEvents,
              primaryColor: const Color(0xFF8B5CF6),
              onDateTap: onDateTapped,
            ),
     // bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }
}