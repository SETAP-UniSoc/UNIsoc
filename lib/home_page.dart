import 'package:flutter/material.dart';
import 'navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: const [
            // Header with navbar + "UniSoc" + "Welcome Student"
            HomeHeader(),

            // Main content placeholder
            Expanded(child: Center(child: Text('Home content here'))),
          ],
        ),
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeNavbar();
  }
}


/*  Future<void> loginUser() async {
    final up_number = upnumberController.text;
    final password = passwordController.text;

    final url = Uri.parse("http://10.128.5.47:8000/api/user/login/");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"up_number": up_number, "password": password}),
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    print(upnumberController.text);
    print(passwordController.text); */