import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'user/user_society_page.dart'; // Correct import for UserSocietyPage

class MySocietyPage extends StatefulWidget {
  const MySocietyPage({super.key});

  @override
  State<MySocietyPage> createState() => _MySocietyPageState();
}

class _MySocietyPageState extends State<MySocietyPage> {
  late Future<List> _futureMySocieties;

  @override
  void initState() {
    super.initState();
    _futureMySocieties = ApiService.getMySocieties();
  }

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
      body: FutureBuilder<List>(
        future: _futureMySocieties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final societies = snapshot.data ?? [];
          if (societies.isEmpty) {
            return const Center(
              child: Text(
                'You have not joined any societies yet.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: societies.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final soc = societies[index] as Map<String, dynamic>;
              final id = soc['id'] as int? ?? 0;
              final name = soc['name'] as String? ?? '';
              final description = soc['description'] as String? ?? '';
              final memberCount = (soc['member_count'] as int?) ?? 0;

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF4A235A),
                  child: Icon(Icons.group, color: Colors.white),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '$description\n$memberCount member${memberCount == 1 ? '' : 's'}',
                ),
                isThreeLine: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserSocietyPage(
                        societyId: id,
                        societyName: name,
                        description: description,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
