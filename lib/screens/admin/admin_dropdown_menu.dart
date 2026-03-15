import 'package:flutter/material.dart';
import 'package:unisoc/screens/society_profile_page.dart';
import 'package:unisoc/services/api_services.dart';

class AdminDropdownMenu extends StatelessWidget {
  const AdminDropdownMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case "account":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SocietyProfilePage(
                  societyId: ApiService.societyId ?? 0,
                  isAdmin: true,
                ),
              ),
            );
            break;
          case "settings":
            // settings page later
            break;
          case "logout":
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: "account", child: Text("My Account")),
        PopupMenuItem(value: "settings", child: Text("Settings")),
        PopupMenuItem(value: "logout", child: Text("Logout")),
      ],
    );
  }
}