// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

<<<<<<< HEAD
class MySocietyPage extends StatefulWidget {
  const MySocietyPage({super.key});

  @override
  State<MySocietyPage> createState() => _MySocietyPageState();
}

class _MySocietyPageState extends State<MySocietyPage> {
  bool _isTechHovered = false;
  bool _isAcsHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Societies',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A235A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: MouseRegion(
                onEnter: (_) => setState(() => _isTechHovered = true),
                onExit: (_) => setState(() => _isTechHovered = false),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isTechHovered ? const Color(0xFFF3E5F5) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        // ignore: duplicate_ignore
                        // ignore: deprecated_member_use
                        color: Colors.grey.withOpacity(_isTechHovered ? 0.3 : 0.1),
                        blurRadius: _isTechHovered ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A235A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.computer,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tech Society',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'All things technology',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: MouseRegion(
                onEnter: (_) => setState(() => _isAcsHovered = true),
                onExit: (_) => setState(() => _isAcsHovered = false),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isAcsHovered ? const Color(0xFFF3E5F5) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(_isAcsHovered ? 0.3 : 0.1),
                        blurRadius: _isAcsHovered ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A235A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.people,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'ACS Society',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Afican and Caribbean Society',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
=======
class MySocietyPage extends StatelessWidget {
  const MySocietyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Societies')),
      body: const Center(child: Text('My Societies Page')),
>>>>>>> Maya-up2266552
    );
  }
}
