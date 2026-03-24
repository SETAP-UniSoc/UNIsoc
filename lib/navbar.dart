import 'package:flutter/material.dart';
import 'screens/settings_user_page.dart';
import 'screens/my_account_page.dart';
import 'screens/my_events_page.dart';
import 'screens/user_mysoc_page.dart';
import 'screens/login_screen.user.dart';

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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyEventsPage()),
                );
                break;
              case _MenuAction.mySocs:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MySocietyPage(),
                  ),
                );
                break;
              case _MenuAction.settings:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
                break;
              case _MenuAction.myAccount:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyAccountPage(),
                  ),
                );
                break;
              case _MenuAction.logout:
                // TODO: implement logout
                // For now: return to login screen and clear navigation stack
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreenUser(),
                  ),
                  (route) => false,
                );
                break;
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _MenuAction.myEvents,
              child: Text('My Events'),
            ),
            PopupMenuItem(value: _MenuAction.mySocs, child: Text('MySocs')),
            PopupMenuItem(value: _MenuAction.settings, child: Text('Settings')),
            PopupMenuItem(
              value: _MenuAction.myAccount,
              child: Text('My Account'),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
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

/// Header section that shows the navbar and a greeting.
/// [studentName] will later be replaced with the actual logged-in user's name.
class HomeHeader extends StatelessWidget {
  final String studentName;

  const HomeHeader({
    super.key,
    this.studentName = 'Student', // later pass the real name
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const HomeNavbar(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UniSoc',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome $studentName',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search events or societies',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                ),
                onChanged: (value) {
                  // TODO: hook up search logic later
                  // print(value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}


/*  Future<void> loginUser() async {
    final up_number = upnumberController.text;
    final password = passwordController.text;

    final url = Uri.parse("http://10.128.5.47:8000/api/user/login/");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"up_number": up_number, "password": password}),
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    print(upnumberController.text);
    print(passwordController.text); */