import 'package:flutter/material.dart';
import 'package:unisoc/screens/admin/admin_my_account_page.dart';

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
                builder: (_) => const AdminMyAccountPage(),
              ),
            );
            break;
          case "settings":
            // settings page later
            break;
          case "logout":
            // logout later
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