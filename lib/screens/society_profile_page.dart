//imports
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unisoc/services/api_services.dart';
import 'package:unisoc/screens/admin/admin_bottom_nav.dart';

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
      if (!widget.isAdmin) checkMembership(),
    ]);
    setState(() => isLoading = false);
  }

  // load society details
  Future<void> loadSociety() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/society/${widget.societyId}/"),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          societyData = data;
          descController.text = data["description"] ?? "";
        });
      }
    } catch (e) {
      print("Error loading society: $e");
    }
  }

  // load upcoming events
  Future<void> loadEvents() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/society/${widget.societyId}/events/"),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final now = DateTime.now();
        setState(() {
          events = data
              .where((e) => DateTime.parse(e["start_time"]).isAfter(now))
              .toList();
        });
      }
    } catch (e) {
      print("Error loading events: $e");
    }
  }

  // check if user is already a member
  Future<void> checkMembership() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiService.baseUrl}/society/${widget.societyId}/is-member/",
        ),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => isMember = data["is_member"] ?? false);
      }
    } catch (e) {
      print("Error checking membership: $e");
    }
  }

  // admin saves description
  Future<void> saveDescription() async {
    try {
      final response = await http.patch(
        Uri.parse("${ApiService.baseUrl}/society/${widget.societyId}/"),
        headers: ApiService.headers,
        body: jsonEncode({"description": descController.text}),
      );
      if (response.statusCode == 200) {
        setState(() => isEditing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Description updated ✅")));
        loadSociety();
      }
    } catch (e) {
      print("Error saving description: $e");
    }
  }

  // user joins or leaves society
  Future<void> toggleJoinSociety() async {
    final endpoint = isMember
        ? "/society/${widget.societyId}/leave/"
        : "/society/${widget.societyId}/join/";

    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}$endpoint"),
        headers: ApiService.headers,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() => isMember = !isMember);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isMember
                  ? "Successfully joined society 🎉"
                  : "Successfully left society",
            ),
          ),
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
                      : Text(
                          societyData["description"]?.isNotEmpty == true
                              ? societyData["description"]
                              : widget.isAdmin
                              ? "No description yet — tap edit to add one."
                              : "No description yet.",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),

                  const SizedBox(height: 24),

                  // upcoming events section
                  const Text(
                    "Upcoming Events",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  events.isEmpty
                      ? const Text(
                          "No upcoming events",
                          style: TextStyle(color: Colors.grey),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            final startTime = DateTime.parse(
                              event["start_time"],
                            ).toLocal();
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.event,
                                  color: Colors.blue,
                                ),
                                title: Text(event["title"]),
                                subtitle: Text(
                                  "${startTime.day}/${startTime.month}/${startTime.year} — ${event["location"] ?? 'No location'}",
                                ),
                                trailing: event["capacity_limit"] != null
                                    ? Text(
                                        "Cap: ${event["capacity_limit"]}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
      bottomNavigationBar: widget.isAdmin
          ? const AdminBottomNav(currentIndex: 0)
          : null,
    );
  }
}



