import 'package:flutter/material.dart';
import 'package:unisoc/screens/society_profile_page.dart';
import 'package:unisoc/services/api_services.dart';
import 'package:unisoc/screens/login_screen.user.dart';

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
            break;
          case "logout":
            // clear all saved admin data
            ApiService.authToken = null;
            ApiService.societyId = null;
            ApiService.societyName = null;
            // navigate back to user login and clear entire navigation stack
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreenUser()),
              (route) => false,
            );
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