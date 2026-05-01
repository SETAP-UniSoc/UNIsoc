import 'package:flutter/material.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({Key? key}) : super(key: key);

  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _savePassword() {
    final current = _currentPasswordController.text;
    final next = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (next.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a new password.')));
      return;
    }
    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    // TODO: wire up password change logic with backend/auth service.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password change requested.')));
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Password'),
            TextField(controller: _currentPasswordController, obscureText: true),
            const SizedBox(height: 12),
            const Text('New Password'),
            TextField(controller: _newPasswordController, obscureText: true),
            const SizedBox(height: 12),
            const Text('Confirm New Password'),
            TextField(controller: _confirmPasswordController, obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _savePassword, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
