import 'package:flutter/material.dart';
import 'login_screen.admin.dart';
import 'forgotten_password_screen.dart';
import 'signup_user_page.dart';


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

          

            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: loginUser,
            //     child: const Text("Login"),
            //   ),
            // ),

            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: loginUser,
                child: const Text("Login"),
              ),
            ),
            const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.bottomRight,
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
            Align(
                  alignment: Alignment.bottomLeft,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}