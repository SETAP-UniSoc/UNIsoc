import 'package:flutter/material.dart';
import 'package:unisoc/screens/society_profile_page.dart';

class UserSocietyPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SocietyProfilePage(
      societyId: societyId,
      isAdmin: false,
    );
  }
}