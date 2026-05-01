import 'package:flutter/material.dart';
import 'package:unisoc/screens/user/settings_user_page.dart';
import 'package:unisoc/user_profile_state.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  late TextEditingController _firstNameController;
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: UserProfileState.firstName.value);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('First Name'),
            TextField(controller: _firstNameController),
            const SizedBox(height: 8),
            const Text('Last Name'),
            TextField(controller: _lastNameController),
            const SizedBox(height: 8),
            const Text('Email Address'),
            TextField(controller: _emailController),
            const SizedBox(height: 8),
            const Text('Current Password'),
            TextField(controller: _currentPasswordController, obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserSettingsPage()),
                );
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
