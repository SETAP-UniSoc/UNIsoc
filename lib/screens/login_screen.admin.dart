import 'package:flutter/material.dart';

class LoginScreenAdmin extends StatefulWidget {
  const LoginScreenAdmin({super.key});

  @override
  State<LoginScreenAdmin> createState() => _LoginScreenAdminState();
}


class _LoginScreenAdminState extends State<LoginScreenAdmin> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void loginAdmin() {
    print(usernameController.text);
    print(emailController.text);
    print(passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
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

            Image.asset(
              "assets/images/logo.png", 
              height: 120,
              ),
              const SizedBox(height: 20),

            // TextField(
            //   controller: usernameController,
            //   decoration: const InputDecoration(
            //     labelText: "name",
            //     border: UnderlineInputBorder(),
            //   ),
            // ),
            // const SizedBox(height: 20),