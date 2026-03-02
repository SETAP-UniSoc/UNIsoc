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
  final String studentName;

  const HomeHeader({
    super.key,
    this.studentName = 'Student', // later pass the real name
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const HomeNavbar(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UniSoc',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome $studentName',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search events or societies',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                ),
                onChanged: (value) {
                  // TODO: hook up search logic later
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Featured Societies',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80, // height of the logo cards
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _SocietyLogoCard(
                      label: 'Gaming Soc',
                      color: Colors.blueAccent,
                      icon: Icons.sports_esports,
                    ),
                    _SocietyLogoCard(
                      label: 'Music Soc',
                      color: Colors.purpleAccent,
                      icon: Icons.music_note,
                    ),
                    _SocietyLogoCard(
                      label: 'Drama Soc',
                      color: Colors.orangeAccent,
                      icon: Icons.theaters,
                    ),
                    _SocietyLogoCard(
                      label: 'Chess Soc',
                      color: Colors.greenAccent,
                      icon: Icons.extension,
                    ),
                    _SocietyLogoCard(
                      label: 'Tech Soc',
                      color: Colors.tealAccent,
                      icon: Icons.computer,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocietyLogoCard extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _SocietyLogoCard({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
