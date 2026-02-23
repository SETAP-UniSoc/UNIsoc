import 'package:flutter/material.dart';

class LoginScreenUser extends StatefulWidget {
  const LoginScreenUser({super.key});

  @override
  State<LoginScreenUser> createState() => _LoginScreenUserState();
}

class _LoginScreenUserState extends State<LoginScreenUser> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void loginUser() {
    print(usernameController.text);
    print(emailController.text);
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


            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "UP number",
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
              child: ElevatedButton(
                onPressed: () {
                  // Handle forgot password
                 // Navigator.push(
                    //context,
                    //MaterialPageRoute(
                     // builder: (context) => const ForgotPasswordPage(),
                     // ),
                   //   );
                },
                child: const Text("Forgot Password?"),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loginUser,
                child: const Text("Login"),
              ),
            ),

            
            //adding a button bottom right
            Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle sign up
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => const LoginScreenAdmin(),
                      ),
                      );
                  },
                  child: const Text("admin"),
                ),   
              ),
          ],    
        ),
      ),
    );
  } 
}
