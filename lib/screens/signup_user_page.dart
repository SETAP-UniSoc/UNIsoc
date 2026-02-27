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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> signupUser() async {
    final firstName = firstNameController.text;
    final lastName = lastNameController.text;
    final upnumberDigits = upnumberController.text.trim();
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (upnumberDigits.length != 7) {
      _showError("UP number must be 7 digits");
      return;
    }

    final upnumber = 'UP$upnumberDigits';

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    if (firstName.isEmpty || lastName.isEmpty || upnumber.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

  //password validation checks password is at least 8 characters at least one  specicial character , a number , one uppercase letter
    // Password must be at least 8 characters
if (password.length < 8) {
  _showError("Password must be at least 8 characters long");
  return;
}

// Must contain uppercase letter
if (!RegExp(r'[A-Z]').hasMatch(password)) {
  _showError("Password must contain at least one uppercase letter");
  return;
}

// Must contain number
if (!RegExp(r'\d').hasMatch(password)) {
  _showError("Password must contain at least one number");
  return;
}

// Must contain special character
if (!RegExp(r'[@$!%*?&]').hasMatch(password)) {
  _showError("Password must contain at least one special character");
  return;
}
    final url = Uri.parse("http://10.128.5.47:8000/api/user/register/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"first_name": firstNameController.text,"last_name": lastNameController.text, "up_number": upnumber, "email": email, "password": password, "confirm_password": confirmPassword}),
      );

      if (!mounted) return;

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
//adding a first and last name field to the signup page and printing them to the console to check if they are being sent to the backend correctly
      print(firstNameController.text);
      print(lastNameController.text);
      print(upnumberController.text);
      print(emailController.text);
      print(passwordController.text);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);
            if (data is Map<String, dynamic>) {
              final token = data['token'] as String?;
              final role = data['role'] as String? ?? 'user';
              print("Token: $token");
              print("Role: $role");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Signup successful ($role)')),
              );
            }
          } catch (_) {}
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreenUser()),
        );
        return;
      }

      String errorMessage = 'Signup failed (${response.statusCode})';
      if (response.body.isNotEmpty) {
        try {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            final serverMessage = data['error'] ?? data['message'] ?? data['detail'];
            if (serverMessage is String && serverMessage.isNotEmpty) {
              errorMessage = serverMessage;
            }
          }
        } catch (_) {}
      }
      _showError(errorMessage);
    } catch (e) {
      if (!mounted) return;
      _showError('Network error: $e');
    }
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
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: "First Name",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: "Last Name",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: upnumberController,
              keyboardType: TextInputType.number,
              inputFormatters:[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              decoration: const InputDecoration(
                labelText: "UP number",
                prefixText: "UP",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            //email input that checks email format and shows error message if email is not valid
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "email",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "password",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "confirm password",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

//sign up button goes back to login screen user page 
            ElevatedButton(
              onPressed: signupUser,
              child: const Text("Signup"),
            ),
          ],
        ),  
      ),
    );
  }
}

// class BlankPage extends StatelessWidget {
//   const BlankPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: SizedBox.expand(),
//     );
//   }
// }