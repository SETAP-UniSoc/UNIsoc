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

  // Fetch events from backend and convert to calendar Event objects
  Future<void> loadEvents() async {
    setState(() => isLoading = true);
    
    print("📅 Loading events for society ID: ${widget.societyId}");
    print("🔑 Token: ${ApiService.authToken}");
    print("🌐 URL: ${ApiService.baseUrl}/societies/${widget.societyId}/events/");
    
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/events/"),
        headers: ApiService.headers,
      );

      print("📊 Events response status: ${response.statusCode}");
      
      if (response.statusCode == 204) {
        final data = jsonDecode(response.body) as List;
        final now = DateTime.now();
        
        // Only show upcoming events (future dates)
        final upcomingEvents = data.where((e) =>
          DateTime.parse(e["start_time"]).isAfter(now)
        ).toList();

        print("✅ Loaded ${upcomingEvents.length} upcoming events");

        setState(() {
          eventData = upcomingEvents;
          calendarEvents = upcomingEvents.map((e) => Event(
            eventName: e["title"],
            dates: [DateTime.parse(e["start_time"]).toLocal()],
            color: const Color(0xFF8B5CF6), // Purple to match theme
          )).toList();
          isLoading = false;
        });
      } else {
        print("❌ Failed to load events: ${response.statusCode}");
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load events: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("❌ LOAD EVENTS ERROR: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading events")),
      );
    }
  }

  // Show popup when admin taps a date - shows ALL events on that date
  void onDateTapped(DateTime date) {
    final selectedDate = DateTime(date.year, date.month, date.day);
    
    // Find ALL events on this date
    final eventsOnDate = eventData.where((e) {
      final eventDate = DateTime.parse(e["start_time"]).toLocal();
      final normalizedEventDate = DateTime(eventDate.year, eventDate.month, eventDate.day);
      return normalizedEventDate == selectedDate;
    }).toList();

    print("📅 Date tapped: $selectedDate, found ${eventsOnDate.length} events");

    if (eventsOnDate.isNotEmpty) {
      // Show ALL events on this date
      _showMultipleEventsDialog(eventsOnDate);
    } else {
      // Create new event
      _showCreateEventDialog(date);
    }
  }

  // Show dialog with ALL events on a date
  void _showMultipleEventsDialog(List eventsOnDate) {
    final formattedDate = "${eventsOnDate[0]["start_time"].toString().substring(0, 10)}";
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Events on $formattedDate"),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: eventsOnDate.length,
            itemBuilder: (context, index) {
              final event = eventsOnDate[index];
              final startTime = DateTime.parse(event["start_time"]).toLocal();
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.event, color: Color(0xFF8B5CF6)),
                  title: Text(
                    event["title"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("⏰ ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}"),
                      if (event["location"] != null && event["location"].toString().isNotEmpty)
                        Text("📍 ${event["location"]}"),
                      if (event["description"] != null && event["description"].toString().isNotEmpty)
                        Text(event["description"], maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _deleteEvent(event["id"]);
                      loadEvents();
                    },
                  ),
                  onTap: () => _showSingleEventDetails(event),
                  
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
              _showCreateEventDialog(DateTime.parse(eventsOnDate[0]["start_time"]));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: const Text("Add Another Event"),
          ),
        ],
      ),
    );
  }

  // Show single event details (when tapping from the list)
  void _showSingleEventDetails(Map event) {
    final startTime = DateTime.parse(event["start_time"]).toLocal();
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(event["title"]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event["description"] != null && event["description"].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(event["description"]),
              ),
            Text("📍 ${event["location"] ?? 'No location'}"),
            const SizedBox(height: 4),
            Text("⏰ ${startTime.day}/${startTime.month}/${startTime.year} at ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}"),
            if (event["capacity_limit"] != null) ...[
              const SizedBox(height: 4),
              Text("👥 Capacity: ${event["capacity_limit"]}"),
            ],
            const SizedBox(height: 8),
            Text("✅ ${event["attendee_count"] ?? 0} people attending"),
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
              Navigator.pop(context);
              await _deleteEvent(event["id"]);
              loadEvents();
            },
            child: const Text("Delete Event", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditEventDialog(event);
            },
            child: const Text("Edit Event"),
          ),
        ],
      ),
    );
  }

  // Edit event dialog
  void _showEditEventDialog(Map event) {
    final titleController = TextEditingController(text: event["title"]);
    final descController = TextEditingController(text: event["description"] ?? "");
    final locationController = TextEditingController(text: event["location"] ?? "");
    final capacityController = TextEditingController(text: event["capacity_limit"]?.toString() ?? "");
    final startDateTime = DateTime.parse(event["start_time"]).toLocal();
    final endDateTime = DateTime.parse(event["end_time"]).toLocal();
    TimeOfDay startTime = TimeOfDay(hour: startDateTime.hour, minute: startDateTime.minute);
    TimeOfDay endTime = TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit Event"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Title *",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: "Location",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Start Time"),
                        subtitle: Text(startTime.format(context)),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );
                          if (picked != null) setDialogState(() => startTime = picked);
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("End Time"),
                        subtitle: Text(endTime.format(context)),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );
                          if (picked != null) setDialogState(() => endTime = picked);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Capacity (optional)",
                    hintText: "Leave blank for unlimited",
                    border: OutlineInputBorder(),
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
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a title")),
                  );
                  return;
                }

                final start = DateTime(
                  startDateTime.year, startDateTime.month, startDateTime.day,
                  startTime.hour, startTime.minute,
                );
                final end = DateTime(
                  endDateTime.year, endDateTime.month, endDateTime.day,
                  endTime.hour, endTime.minute,
                );

                await _updateEvent(
                  eventId: event["id"],
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
              ),
              child: const Text("Update Event"),
            ),
          ],
        ),
      ),
    );
  }

  // PUT update event to backend
  Future<void> _updateEvent({
    required int eventId,
    required String title,
    required String description,
    required String location,
    required String startTime,
    required String endTime,
    int? capacity,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiService.baseUrl}/event/$eventId/"),
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

      print("✏️ Update event response: ${response.statusCode}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event updated successfully! ✅")),
        );
        loadEvents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update event: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("❌ Error updating event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating event")),
      );
    }
  }

  // Create event dialog
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
                  decoration: const InputDecoration(
                    labelText: "Title *",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: "Location",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Start Time"),
                        subtitle: Text(startTime.format(context)),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );
                          if (picked != null) setDialogState(() => startTime = picked);
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("End Time"),
                        subtitle: Text(endTime.format(context)),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );
                          if (picked != null) setDialogState(() => endTime = picked);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Capacity (optional)",
                    hintText: "Leave blank for unlimited",
                    border: OutlineInputBorder(),
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
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a title")),
                  );
                  return;
                }

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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
              ),
              child: const Text("Create Event"),
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

      print("📝 Create event response: ${response.statusCode}");
      print("📝 Response body: ${response.body}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event created successfully! 🎉")),
        );
        loadEvents(); // Auto-refresh calendar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create event: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("❌ Error creating event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error creating event")),
      );
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
        loadEvents(); // Auto-refresh after delete
      } else {
        print("❌ Failed to delete event: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error deleting event: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Events Calendar"),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: EventBasedCalender(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(8),
                        events: calendarEvents,
                        primaryColor: const Color(0xFF8B5CF6),
                        backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                        chooserColor: Colors.black,
                        endYear: 2028,
                        startYear: 2024,
                        currentMonthDateColor: Colors.black,
                        pastFutureMonthDateColor: Colors.grey,
                        isSelectedColor: const Color(0xFF8B5CF6),
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