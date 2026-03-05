import 'package:flutter/material.dart';

class MySocietyPage extends StatelessWidget {
  const MySocietyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Societies')),
      body: const Center(child: Text('My Societies Page')),
    );
  }
}
