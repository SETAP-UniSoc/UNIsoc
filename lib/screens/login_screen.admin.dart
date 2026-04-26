// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:unisoc/screens/admin/admin_hompage.dart';
// //import 'package:unisoc/screens/admin/admin_hompage.dart';
// import 'forgotten_password_screen.dart';
// import 'signup_user_page.dart';
// import 'package:unisoc/services/api_services.dart'; 

// class LoginScreenAdmin extends StatefulWidget {
//   const LoginScreenAdmin({super.key});

//   @override
//   State<LoginScreenAdmin> createState() => _LoginScreenAdminState();
// }

// class _LoginScreenAdminState extends State<LoginScreenAdmin> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   List societies = [];
//   String? selectedSociety;

//   bool isLoading = false;

//   Future<void> loginUser() async {
//     FocusScope.of(context).unfocus(); // close keyboard

//     final name = nameController.text.trim();
//     final email = emailController.text.trim();
//     final password = passwordController.text;

  
//     if (email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Email and Password are required")),
//       );
//       return;
//     }

//     if (!email.contains("@")) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter a valid email address")),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     final url = Uri.parse("http://192.168.1.125:8000/api/api/login/");

//     final body = {
//       "name": name, // backend ignores this (kept as requested)
//       "email": email,
//       "password": password,
//     };

//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//   final responseData = jsonDecode(response.body);

//   print("Full response: $responseData");
//   print("Society ID: ${responseData['society_id']}");

//   ApiService.authToken = responseData["token"];
//   ApiService.societyId = responseData["society_id"];
//   ApiService.societyName = responseData["society_name"];

//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(
//       builder: (context) => const AdminHomepage(),
//     ),
//   );
// }else if (response.statusCode == 401) {
//         // backend is unchanged
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Invalid email or password"),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Login failed (${response.statusCode})"),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Unable to connect to server"),
//         ),
      
//       );
//     }

//     if (mounted) {
//       setState(() => isLoading = false);
//     }
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
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 60),

//               const Text(
//                 "Login",
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 30),

//               TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   labelText: "Society Name",
//                   border: UnderlineInputBorder(),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               TextField(
//                 controller: emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(
//                   labelText: "Email",
//                   border: UnderlineInputBorder(),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               TextField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                   labelText: "Password",
//                   border: UnderlineInputBorder(),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           const ForgottenPasswordScreen(),
//                     ),
//                   );
//                 },
//                 child: const Text("Forgot Password?"),
//               ),

//               const SizedBox(height: 10),

//               isLoading
//                   ? const CircularProgressIndicator()
//                   : SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: loginUser,
//                         child: const Text("Login"),
//                       ),
//                     ),

//               const SizedBox(height: 10),

//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const SignupUserPage(),
//                       ),
//                     );
//                   },
//                   child: const Text("Signup"),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }






























import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unisoc/screens/admin/admin_hompage.dart';
import 'forgotten_password_screen.dart';
import 'signup_user_page.dart';
import 'package:unisoc/services/api_services.dart'; 

class LoginScreenAdmin extends StatefulWidget {
  const LoginScreenAdmin({super.key});

  @override
  State<LoginScreenAdmin> createState() => _LoginScreenAdminState();
}

