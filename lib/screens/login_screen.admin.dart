// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:unisoc/screens/admin/admin_hompage.dart';
// import 'forgotten_password_screen.dart';
// import 'signup_user_page.dart';

// class LoginScreenAdmin extends StatefulWidget {
//   const LoginScreenAdmin({super.key});

//   @override
//   State<LoginScreenAdmin> createState() => _LoginScreenAdminState();
// }

// class _LoginScreenAdminState extends State<LoginScreenAdmin> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   bool isLoading = false;

//   Future<void> loginUser() async {
//     final name = nameController.text.trim(); 
//     final email = emailController.text.trim();
//     final password = passwordController.text;

//     if (email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("All fields are required")),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     final url = Uri.parse("http://10.128.4.196:8000/api/login/");

//     final body = {
//       "name": name, // backend ignores this
//       "email": email,
//       "password": password,
//     };

//     print("Sending POST to $url");
//     print("Body: ${jsonEncode(body)}");

//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );

//       print("Status Code: ${response.statusCode}");
//       print("Response Body: ${response.body}");

//       if (!mounted) return;

//       final responseData = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const AdminHomepage()),
//         );
//       } else if (response.statusCode == 401) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Invalid credentials")),
//         );
//       } else if (response.statusCode == 400) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(responseData["error"] ?? "Bad request")),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error ${response.statusCode}")),
//         );
//       }
//     } catch (e) {
//       print("Network Error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Network error")),
//       );
//     }

//     setState(() => isLoading = false);
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Admin Login")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               "Login",
//               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 30),

//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 labelText: "Society Name",
//                 border: UnderlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),

//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(
//                 labelText: "Email",
//                 border: UnderlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),

//             TextField(
//               controller: passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: "Password",
//                 border: UnderlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 30),

//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const ForgottenPasswordScreen(),
//                   ),
//                 );
//               },
//               child: const Text("Forgot Password?"),
//             ),
//             const SizedBox(height: 10),

//             isLoading
//                 ? const CircularProgressIndicator()
//                 : SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: loginUser,
//                       child: const Text("Login"),
//                     ),
//                   ),
//             const SizedBox(height: 10),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const SignupUserPage(),
//                     ),
//                   );
//                 },
//                 child: const Text("Signup"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unisoc/screens/admin/admin_hompage.dart';
//import 'package:unisoc/screens/admin/admin_hompage.dart';
import 'forgotten_password_screen.dart';
import 'signup_user_page.dart';
import 'package:unisoc/services/api_services.dart'; 

class LoginScreenAdmin extends StatefulWidget {
  const LoginScreenAdmin({super.key});

  @override
  State<LoginScreenAdmin> createState() => _LoginScreenAdminState();
}

class _LoginScreenAdminState extends State<LoginScreenAdmin> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> loginUser() async {
    FocusScope.of(context).unfocus(); // close keyboard

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    // ✅ Basic frontend validation only
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and Password are required")),
      );
      return;
    }

    if (!email.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid email address")),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse("http://10.128.4.122:8000/api/login/");

    final body = {
      "name": name, // backend ignores this (kept as requested)
      "email": email,
      "password": password,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            //chnaging  page it goes to as error wih adminhomepage
            builder: (context) => const AdminHomepage(),
          ),
        );
      } else if (response.statusCode == 401) {
        // ✅ Generic message (backend unchanged)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid email or password"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed (${response.statusCode})"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to connect to server"),
        ),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
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
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
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
                      builder: (context) =>
                          const ForgottenPasswordScreen(),
                    ),
                  );
                },
                child: const Text("Forgot Password?"),
              ),

              const SizedBox(height: 10),

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
            ],
          ),
        ),
      ),
    );
  }
}
