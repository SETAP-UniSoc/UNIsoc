import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:unisoc/screens/admin/admin_hompage.dart';
import 'forgotten_password_screen.dart';
import 'login_screen.user.dart';

class LoginScreenAdmin extends StatefulWidget {
  const LoginScreenAdmin({super.key});

  @override
  State<LoginScreenAdmin> createState() => _LoginScreenAdminState();
}

//adding error handleing for the name email and password fields

class _LoginScreenAdminState extends State<LoginScreenAdmin> {
  //final TextEditingController usernameController = TextEditingController();

  bool _isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> loginAdmin() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError("Please enter all fields");
      return;
    }

    if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email)) {
      _showError("Please enter a valid email address");
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse("http://10.128.5.47:8000/api/login/");
//http://10.0.2.2:8000/api/login/
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

    //if name is not in database show error message
      
      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomepage()),
        );
        return;
      }

      if (response.statusCode == 401) {
        _showError("Invalid credentials");
        return;
      }

      if (response.statusCode == 404) {
        _showError("Admin account not found");
        return;
      }

      String errorMessage = "Login failed (${response.statusCode})";
      try {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final serverMessage = data['error'] ?? data['message'] ?? data['detail'];
          if (serverMessage is String && serverMessage.isNotEmpty) {
            errorMessage = serverMessage;
          }
        }
      } catch (_) {}
      _showError(errorMessage);
    }  catch(e) {
      print("Error:$e");
      _showError('Network error: $e');
      
    } 
    finally {
      if (mounted) setState (()=> _isLoading = false);
    }
    // error handeling for email 
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Login"), //putting back the arrow back to the login screen
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
              controller:nameController,
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
                    MaterialPageRoute(builder: (context) => const ForgottenPasswordScreen()),
                  );
                },
                child: const Text("Forgot Password?"),
              ),
            ),
//should go to admin homepage when login button is pressed and the login is successful, otherwise show a snackbar with the error message
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: _isLoading ? null : loginAdmin,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
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
                      MaterialPageRoute(builder: (context) => const LoginScreenUser()),
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
  