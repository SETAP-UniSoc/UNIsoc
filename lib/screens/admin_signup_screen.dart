import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
//import 'login_screen.admin.dart';




class AdminSignupScreen extends StatefulWidget {
  const AdminSignupScreen({super.key});

  @override
  State<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends State<AdminSignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();



  Future<void> signupAdmin() async {

    final username = usernameController.text;
    final email = emailController.text;
    final password = passwordController.text;

    final url = Uri.parse("http://127.0.0.1:8000/api/admin/signup");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json", "Accept": "application/json"},
    body: jsonEncode({"name": username, "email": email, "password": password}),
  );
  
    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");


    print(usernameController.text);
    print(emailController.text);
    print(passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Signup")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Signup",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "name",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "email",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "password",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: signupAdmin,
              child: const Text("Signup"),
            ),  
          ],
        ),
      ),
    );
  }
}
//admin page created
