import 'package:flutter/material.dart';
import 'package:flutter_calenders/flutter_calenders.dart';
import 'package:unisoc/services/api_services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unisoc/screens/admin/admin_bottom_nav.dart';

class AdminEventsPage extends StatefulWidget {
  final int societyId;

  const AdminEventsPage({super.key, required this.societyId});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  List<Event> calendarEvents = [];
  List eventData = []; // raw data from backend

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  // fetch events from backend and convert to calendar Event objects
  Future<void> loadEvents() async {
  print("SOCIETY ID: ${widget.societyId}");  // ← move to here
  print("TOKEN: ${ApiService.authToken}");    // ← move to here
  print("URL: ${ApiService.baseUrl}/society/${widget.societyId}/api/events/");
  try {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/society/${widget.societyId}/api/events/"),
      headers: ApiService.headers,
    );

    print("Load events status: ${response.statusCode}");
    print("Load events body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;

      final now = DateTime.now();

      final filtered = data.where((e) =>
        DateTime.parse(e["start_time"]).isAfter(now)
      ).toList();

//       setState(() {
//   eventData = data;
//   calendarEvents = data.map((e) => Event(
//     eventName: e["title"],
//     dates: [DateTime.parse(e["start_time"]).toLocal()],
//     color: Colors.blue,
//   )).toList();
// });

      setState(() {
        eventData = filtered;
        calendarEvents = filtered.map((e) => Event(
          eventName: e["title"],
          dates: [DateTime.parse(e["start_time"])],
          color: Colors.blue,
        )).toList();
      });
    }
  } catch (e) {
    print("LOAD EVENTS ERROR: $e");
  }
}









// Future<void> loadEvents() async {
//     try {
//       final response = await http.get(
//         Uri.parse("${ApiService.baseUrl}/society/${widget.societyId}/api/events/"),
//         headers: ApiService.headers,
//       );

//       if (response.statusCode == 200) {
//         final List data = jsonDecode(response.body);
//         final now = DateTime.now().toUtc();

//         final filtered = data.where((e) =>
//           DateTime.parse(e["start_time"]).toUtc().isAfter(now)
//         ).map((e) => Map<String, dynamic>.from(e)).toList();

//         setState(() {
//           eventData = filtered;
//           calendarEvents = filtered.map((e) {
//             // convert start time to local for display
//             final start = DateTime.parse(e["start_time"]).toLocal();
//             final end = DateTime.parse(e["end_time"]).toLocal();
//             return Event(
//               eventName: e["title"],
//               dates: [start],
//               color: Colors.blue,
//               // optionally store end time if package supports multi-hour
//             );
//           }).toList();
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to load events: ${response.statusCode}")),
//         );
//       }
//     } catch (e) {
//       print("LOAD EVENTS ERROR: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Error loading events")),
//       );
//     }
//   }


  // show popup when admin taps a date
  // void onDateTapped(DateTime date) {
  //   // check if there's already an event on this date
  //   final existing = eventData.where((e) =>
  //     DateTime.parse(e["start_time"]).toLocal().day == date.day &&
  //     DateTime.parse(e["start_time"]).toLocal().month == date.month &&
  //     DateTime.parse(e["start_time"]).toLocal().year == date.year
  //   ).toList();

  //   if (existing.isNotEmpty) {
  //     // show existing event with remove button
  //     _showEventDetails(existing.first);
  //   } else {
  //     // show create event form
  //     _showCreateEventDialog(date);
  //   }
  // }

  // show popup when admin taps a date
void onDateTapped(DateTime date) {
  final selectedDate = DateTime(date.year, date.month, date.day);

  final existing = eventData.where((e) {
    final eventDate = DateTime.parse(e["start_time"]).toLocal();
    final normalizedEventDate =
        DateTime(eventDate.year, eventDate.month, eventDate.day);

    return normalizedEventDate == selectedDate;
  }).toList();

  if (existing.isNotEmpty) {
    _showEventDetails(existing.first);
  } else {
    _showCreateEventDialog(date);
  }
}

  // popup to view and remove an existing event
  void _showEventDetails(Map event) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(event["title"]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event["description"] ?? ""),
            const SizedBox(height: 8),
            Text("📍 ${event["location"] ?? 'No location'}"),
            const SizedBox(height: 8),
            Text("👥 ${event["attendee_count"]} attending"),
            if (event["capacity_limit"] != null)
              Text("🔒 Capacity: ${event["capacity_limit"]}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _deleteEvent(event["id"]);
              Navigator.pop(context);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // popup form to create a new event
  void _showCreateEventDialog(DateTime selectedDate) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    final capacityController = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Create Event"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title *"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: "Location"),
                ),
                const SizedBox(height: 10),

                // start time picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Start: ${startTime.format(context)}"),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (picked != null) setDialogState(() => startTime = picked);
                  },
                ),

                // end time picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("End: ${endTime.format(context)}"),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (picked != null) setDialogState(() => endTime = picked);
                  },
                ),

                // optional capacity
                TextField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Set Capacity (optional)",
                    hintText: "Leave blank for unlimited",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;

                // build datetime strings for backend
                final start = DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day,
                  startTime.hour, startTime.minute,
                );
                final end = DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day,
                  endTime.hour, endTime.minute,
                );

                await _createEvent(
                  title: titleController.text,
                  description: descController.text,
                  location: locationController.text,
                  startTime: start.toIso8601String(),
                  endTime: end.toIso8601String(),
                  capacity: capacityController.text.isEmpty
                      ? null
                      : int.tryParse(capacityController.text),
                );

                Navigator.pop(context);
              },
              child: const Text("Post"),
            ),
          ],
        ),
      ),
    );
  }

  // POST new event to backend
  Future<void> _createEvent({
    required String title,
    required String description,
    required String location,
    required String startTime,
    required String endTime,
    int? capacity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/society/${widget.societyId}/events/"),
        headers: ApiService.headers,
        body: jsonEncode({
          "title": title,
          "description": description,
          "location": location,
          "start_time": startTime,
          "end_time": endTime,
          if (capacity != null) "capacity_limit": capacity,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event created ✅")),
        );
        loadEvents(); // refresh calendar
      }
    } catch (e) {
      print("Error creating event: $e");
    }
  }

  // DELETE event via backend
  Future<void> _deleteEvent(int eventId) async {
    try {
      final response = await http.delete(
        Uri.parse("${ApiService.baseUrl}/event/$eventId/delete/"),
        headers: ApiService.headers,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event removed")),
        );
        loadEvents(); // refresh calendar
      }
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Calendar"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: EventBasedCalender(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  events: calendarEvents,
                  primaryColor: Colors.blue,
                  backgroundColor: Colors.blue.withValues(alpha: .05),
                  chooserColor: Colors.black,
                  endYear: 2028,
                  startYear: 2024,
                  currentMonthDateColor: Colors.black,
                  pastFutureMonthDateColor: Colors.grey,
                  isSelectedColor: Colors.amber,
                  isSelectedShow: true,
                  showEvent: true,
                  onDateTap: (date) => onDateTapped(date),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }
}
