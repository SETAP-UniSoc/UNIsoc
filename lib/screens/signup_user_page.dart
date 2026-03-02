import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.user.dart';

class SignupUserPage extends StatefulWidget {
  const SignupUserPage({super.key});

  @override
  State<SignupUserPage> createState() => _SignupUserPageState();
}

class _SignupUserPageState extends State<SignupUserPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController upnumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _validateFields() {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final upnumberDigits = upnumberController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        upnumberDigits.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError("Please fill in all fields");
      return false;
    }

    if (!RegExp(r'^\d{7}$').hasMatch(upnumberDigits)) {
      _showError("UP number must be exactly 7 digits");
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showError("Enter a valid email address");
      return false;
    }

    if (password != confirmPassword) {
      _showError("Passwords do not match");
      return false;
    }

    if (password.length < 8) {
      _showError("Password must be at least 8 characters");
      return false;
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      _showError("Password must contain one uppercase letter");
      return false;
    }

    if (!RegExp(r'\d').hasMatch(password)) {
      _showError("Password must contain one number");
      return false;
    }

    if (!RegExp(r'[^\w\s]').hasMatch(password)) {
      _showError("Password must contain one special character");
      return false;
    }

    return true;
  }

  Future<void> signupUser() async {
    if (!_validateFields()) return;

    setState(() => isLoading = true);

    final upnumber = "UP${upnumberController.text.trim()}";

    final url =
        Uri.parse("http://10.128.5.47:8000/api/user/register/");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode({
          "first_name": firstNameController.text.trim(),
          "last_name": lastNameController.text.trim(),
          "up_number": upnumber,
          "email": emailController.text.trim(),
          "password": passwordController.text,
          "confirm_password": confirmPasswordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup successful")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const LoginScreenUser()),
        );
      } else {
        String errorMessage =
            "Signup failed (${response.statusCode})";

        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);
            if (data is Map<String, dynamic>) {
              errorMessage =
                  data['error'] ??
                  data['message'] ??
                  data['detail'] ??
                  errorMessage;
            }
          } catch (_) {}
        }

        _showError(errorMessage);
      }
    } catch (e) {
      _showError("Network error: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("User Signup")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Signup",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              _buildField(firstNameController, "First Name"),
              _buildField(lastNameController, "Last Name"),

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

              _buildField(emailController, "Email"),

              _buildField(passwordController, "Password",
                  obscure: true),

              _buildField(confirmPasswordController,
                  "Confirm Password",
                  obscure: true),

              const SizedBox(height: 30),

              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: signupUser,
                      child: const Text("Signup"),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller,
      String label,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }
}