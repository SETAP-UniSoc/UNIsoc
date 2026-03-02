import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:unisoc/home_page.dart';
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

  bool isLoading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> loginUser() async {
  final upNumber = upnumberController.text.trim();
  final password = passwordController.text;

  if (upNumber.isEmpty || password.isEmpty) {
    _showError("Please enter UP number and password");
    return;
  }

  if (upNumber.length != 7) {
    _showError("UP number must be 7 digits");
    return;
  }

  setState(() => isLoading = true);

  final url = Uri.parse("http://10.128.5.47:8000/api/user/login/");

  try {
    final response = await http
        .post(
          url,
          headers: {"Content-Type": "application/json", "Accept": "application/json"},
          body: jsonEncode({"up_number": upNumber, "password": password}),
        )
        .timeout(const Duration(seconds: 10)); // ✅ timeout added

    if (!mounted) return;

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful")),
      );
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
  } on http.ClientException catch (e) {
    _showError("Client error: $e");
  } on FormatException catch (e) {
    _showError("Response format error: $e");
  } on Exception catch (e) {
    _showError("Network error or timeout: $e");
  } finally {
    if (mounted) setState(() => isLoading = false); // ✅ stop loading indicator
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

            
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: loginUser,
                    child: const Text("Login"),
                  ),

            const SizedBox(height: 20),

            TextButton(
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

            TextButton(
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
          ],
        ),
      ),
    );
  }
}