import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:unisoc/services/api_services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool emailUpdates = true;
  bool loadingEmailPref = true;
  bool savingEmailPref = false;
  bool savingPassword = false;
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmailPreference();
  }

  Future<void> _loadEmailPreference() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/user/email-updates/"),
        headers: ApiService.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (!mounted) return;
        setState(() {
          emailUpdates = data["email_updates"] == true;
          loadingEmailPref = false;
        });
        return;
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() => loadingEmailPref = false);
  }

  Future<void> _setEmailPreference(bool value) async {
    setState(() {
      emailUpdates = value;
      savingEmailPref = true;
    });

    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/user/email-updates/"),
        headers: ApiService.headers,
        body: jsonEncode({"email_updates": value}),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email preferences updated')),
        );
        return;
      }

      if (!mounted) return;
      String message = 'Could not save email preferences.';
      if (response.statusCode == 401 || response.statusCode == 403) {
        message = 'Session expired. Please log in again.';
      } else {
        try {
          final body = jsonDecode(response.body);
          if (body is Map<String, dynamic>) {
            message = (body['error'] ?? body['message'] ?? message).toString();
          }
        } catch (_) {}
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server timeout. Please try again.')),
      );
    } on http.ClientException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server unreachable. Check your backend URL.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not sync with server. Preference kept locally.'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => savingEmailPref = false);
    }
  }

  Future<void> _updatePassword() async {
    final oldPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmNewPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all password fields.')),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 6 characters.')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.')),
      );
      return;
    }

    setState(() => savingPassword = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/change-password/"),
        headers: ApiService.headers,
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      ).timeout(const Duration(seconds: 8));

      if (!mounted) return;

      if (response.statusCode == 200) {
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmNewPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully.')),
        );
        return;
      }

      String message = 'Could not update password.';
      if (response.statusCode == 401 || response.statusCode == 403) {
        message = 'Session expired. Please log in again.';
      } else {
        try {
          final body = jsonDecode(response.body);
          if (body is Map<String, dynamic>) {
            message = (body['error'] ?? body['message'] ?? message).toString();
          }
        } catch (_) {}
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server timeout. Please try again.')),
      );
    } on http.ClientException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server unreachable. Check your backend URL.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error while updating password.')),
      );
    } finally {
      if (!mounted) return;
      setState(() => savingPassword = false);
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A235A),
      ),
      body: ListView(
        children: [
          // Notifications Section
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          ListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive email notifications'),
            trailing: Switch(
              value: emailUpdates,
              onChanged: (loadingEmailPref || savingEmailPref)
                  ? null
                  : _setEmailPreference,
              activeThumbColor: const Color(0xFF4A235A),
            ),
          ),
          if (loadingEmailPref || savingEmailPref)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          const Divider(),
          
          // Password Section
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
            child: Text(
              'Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: confirmNewPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: savingPassword ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A235A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Update Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
