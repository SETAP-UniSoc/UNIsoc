import 'package:flutter/material.dart';
import 'package:unisoc/screens/society_profile_page.dart';

class UserSocietyPage extends StatefulWidget {
  final int societyId;
  final String societyName;
  final String description;

  const UserSocietyPage({
    super.key,
    required this.societyId,
    required this.societyName,
    required this.description,
  });

  @override
  State<UserSocietyPage> createState() => _UserSocietyPageState();
}

class _UserSocietyPageState extends State<UserSocietyPage> {
  @override
  Widget build(BuildContext context) {
    return SocietyProfilePage(
      societyId: widget.societyId,
      isAdmin: false,
    );
  }
}
