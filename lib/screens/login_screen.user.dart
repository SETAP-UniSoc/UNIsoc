import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:unisoc/screens/user/user_home_page.dart';
import 'login_screen.admin.dart';
import 'forgotten_password_screen.dart';
import 'signup_user_page.dart';
import 'package:unisoc/services/api_services.dart';

class LoginScreenUser extends StatefulWidget {
  const LoginScreenUser({super.key});

  @override
  State<LoginScreenUser> createState() => _LoginScreenUserState();
}

class _LoginScreenUserState extends State<LoginScreenUser> {
  final TextEditingController upnumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  // Minimal error display
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> loginUser() async {
    final upNumber = upnumberController.text.trim();
    final password = passwordController.text;

    if (upNumber.isEmpty || password.isEmpty) {
      _showError("Please enter all fields");
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse("${ApiService.baseUrl}/login/");

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"up_number": upNumber, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      print("HTTP Status: ${response.statusCode}, Body: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ApiService.authToken = responseData["token"];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else if (response.statusCode == 404) {
        _showError("UP number not found");
      } else if (response.statusCode == 401) {
        _showError("Incorrect password");
      } else {
        _showError("Login failed (${response.statusCode})");
      }
    } on TimeoutException {
      _showError("Login request timed out. Check server connection.");
      print("Error during login: request timed out after 10 seconds");
    } catch (e) {
      _showError("Network or server error");
      print("Error during login: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
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

            // UP Number
            TextField(
              controller: upnumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              decoration: const InputDecoration(
                labelText: "UP Number",
                prefixText: "UP",
                border: UnderlineInputBorder(),
              ),
            ),

            // Password
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // Forgot Password stays as TextButton
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgottenPasswordScreen(),
                  ),
                );
              },
              child: const Text("Forgot Password?"),
            ),
            const SizedBox(height: 10),

            // Login as ElevatedButton
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loginUser,
                      child: const Text("Login"),
                    ),
                  ),
            const SizedBox(height: 10),

            // Signup ElevatedButton
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
            const SizedBox(height: 10),

            // Admin ElevatedButton
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreenAdmin(),
                    ),
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
