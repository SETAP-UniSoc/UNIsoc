import 'package:flutter/material.dart';

class Society {
  final String name;
  final Color color;
  final IconData icon;

  const Society({required this.name, required this.color, required this.icon});
}

const List<Society> featuredSocieties = [
  Society(
    name: 'Gaming Soc',
    color: Colors.blueAccent,
    icon: Icons.sports_esports,
  ),
  Society(
    name: 'Music Soc',
    color: Colors.purpleAccent,
    icon: Icons.music_note,
  ),
  Society(name: 'Drama Soc', color: Colors.orangeAccent, icon: Icons.theaters),
  Society(name: 'Chess Soc', color: Colors.greenAccent, icon: Icons.extension),
  Society(name: 'Tech Soc', color: Colors.tealAccent, icon: Icons.computer),
];