class _LoginScreenAdminState extends State<LoginScreenAdmin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  List<Map<String, dynamic>> societies = [];
  String? selectedSocietyId;
  String? selectedSocietyName;
  bool isLoadingSocieties = true;
  bool isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _fetchSocieties();
  }

  Future<void> _fetchSocieties() async {
    setState(() => isLoadingSocieties = true);
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/societies/"),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          societies = data.map((s) => {
            "id": s["id"],
            "name": s["name"],
          }).toList();
          isLoadingSocieties = false;
        });
      } else {
        throw Exception("Failed to load societies");
      }
    } catch (e) {
      print("Error fetching societies: $e");
      setState(() => isLoadingSocieties = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not load societies. Please try again.")),
      );
    }
  }

  Future<void> loginUser() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();
    final password = passwordController.text;

    // Validation
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
    if (selectedSocietyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a society")),
      );
      return;
    }

    setState(() => isLoggingIn = true);

    final url = Uri.parse("${ApiService.baseUrl}/login/");
    final body = {
      "email": email,
      "password": password,
      "society_id": selectedSocietyId, // Optional: send selected society ID
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print("Full response: $responseData");
        print("Society ID: ${responseData['society_id']}");

        // Optional: Verify selected society matches backend
        if (responseData['society_id'] != null &&
            responseData['society_id'].toString() != selectedSocietyId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Selected society does not match your admin assignment")),
          );
          setState(() => isLoggingIn = false);
          return;
        }

        ApiService.authToken = responseData["token"];
        ApiService.societyId = responseData["society_id"];
        ApiService.societyName = responseData["society_name"] ?? selectedSocietyName;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminHomepage(),
          ),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed (${response.statusCode})")),
        );
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login request timed out. Check server connection"),
        ),
      );
    } catch (e) {
      print("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to connect to server")),
      );
    } finally {
      if (mounted) setState(() => isLoggingIn = false);
    }
  }

  @override
  void dispose() {
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Society Dropdown
              if (isLoadingSocieties)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                )
              else
                DropdownButtonFormField<String>(
                  value: selectedSocietyId,
                  decoration: const InputDecoration(
                    labelText: "Select your society",
                    border: OutlineInputBorder(),
                  ),
                  items: societies.map((society) {
                    return DropdownMenuItem<String>(
                      value: society["id"].toString(),
                      child: Text(society["name"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSocietyId = value;
                      final society = societies.firstWhere((s) => s["id"].toString() == value);
                      selectedSocietyName = society["name"];
                    });
                  },
                  validator: (value) => value == null ? "Please select a society" : null,
                ),

              const SizedBox(height: 20),

              // Email field
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Password field
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

              isLoggingIn
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





























// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:unisoc/screens/admin/admin_hompage.dart';
// import 'forgotten_password_screen.dart';
// import 'signup_user_page.dart';
// import 'package:unisoc/services/api_services.dart'; 

// class LoginScreenAdmin extends StatefulWidget {
//   const LoginScreenAdmin({super.key});

//   @override
//   State<LoginScreenAdmin> createState() => _LoginScreenAdminState();
// }

// class _LoginScreenAdminState extends State<LoginScreenAdmin> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   List<Map<String, dynamic>> societies = [];
//   String? selectedSocietyId;
//   String? selectedSocietyName;
//   bool isLoadingSocieties = true;
//   bool isLoggingIn = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSocieties();
//   }

//   Future<void> _fetchSocieties() async {
//     setState(() => isLoadingSocieties = true);
//     try {
//       // No authentication needed now
//       final response = await http.get(
//         Uri.parse("${ApiService.baseUrl}/societies/"),
//         headers: {"Content-Type": "application/json"}, // No token needed
//       );
      
//       print("📡 Societies response: ${response.statusCode}");
//       print("📡 Societies body: ${response.body}");
      
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           societies = data.map((s) => {
//             "id": s["id"],
//             "name": s["name"],
//           }).toList();
//           isLoadingSocieties = false;
//         });
//       } else {
//         throw Exception("Failed to load societies: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching societies: $e");
//       setState(() => isLoadingSocieties = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Could not load societies. Please try again.")),
//       );
//     }
//   }

//   Future<void> loginUser() async {
//     FocusScope.of(context).unfocus();

//     final email = emailController.text.trim();
//     final password = passwordController.text;

//     // Validation
//     if (email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Email and Password are required")),
//       );
//       return;
//     }
//     if (!email.contains("@")) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter a valid email address")),
//       );
//       return;
//     }
//     if (selectedSocietyId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select a society")),
//       );
//       return;
//     }

//     setState(() => isLoggingIn = true);

//     final url = Uri.parse("${ApiService.baseUrl}/login/");
//     final body = {
//       "email": email,
//       "password": password,
//     };

//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       ).timeout(const Duration(seconds: 10));

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);

//         print("Full response: $responseData");
//         print("Society ID from backend: ${responseData['society_id']}");

//         // Verify selected society matches backend
//         final backendSocietyId = responseData['society_id']?.toString();
//         if (backendSocietyId != null && backendSocietyId != selectedSocietyId) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Selected society does not match your admin assignment")),
//           );
//           setState(() => isLoggingIn = false);
//           return;
//         }

//         ApiService.authToken = responseData["token"];
//         ApiService.societyId = responseData["society_id"];
//         ApiService.societyName = responseData["society_name"] ?? selectedSocietyName;

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const AdminHomepage(),
//           ),
//         );
//       } else if (response.statusCode == 401) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Invalid email or password")),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Login failed (${response.statusCode})")),
//         );
//       }
//     } catch (e) {
//       print("Login error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Unable to connect to server")),
//       );
//     } finally {
//       if (mounted) setState(() => isLoggingIn = false);
//     }
//   }

//   @override
//   void dispose() {
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
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 60),
//               const Text(
//                 "Login",
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 30),

//               // Society Dropdown
//               if (isLoadingSocieties)
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 20),
//                   child: CircularProgressIndicator(),
//                 )
//               else if (societies.isEmpty)
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 20),
//                   child: Text("No societies found"),
//                 )
//               else
//                 DropdownButtonFormField<String>(
//                   value: selectedSocietyId,
//                   decoration: const InputDecoration(
//                     labelText: "Select your society",
//                     border: OutlineInputBorder(),
//                   ),
//                   items: societies.map((society) {
//                     return DropdownMenuItem<String>(
//                       value: society["id"].toString(),
//                       child: Text(society["name"]),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedSocietyId = value;
//                       final society = societies.firstWhere((s) => s["id"].toString() == value);
//                       selectedSocietyName = society["name"];
//                     });
//                   },
//                 ),

//               const SizedBox(height: 20),

//               // Email field
//               TextField(
//                 controller: emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(
//                   labelText: "Email",
//                   border: UnderlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Password field
//               TextField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(
//                   labelText: "Password",
//                   border: UnderlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 30),

//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const ForgottenPasswordScreen(),
//                     ),
//                   );
//                 },
//                 child: const Text("Forgot Password?"),
//               ),
//               const SizedBox(height: 10),

//               isLoggingIn
//                   ? const CircularProgressIndicator()
//                   : SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: loginUser,
//                         child: const Text("Login"),
//                       ),
//                     ),
//               const SizedBox(height: 10),

//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const SignupUserPage(),
//                       ),
//                     );
//                   },
//                   child: const Text("Signup"),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }