//imports
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unisoc/services/api_services.dart';
import 'package:unisoc/screens/admin/admin_bottom_nav.dart';
import 'package:unisoc/screens/admin/admin_events_page.dart';
import 'package:unisoc/screens/my_events_page.dart';

//society profile page used by both users and admins — shows society details and upcoming events. Admins can also edit the description
class SocietyProfilePage extends StatefulWidget {
  final int societyId;
  final bool isAdmin;

  const SocietyProfilePage({
    super.key,
    required this.societyId,
    required this.isAdmin,
  });

  @override
  State<SocietyProfilePage> createState() => _SocietyProfilePageState();
}

class _SocietyProfilePageState extends State<SocietyProfilePage> {
  Map societyData = {};
  List events = [];
  bool isLoading = true;
  bool isEditing = false;
  bool isMember = false;
  Timer? pollingTimer;
  final TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
    if (!widget.isAdmin) startPolling();
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    descController.dispose();
    super.dispose();
  }

  void startPolling() {
    pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadEvents();
    });
  }

  Future<void> loadData() async {
    await Future.wait([
      loadSociety(),
      loadEvents(),
    ]);
    setState(() => isLoading = false);
  }

  // load society details
  Future<void> loadSociety() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/"),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          societyData = data;
          descController.text = data["description"] ?? "";
        });
        print(" Loaded society: ${data["name"]} (ID: ${widget.societyId})");
      } else {
        print(" Failed to load society: ${response.statusCode}");
      }
    } catch (e) {
      print(" Error loading society: $e");
    }
  }

  // load upcoming events
  Future<void> loadEvents() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiService.baseUrl}/societies/${widget.societyId}/events/",
        ),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final now = DateTime.now();
        setState(() {
          final upcoming = data
              .where((e) => DateTime.parse(e["start_time"]).isAfter(now))
              .toList();

          upcoming.sort(
            (a, b) => DateTime.parse(
              a["start_time"],
            ).compareTo(DateTime.parse(b["start_time"])),
          );

          events = upcoming;
        });
        print("Loaded ${events.length} events");
      }
    } catch (e) {
      print("Error loading events: $e");
    }
  }

 
  // Admin saves description - PERSISTS in database!
  Future<void> saveDescription() async {
    try {
      if (descController.text != societyData["description"]) {
        final response = await http.patch(
          Uri.parse("${ApiService.baseUrl}/societies/${widget.societyId}/"),
          headers: ApiService.headers,
          body: jsonEncode({"description": descController.text}),
        );
        
        if (response.statusCode == 200) {
          setState(() => isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Description saved ")),
          );
          loadSociety(); // Refresh to show updated data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to save: ${response.statusCode}")),
          );
        }
      } else {
        setState(() => isEditing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Description updated ✅")));
        loadSociety();
      }
    } catch (e) {
      print(" Error saving description: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving description")),
      );
    }
  }


Future<void> toggleJoinSociety() async {
  final endpoint = isMember
      ? "/societies/${widget.societyId}/leave/"
      : "/societies/${widget.societyId}/join/";

  try {
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}$endpoint"),
      headers: ApiService.headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      
      if (data["message"] == "Already joined") {
        setState(() => isMember = true);
      } else if (data["message"] == "Successfully joined society") {
        setState(() => isMember = true);
      } else if (data["message"] == "Successfully left society") {
        setState(() => isMember = false);
      } else {
        setState(() => isMember = !isMember);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Success")),
      );
    }
  } catch (e) {
    print("Error toggling membership: $e");
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isAdmin,
        title: Text(societyData["name"] ?? "Society"),
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit),
              onPressed: () {
                if (isEditing) {
                  saveDescription();
                } else {
                  setState(() => isEditing = true);
                }
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // society header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          societyData["name"] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          societyData["category"] ?? "",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // join/leave button — users only
                  if (!widget.isAdmin)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: toggleJoinSociety,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMember ? Colors.red : Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isMember ? "Leave Society" : "Join Society",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                  if (!widget.isAdmin) const SizedBox(height: 24),

                  // about section
                  const Text(
                    "About",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  isEditing
                      ? TextField(
                          controller: descController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: "Write a description for your society...",
                          ),
                        )
                      : SizedBox(
  height: 320,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: events.length,
    itemBuilder: (context, index) {
      final event = events[index];
      final startTime = DateTime.parse(event["start_time"]).toLocal();

      // return Container(
      //   width: 300,
      //   margin: const EdgeInsets.only(right: 16),
      //   child: Card(

      // elevation: 0,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [

      return GestureDetector(
        onTap: widget.isAdmin
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyEventsPage()
                      
                    
                  ),
                );
              },
        child: Container(
          width: 300,
          margin: const EdgeInsets.only(right: 16),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event["title"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            "${startTime.day}/${startTime.month}/${startTime.year}",
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time,
                              size: 14, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event["description"] ?? "No description",
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF4B5563)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event["location"] ?? "No location",
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF6B7280)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (event["capacity_limit"] != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.people,
                                size: 16, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 6),
                            Text(
                              "Capacity: ${event["capacity_limit"]}",
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ),
),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
      bottomNavigationBar: widget.isAdmin
          ? const AdminBottomNav(currentIndex: 0)
          : null,
    );
  }
}
