import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unisoc/services/api_services.dart';

class UserSocietyPage extends StatefulWidget {
  final int societyId;
  final String societyName;
  final String description;

  const UserSocietyPage({
    super.key,
    required this.societyId,
    required this.societyName,
    required this.description,
  });

  @override
  State<UserSocietyPage> createState() => _UserSocietyPageState();
}

class _UserSocietyPageState extends State<UserSocietyPage> {
  List events = [];
  bool joinedSociety = false;
  Timer? pollingTimer;

  @override
  void initState() {
    super.initState();
    loadEvents();
    startPolling();
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    super.dispose();
  }

  void startPolling() {
    pollingTimer =
        Timer.periodic(const Duration(seconds: 5), (_) {
      loadEvents();
    });
  }

  Future<void> loadEvents() async {
    final data =
        await ApiService.getSocietyEvents(widget.societyId);

    for (var event in data) {
      final countData =
          await ApiService.getEventCount(event["id"]);
      event["attendee_count"] =
          countData["attendee_count"];
    }

    setState(() {
      events = data;
    });
  }

  Future<void> toggleJoinSociety() async {
  final endpoint = joinedSociety
      ? "/society/${widget.societyId}/leave/"
      : "/society/${widget.societyId}/join/";

  final url = Uri.parse("${ApiService.baseUrl}$endpoint");

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token ${ApiService.authToken}",
      },
    );

    if (response.statusCode == 201) {
      setState(() {
        joinedSociety = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully joined society 🎉"),
          duration: Duration(seconds: 2),
        ),
      );
    } 
    else if (response.statusCode == 200) {
      setState(() {
        joinedSociety = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully left society"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Network error: $e"),
      ),
    );
  }
}

  Future<void> toggleJoinEvent(int eventId) async {
    final url =
        Uri.parse("${ApiService.baseUrl}/event/$eventId/join/");

    final response = await http.post(url);

    final data = jsonDecode(response.body);

    setState(() {
      events.firstWhere((e) => e["id"] == eventId)
          ["attendee_count"] = data["attendee_count"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.societyName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Text(widget.description),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: toggleJoinSociety,
              child: Text(
                  joinedSociety ? "Leave Society" : "Join Society"),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            event["title"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: joinedSociety
                                ? () =>
                                    toggleJoinEvent(event["id"])
                                : null,
                            child: const Text("Join Event"),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              "👥 ${event["attendee_count"] ?? 0} attending"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

