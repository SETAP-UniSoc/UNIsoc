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
  List eventData = [];
  bool isLoading = true;

  DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  // LOAD EVENTS + GROUP BY DATE
  Future<void> loadEvents() async {
    setState(() => isLoading = true);

    final url = "${ApiService.baseUrl}/societies/${widget.societyId}/events/";
    print("🔍 Loading events from: $url");

    final res = await http.get(Uri.parse(url), headers: ApiService.headers);

    print("📊 Events response status: ${res.statusCode}");
    print("📊 Events response body: ${res.body}");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      print("✅ Found ${data.length} events");

      // GROUP EVENTS BY DATE
      Map<String, List> grouped = {};

      for (var e in data) {
        final parsed = DateTime.parse(e["start_time"]).toLocal();
        final key = "${parsed.year}-${parsed.month}-${parsed.day}";

        if (!grouped.containsKey(key)) {
          grouped[key] = [];
        }
        grouped[key]!.add(e);
      }

      // CREATE CALENDAR EVENTS (ONE PER DAY)
      List<Event> calEvents = grouped.entries.map((entry) {
        final parts = entry.key.split("-");
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );

        return Event(
          eventName: "${entry.value.length} events",
          dates: [date],
          color: entry.value.length > 1 ? Colors.red : const Color(0xFF8B5CF6),
        );
      }).toList();

      setState(() {
        eventData = data;
        calendarEvents = calEvents;
        isLoading = false;
      });
    } else {
      print("❌ Failed to load events");
      setState(() => isLoading = false);
    }
  }

  // TAP DATE
  void onDateTapped(DateTime date) {
    final selected = normalize(date);

    final eventsOnDate = eventData.where((e) {
      final parsed = DateTime.parse(e["start_time"]).toLocal();
      return normalize(parsed) == selected;
    }).toList();

    if (eventsOnDate.isNotEmpty) {
      _showEvents(eventsOnDate);
    } else {
      _showCreateDialog(date);
    }
  }

  // SHOW EVENTS LIST
  void _showEvents(List events) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Events (${events.length})"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: events.length,
            itemBuilder: (_, i) {
              final e = events[i];
              final time = DateTime.parse(e["start_time"]).toLocal();

              return ListTile(
                title: Text(e["title"]),
                subtitle: Text(
                  "${time.hour}:${time.minute} • ${e["location"] ?? ""} • ${e["capacity_limit"] != null ? "Cap: ${e["capacity_limit"]}" : "No Cap"}",
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(e);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _deleteEvent(e["id"]);
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showCreateDialog(
                DateTime.parse(events[0]["start_time"]).toLocal(),
              );
            },
            child: const Text("Add Another"),
          ),
        ],
      ),
    );
  }

  // CREATE EVENT
  void _showCreateDialog(DateTime date) {
    final title = TextEditingController();
    final desc = TextEditingController();
    final loc = TextEditingController();
    final cap = TextEditingController();

    TimeOfDay start = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 10, minute: 0);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setStateDialog) => AlertDialog(
          title: const Text("Create Event"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: desc,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: loc,
                decoration: const InputDecoration(labelText: "Location"),
              ),

              TextField(
                controller: cap,
                decoration: const InputDecoration(
                  labelText: "Capacity (optional)",
                ),
                keyboardType: TextInputType.number,
              ),

              ListTile(
                title: const Text("Start Time"),
                subtitle: Text(start.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: start,
                  );
                  if (picked != null) setStateDialog(() => start = picked);
                },
              ),
              ListTile(
                title: const Text("End Time"),
                subtitle: Text(end.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: end,
                  );
                  if (picked != null) setStateDialog(() => end = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final startDT = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  start.hour,
                  start.minute,
                );
                final endDT = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  end.hour,
                  end.minute,
                );

                await _createEvent(
                  title: title.text,
                  description: desc.text,
                  location: loc.text,
                  startTime: startDT.toIso8601String(),
                  endTime: endDT.toIso8601String(),
                  capacity: cap.text.isEmpty ? null : int.tryParse(cap.text),
                );

                Navigator.pop(context);
              },
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }

  // EDIT EVENT
  void _showEditDialog(Map event) {
    final title = TextEditingController(text: event["title"]);
    final desc = TextEditingController(text: event["description"]);
    final loc = TextEditingController(text: event["location"]);
    final cap = TextEditingController(
      text: event["capacity_limit"]?.toString() ?? "",
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Event"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: title),
            TextField(controller: desc),
            TextField(controller: loc),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updateEvent(event["id"], {
                "title": title.text,
                "description": desc.text,
                "location": loc.text,
                "start_time": event["start_time"],
                "end_time": event["end_time"],
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _createEvent({
    required String title,
    required String description,
    required String location,
    required String startTime,
    required String endTime,
    int? capacity,
  }) async {
    Map<String, dynamic> body = {
      "title": title,
      "description": description,
      "location": location,
      "start_time": startTime,
      "end_time": endTime,
    };

    // Only add capacity if it's not null AND greater than 0
    if (capacity != null && capacity > 0) {
      body["capacity_limit"] = capacity;
    }

    print("📝 Creating event with body: $body");

    final res = await http.post(
      Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/events/"),
      headers: ApiService.headers,
      body: jsonEncode(body),
    );

    print("📊 Create event response: ${res.statusCode}");
    print("📊 Response body: ${res.body}");

    if (res.statusCode == 201) {
      print("✅ Event created successfully");
      loadEvents();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event created successfully!")),
      );
    } else {
      print("❌ Failed to create event");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create event: ${res.statusCode}")),
      );
    }
  }

  Future<void> _updateEvent(int id, Map data) async {
    final res = await http.put(
      Uri.parse("${ApiService.baseUrl}/events/$id/update/"),
      headers: ApiService.headers,
      body: jsonEncode(data),
    );

    if (res.statusCode == 200) {
      print("✅ Event updated successfully");
      loadEvents();
    } else {
      print("❌ Failed to update event: ${res.statusCode}");
    }
  }

  Future<void> _deleteEvent(int id) async {
    final res = await http.delete(
      Uri.parse("${ApiService.baseUrl}/events/$id/delete/"),
      headers: ApiService.headers,
    );

    if (res.statusCode == 204) {
      print("✅ Event deleted successfully");
      loadEvents();
    } else {
      print("❌ Failed to delete event: ${res.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events Calendar"),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: EventBasedCalender(
                      events: calendarEvents,
                      primaryColor: const Color(0xFF8B5CF6),
                      onDateTap: onDateTapped,
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }
}
























