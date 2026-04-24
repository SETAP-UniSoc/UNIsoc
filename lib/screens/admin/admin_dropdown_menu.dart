import 'package:flutter/material.dart';

class AdminDropdownMenu extends StatelessWidget {
  const AdminDropdownMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'account':
            showDialog<void>(
              context: context,
              builder: (_) => const AlertDialog(
                title: Text('My Account'),
                content: Text('Account details coming soon.'),
              ),
            );
            break;
          case 'settings':
            showDialog<void>(
              context: context,
              builder: (_) => const AlertDialog(
                title: Text('Settings'),
                content: Text('Settings page coming soon.'),
              ),
            );
            break;
          case 'logout':
            showDialog<void>(
              context: context,
              builder: (_) => const AlertDialog(
                title: Text('Logout'),
                content: Text('Logout is not wired up yet.'),
              ),
            );
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'account', child: Text('My Account')),
        PopupMenuItem(value: 'settings', child: Text('Settings')),
        PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
    );
  }
}
