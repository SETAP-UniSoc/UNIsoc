import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SignupUserPage extends StatefulWidget {
  const SignupUserPage({super.key});

  @override
  State<SignupUserPage> createState() => _SignupUserPageState();
}

class _SignupUserPageState extends State<SignupUserPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> signupUser() async {
    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;

    final url = Uri.parse("http://127.0.0.1:8000/api/user/signup");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json", "Accept": "application/json"},
    body: jsonEncode({"name": name, "email": email, "password": password}),
  );
  
    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");


    print(nameController.text);
    print(emailController.text);
    print(passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Signup")), //theres an automaticly generated back arrow 
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
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "UP number",
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

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "confirm password",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: signupUser,
              child: const Text("Signup"),
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