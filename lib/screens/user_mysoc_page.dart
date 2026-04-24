import 'package:flutter/material.dart';

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
        child: Row(
          children: [
            Expanded(
              child: _SocietyCard(
                title: 'Tech Society',
                subtitle: 'All things technology',
                members: '150 members',
                icon: Icons.computer,
                hovered: _isTechHovered,
                onHoverChanged: (hovered) {
                  setState(() => _isTechHovered = hovered);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SocietyCard(
                title: 'ACS Society',
                subtitle: 'African and Caribbean Society',
                members: '350 members',
                icon: Icons.people,
                hovered: _isAcsHovered,
                onHoverChanged: (hovered) {
                  setState(() => _isAcsHovered = hovered);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocietyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String members;
  final IconData icon;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;

  const _SocietyCard({
    required this.title,
    required this.subtitle,
    required this.members,
    required this.icon,
    required this.hovered,
    required this.onHoverChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: hovered ? const Color(0xFFF3E5F5) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(hovered ? 0.3 : 0.1),
              blurRadius: hovered ? 8 : 4,
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
              child: Icon(icon, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              members,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A235A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
