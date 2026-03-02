import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:unisoc/screens/home_page.dart';
import 'login_screen.admin.dart';
import 'forgotten_password_screen.dart';
import 'signup_user_page.dart';

class LoginScreenUser extends StatefulWidget {
  const LoginScreenUser({super.key});

  @override
  State<LoginScreenUser> createState() => _LoginScreenUserState();
}

class _LoginScreenUserState extends State<LoginScreenUser> {
  final TextEditingController upnumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
    final upNumber = upnumberController.text.trim();
    final password = passwordController.text;

    if (upNumber.length != 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("UP number must be 7 digits")),
      );
      return;
    }

    final url = Uri.parse("http://10.128.5.47:8000/api/user/login/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"up_number": upNumber, "password": password}),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("UP number not found")),
        );
        return;
      }

      if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect password")),
        );
        return;
      }

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful")),
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed (${response.statusCode})")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Login",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: upnumberController,
              decoration: const InputDecoration(
                labelText: "UP number",
                prefixText: "UP",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgottenPasswordScreen()),
                  );
                },
                child: const Text("Forgot Password?"),
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: loginUser,
                child: const Text("Login"),
              ),
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupUserPage(),
                    ),
                  );
                },
                child: const Text("Signup"),
              ),
            ),

            Align(
              alignment: Alignment.bottomLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreenAdmin()),
                    );
                  },
                  child: const Text("Admin"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
