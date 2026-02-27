import 'package:flutter/material.dart';

// A reusable navbar for the logged-in home page
class HomeNavbar extends StatelessWidget implements PreferredSizeWidget {
  const HomeNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Home'),
      actions: [
        PopupMenuButton<_MenuAction>(
          icon: const Icon(Icons.account_circle),
          onSelected: (action) {
            switch (action) {
              case _MenuAction.myEvents:
                break;
              case _MenuAction.mySocs:
                ;
                break;
              case _MenuAction.settings:
                break;
              case _MenuAction.myAccount:
                break;
              case _MenuAction.logout:
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: _MenuAction.myEvents,
              child: Text('My Events'),
            ),
            const PopupMenuItem(
              value: _MenuAction.mySocs,
              child: Text('MySocs'),
            ),
            const PopupMenuItem(
              value: _MenuAction.settings,
              child: Text('Settings'),
            ),
            const PopupMenuItem(
              value: _MenuAction.myAccount,
              child: Text('My Account'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: _MenuAction.logout,
              child: Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }
}

enum _MenuAction { myEvents, mySocs, settings, myAccount, logout }


// ...existing code...
/* import 'package:flutter/material.dart';
import 'navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeNavbar(),
      body: const Center(
        child: Text('Home content here'),
      ),
    );
  }
} */
// ...existing code...