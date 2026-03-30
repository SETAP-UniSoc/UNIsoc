import 'package:flutter/material.dart';
import 'package:unisoc/screens/society_profile_page.dart';
import 'package:unisoc/services/api_services.dart';
import 'package:unisoc/screens/login_screen.user.dart';
import 'package:unisoc/screens/admin/admin_settings_page.dart';

class AdminDropdownMenu extends StatelessWidget {
  const AdminDropdownMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case "society":
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
          case "myaccount":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminSettingsPage()),
            );
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
        PopupMenuItem(value: "society", child: Text("My Society")),
        PopupMenuItem(value: "myaccount", child: Text("My Account")),
        PopupMenuItem(value: "logout", child: Text("Logout")),
      ],
    );
  }
}