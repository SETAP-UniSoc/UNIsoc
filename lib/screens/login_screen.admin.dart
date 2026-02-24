import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'forgotten_password_screen.dart';
import 'admin_signup_screen.dart';

class LoginScreenAdmin extends StatefulWidget {
  const LoginScreenAdmin({super.key});

  @override
  State<LoginScreenAdmin> createState() => _LoginScreenAdminState();
}



class _LoginScreenAdminState extends State<LoginScreenAdmin> {
  //final TextEditingController usernameController = TextEditingController();

  bool _isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginAdmin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final url = Uri.parse("http://192.168.1.105:8000/api/login/");
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json", "Accept": "application/json"},
    body: jsonEncode({"email": email, "password": password}),
  );
} 
    }  catch(e) {
      print("Error:$e");
    } 
    finally {
      if (mounted) setState (()=> _isLoading = false);
    }
  }
//        } else {
//       String message = 'Login failed: ${response.statusCode}';
//       try {
//         final err = jsonDecode(response.body);
//         if (err is Map && err['detail'] != null) {
//           message = err['detail'] as String;
//         }
//       } catch (_) {}
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Network error: $e')),
//     );
//   }
// }

      

 //   print("Response Status: ${response.statusCode}");
   // print("Response Body: ${response.body}");
  

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

            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: _isLoading ? null : loginAdmin,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Login"),
              ),
            ),
            const SizedBox(height: 20),


            // Align(
            //   alignment: Alignment.bottomLeft,
            //   child: IconButton(
            //     icon: const Icon(Icons.arrow_back),
            //     onPressed: () {
            //       Navigator.pop(context);

            //     },

            //   ),
            // ),
          //adding a sign up button
            Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminSignupScreen()),
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
  