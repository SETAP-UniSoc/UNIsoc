import 'package:flutter/material.dart';

// Forgotten password screen with simple verify + reset flow
class ForgottenPasswordScreen extends StatefulWidget {
  const ForgottenPasswordScreen({super.key});

  @override
  State<ForgottenPasswordScreen> createState() => _ForgottenPasswordScreenState();
}

class _ForgottenPasswordScreenState extends State<ForgottenPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Exposed for widget tests to manipulate directly
  bool isVerified = false;
  String userId = '';

  // Role selection
  String role = 'user'; // 'user' or 'admin'

  void resetPassword() {
    final newPass = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    if (newPass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    if (newPass.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 8 characters')));
      return;
    }

    if (newPass != confirm) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Password reset')));
  }

  void verifyEmail() {
    final email = emailController.text.trim();
    if (role == 'user') {
      if (email.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Please enter your email')));
        return;
      }
      setState(() {
        isVerified = true;
        userId = '42';
      });
    } else {
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter your registered email')));
        return;
      }
      setState(() {
        isVerified = true;
        userId = '42';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(role == 'admin' && !isVerified ? 'Admin Password Reset' : 'Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: isVerified ? _buildResetForm() : _buildVerifyForm(),
        ),
      ),
    );
  }

  Widget _buildVerifyForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Select your role',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => setState(() => role = 'user'),
              child: const Text(' User'),
            ),
            TextButton(
              onPressed: () => setState(() => role = 'admin'),
              child: const Text(' Admin'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Enter your email address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'email',
            border: UnderlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: verifyEmail,
          child: Text(role == 'admin' ? 'Verify Admin' : 'Verify Email'),
        ),
      ],
    );
  }

  Widget _buildResetForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Reset Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          controller: newPasswordController,
          decoration: const InputDecoration(labelText: 'New Password'),
          obscureText: true,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: confirmPasswordController,
          decoration: const InputDecoration(labelText: 'Confirm Password'),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: resetPassword, child: const Text('Reset Password'))
      ],
    );
  }
}
