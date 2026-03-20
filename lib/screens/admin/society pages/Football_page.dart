import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unisoc/services/api_services.dart';
import 'package:unisoc/screens/admin/admin_bottom_nav.dart';

//creating a football soc page for admin and user in society page 
class FootballSocPage extends StatefulWidget {
  final int societyId;
  final bool isAdmin;

  const FootballSocPage({
    super.key,
    required this.societyId,
    required this.isAdmin,
  });

  @override
  State<FootballSocPage> createState() => _FootballSocPageState();
}

// creating what both admins and users will se for the soc page but only admins will be able to add a description which will be saved util they want to chnage it 

class _FootballSocPageState extends State<FootballSocPage> {
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

   Future<void> loadData() async {
    await Future.wait([
      loadSociety(),
      loadEvents(),
      if (!widget.isAdmin) checkMembership(),
    ]);
    setState(() => isLoading = false);
  }

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
          events = data.where((e) =>
            DateTime.parse(e["start_time"]).isAfter(now)
          ).toList();
        });
      }
    } catch (e) {
      print("Error loading events: $e");
    }
  }

  Future<void> checkMembership() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/society/${widget.societyId}/is-member/"),
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

  //only admin can save and write description and it will be saved until they want to change it again and only for that soc page
  Future<void> saveDescription() async {
    try {
      final response = await http.patch(
        Uri.parse("${ApiService.baseUrl}/society/${widget.societyId}/"),
        headers: ApiService.headers,
        body: jsonEncode({"description": descController.text}),
      );
      if (response.statusCode == 200) {
        setState(() => isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Description updated ✅")),
        );
        loadSociety();
      }
    } catch (e) {
      print("Error saving description: $e");
    }
  }

// join and leave buttons 
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
            content: Text(isMember
                ? "Successfully joined society 🎉"
                : "Successfully left society"),
          ),
        );
      }
    } catch (e) {
      print("Error toggling membership: $e");
    }
  }

  