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

  Future<void> loginAdmin() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all fields")),
      );
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['token'] as String;
        final role = data['role'] as String? ?? 'admin';

     Navigator.pushReplacement(
    context, 
    MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text("Admin Login Success")),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text("Admin login successful!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text("Token: $token", style: const TextStyle(fontSize: 14, fontFamily: 'monospace')),
              Text("Role: $role"),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text("Back to Login"),
              ),
            ],
          ),
        ),
      ),
    ),
  );
} 
    }  catch(e) {
      print("Error:$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
      
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
//should go to admin homepage when login sbutton is pressed and the login is successful, otherwise show a snackbar with the error message
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminHomepage()),
                    );
                  },
                  child: const Text("Login"),
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
  