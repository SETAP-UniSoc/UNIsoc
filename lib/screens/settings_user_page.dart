import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool emailUpdates = true;

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
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive event and society notifications'),
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
              activeThumbColor: const Color(0xFF4A235A),
            ),
          ),
          ListTile(
            title: const Text('Email Updates'),
            subtitle: const Text('Receive email notifications'),
            trailing: Switch(
              value: emailUpdates,
              onChanged: (value) {
                setState(() {
                  emailUpdates = value;
                });
              },
              activeThumbColor: const Color(0xFF4A235A),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
