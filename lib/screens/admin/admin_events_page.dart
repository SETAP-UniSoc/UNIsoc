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

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> loadEvents() async {
    setState(() => isLoading = true);

    final res = await http.get(
      Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/events/"),
      headers: ApiService.headers,
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;

      setState(() {
        eventData = data;

        calendarEvents = data.map((e) {
          final parsed = DateTime.parse(e["start_time"]).toLocal();
          return Event(
            eventName: e["title"],
            dates: [normalize(parsed)], // 🔥 key fix
            color: const Color(0xFF8B5CF6),
          );
        }).toList();

        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

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
                subtitle: Text("${time.hour}:${time.minute} • ${e["location"] ?? ""}"),
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
        ],
      ),
    );
  }

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
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: title, decoration: const InputDecoration(labelText: "Title")),
                TextField(controller: desc, decoration: const InputDecoration(labelText: "Description")),
                TextField(controller: loc, decoration: const InputDecoration(labelText: "Location")),

                ListTile(
                  title: const Text("Start Time"),
                  subtitle: Text(start.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: start);
                    if (picked != null) setStateDialog(() => start = picked);
                  },
                ),

                ListTile(
                  title: const Text("End Time"),
                  subtitle: Text(end.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: end);
                    if (picked != null) setStateDialog(() => end = picked);
                  },
                ),

                TextField(
                  controller: cap,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Capacity"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final startDT = DateTime(date.year, date.month, date.day, start.hour, start.minute);
                final endDT = DateTime(date.year, date.month, date.day, end.hour, end.minute);

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
            )
          ],
        ),
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
    final res = await http.post(
      Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/events/"),
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

    if (res.statusCode == 201) loadEvents();
  }

  Future<void> _deleteEvent(int id) async {
    final res = await http.delete(
      Uri.parse("${ApiService.baseUrl}/events/$id/delete/"),
      headers: ApiService.headers,
    );

    if (res.statusCode == 204) loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Events Calendar")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : EventBasedCalender(
              events: calendarEvents,
              primaryColor: const Color(0xFF8B5CF6),
              onDateTap: onDateTapped,
            ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }
}