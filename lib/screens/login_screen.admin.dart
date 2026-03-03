import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unisoc/screens/admin/admin_hompage.dart';
import 'forgotten_password_screen.dart';
import 'login_screen.user.dart';

class LoginScreenAdmin extends StatefulWidget {
  const LoginScreenAdmin({super.key});

  @override
  State<LoginScreenAdmin> createState() => _LoginScreenAdminState();
}

class _LoginScreenAdminState extends State<LoginScreenAdmin> {
  bool _isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginAdmin() async {
  
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  // Check empty fields first
  // if (name.isEmpty) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Society name is required")),
  //   );
  //   return;
  // }
  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email is required")),
    );
    return;
  }
  if (password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password is required")),
    );
    return;
  }

  setState(() => _isLoading = true);

  final url = Uri.parse("http://10.128.4.254:8000/api/login/");

  try {
    final response = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode({
            "name": nameController.text.trim(),
            "email": email,
            "password": password,
          }),
        )
        .timeout(const Duration(seconds: 5));

    if (!mounted) return;

    // Assume backend returns JSON like:
    // { "success": false, "errors": { "name": "Invalid", "email": "Not found", "password": "Incorrect" } }
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      // Successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomepage()),
      );
    } else {
      // Field-level errors
      final errors = responseData['errors'] as Map<String, dynamic>?;

      if (errors != null) {
        if (errors.containsKey('name')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Name Error: ${errors['name']}")),
          );
        } else if (errors.containsKey('email')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Email Error: ${errors['email']}")),
          );
        } else if (errors.containsKey('password')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Password Error: ${errors['password']}")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login failed")),
          );
        }
      } else {
        // Fallback generic error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${response.statusCode}")),
        );
      }
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network error: $e")),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Login"),
      ),
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
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Society Name",
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
            Align(
              alignment: Alignment.center,
              child: TextButton(
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
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: _isLoading ? null : loginAdmin,
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Login"),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreenUser(),
                    ),
                  );
                },
                child: const Text("Sign up"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}