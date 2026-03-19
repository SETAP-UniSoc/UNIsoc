import 'package:flutter/material.dart';
//import 'login_screen.user.dart';
//import 'login_screen.admin.dart';

//for now ser will enter their up number and if it mathces they can reset thier password
//user enters email and backend checks if it belongs to user or admin
// if admin it shon new password directly 
// if user then user enters their up number then shows the new password field

//forgotten password screen for both admin and user login screens 
class ForgottenPasswordScreen extends StatefulWidget {
  const ForgottenPasswordScreen({super.key});

  @override
  State<ForgottenPasswordScreen> createState() => _ForgottenPasswordScreenState();
}

class _ForgottenPasswordScreenState extends State<ForgottenPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  void resetPassword() {
    print(emailController.text);
  }

//email input field only with a verify button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter your email",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "email",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: resetPassword,
              child: const Text("Verify"),
            ),
            //back arrow to go to prevoius screen
            // Align(
            //   alignment: Alignment.bottomLeft,
            //   child: IconButton(
            //     icon: const Icon(Icons.arrow_back),
            //     onPressed: () {
            //       Navigator.pop(context);
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}