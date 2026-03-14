import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unisoc/services/api_services.dart';
import 'admin_bottom_nav.dart';

class AdminMyAccountPage extends StatefulWidget {
  const AdminMyAccountPage({super.key});

  @override
  State<AdminMyAccountPage> createState() => _AdminMyAccountPageState();
}

class _AdminMyAccountPageState extends State<AdminMyAccountPage> {
  Map societyData = {};
  List events = [];
  bool isLoading = true;
  bool isEditing = false;
  final TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    descController.dispose();
    super.dispose();
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
      final id = ApiService.societyId;
      if (id == null) return;

      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/society/$id/"),
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

  // load upcoming events for this society
  Future<void> loadEvents() async {
    try {
      final id = ApiService.societyId;
      if (id == null) return;

      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/society/$id/events/"),
        headers: ApiService.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final now = DateTime.now();
        setState(() {
          events = data.where((e) =>
            DateTime.parse(e["start_time"]).isAfter(now)
          ).toList();
        });
      }
    } catch (e) {
      print("Error loading events: $e");
    }
  }

  // save updated description
  Future<void> saveDescription() async {
    try {
      final id = ApiService.societyId;
      if (id == null) return;

      final response = await http.patch(
        Uri.parse("${ApiService.baseUrl}/society/$id/"),
        headers: ApiService.headers,
        body: jsonEncode({"description": descController.text}),
      );

      if (response.statusCode == 200) {
        setState(() => isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Description updated ✅")),
        );
        loadSociety(); // refresh
      }
    } catch (e) {
      print("Error saving description: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(societyData["name"] ?? "My Society"),
        actions: [
          // edit/save button for description
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

                  // description section
                  const Text(
                    "About",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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
                              : "No description yet — tap edit to add one.",
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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
                            final startTime = DateTime.parse(event["start_time"]).toLocal();
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
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }
}