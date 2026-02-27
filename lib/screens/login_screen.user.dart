import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'login_screen.admin.dart';
import 'forgotten_password_screen.dart';
import 'signup_user_page.dart';
//kfnd


class LoginScreenUser extends StatefulWidget {
  const LoginScreenUser({super.key});

  @override
  State<LoginScreenUser> createState() => _LoginScreenUserState();
}

class _LoginScreenUserState extends State<LoginScreenUser> {
  final TextEditingController upnumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
   
    final up_number = upnumberController.text; 
    final password = passwordController.text;

    final url = Uri.parse("http://10.128.5.47:8000/api/user/login/");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json", "Accept": "application/json"},
    body: jsonEncode({"up_number": up_number, "password": password}),
  );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    
    print(upnumberController.text);
    print(passwordController.text);
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

        
// making it direct to blank page for now but will change it to user homepage late
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreenAdmin()),
                  );
                },
                child: const Text("Login"),
              ),
            ),
            const SizedBox(height: 20),
          //Row(
           // mainAxisAlignment: MainAxisAlignment.bottomLeft,
            //children: [


              Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
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


              Align(
                alignment: Alignment.bottomLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreenAdmin()),
                  );
                },
                child: const Text("Admin"),
              ),
            ),
            
            //adding a button bottom left to go to signup page
            
              ],
            ),
         // ],
        ),
    //  ),
    );
  }
}