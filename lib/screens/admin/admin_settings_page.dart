import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unisoc/services/api_services.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscureOld = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  // notifications
  List notificationPrefs = [];
  bool notificationsLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
     // loadNotifications();
    });
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> loadNotifications() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/notifications/"),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        setState(() {
          notificationPrefs = jsonDecode(response.body);
          notificationsLoading = false;
        });
      }
    } catch (e) {
      setState(() => notificationsLoading = false);
      print("Error loading notifications: $e");
    }
  }

  Future<void> toggleNotification(int societyId, bool currentValue) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/notifications/"),
        headers: ApiService.headers,
        body: jsonEncode({
          "society_id": societyId,
          "notify": !currentValue,
        }),
      );
      if (response.statusCode == 200) {
        loadNotifications();
      }
    } catch (e) {
      print("Error toggling notification: $e");
    }
  }

  Future<void> changePassword() async {
    final oldPassword = oldPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("All fields are required");
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar("New passwords do not match");
      return;
    }

    if (newPassword.length < 8) {
      _showSnackBar("New password must be at least 8 characters");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/change-password/"),
        headers: ApiService.headers,
        body: jsonEncode({
          "old_password": oldPassword,
          "new_password": newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showSnackBar("Password changed successfully ✅");
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      } else {
        _showSnackBar(data["error"] ?? "Something went wrong");
      }
    } catch (e) {
      _showSnackBar("Unable to connect to server");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Account Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Manage your account security",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // notifications section
            const Text(
              "Notifications",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              "Manage email notifications for your societies",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            notificationsLoading
                ? const Center(child: CircularProgressIndicator())
                : notificationPrefs.isEmpty
                    ? const Text(
                        "No notification preferences yet",
                        style: TextStyle(color: Colors.grey),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notificationPrefs.length,
                        itemBuilder: (context, index) {
                          final pref = notificationPrefs[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SwitchListTile(
                              title: Text(
                                pref["society"],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                pref["notify"]
                                    ? "Notifications on"
                                    : "Notifications off",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: pref["notify"]
                                      ? Colors.purple
                                      : Colors.grey,
                                ),
                              ),
                              value: pref["notify"] ?? true,
                              activeColor: Colors.purple,
                              onChanged: (val) {
                                toggleNotification(
                                  pref["society_id"],
                                  pref["notify"] ?? true,
                                );
                              },
                            ),
                          );
                        },
                      ),

            const SizedBox(height: 32),

            // change password section
            const Text(
              "Change Password",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: oldPasswordController,
              obscureText: obscureOld,
              decoration: InputDecoration(
                labelText: "Current Password",
                labelStyle: const TextStyle(color: Colors.purple),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.purple),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureOld ? Icons.visibility_off : Icons.visibility,
                    color: Colors.purple,
                  ),
                  onPressed: () => setState(() => obscureOld = !obscureOld),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: newPasswordController,
              obscureText: obscureNew,
              decoration: InputDecoration(
                labelText: "New Password",
                labelStyle: const TextStyle(color: Colors.purple),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.purple),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureNew ? Icons.visibility_off : Icons.visibility,
                    color: Colors.purple,
                  ),
                  onPressed: () => setState(() => obscureNew = !obscureNew),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: confirmPasswordController,
              obscureText: obscureConfirm,
              decoration: InputDecoration(
                labelText: "Confirm New Password",
                labelStyle: const TextStyle(color: Colors.purple),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.purple),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: Colors.purple,
                  ),
                  onPressed: () =>
                      setState(() => obscureConfirm = !obscureConfirm),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}