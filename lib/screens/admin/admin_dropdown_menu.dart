import 'package:flutter/material.dart';

class AdminDropdownMenu extends StatelessWidget {
  const AdminDropdownMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case "account":
            // Navigate to My Account page later
            break;
          case "settings":
            // Navigate to Settings page later
            break;
          case "logout":
            // Handle logout later
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: "account",
          child: Text("My Account"),
        ),
        PopupMenuItem(
          value: "settings",
          child: Text("Settings"),
        ),
        PopupMenuItem(
          value: "logout",
          child: Text("Logout"),
        ),
      ],
    );
  }
}