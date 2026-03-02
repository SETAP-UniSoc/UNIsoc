import 'package:flutter/material.dart';
import 'navbar.dart';
import 'models/soc_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: const [
              // Header with navbar + "UniSoc" + "Welcome Student"
              HomeHeader(),

              // Main content placeholder (will be replaced by A–Z list section)
              // For now we can leave it or remove it:
              // SizedBox(height: 400, child: Center(child: Text('Home content here'))),
            ],
          ),
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
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredSocieties.length,
                  itemBuilder: (context, index) {
                    final soc = featuredSocieties[index];
                    return _SocietyLogoCard(
                      label: soc.name,
                      color: soc.color,
                      icon: soc.icon,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // A–Z list header with sort/filter labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'All Societies (A–Z)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Text(
                        'Sort by',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Filter by',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Scrollable list of societies A–Z
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: featuredSocieties.length,
                itemBuilder: (context, index) {
                  final soc = featuredSocieties[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: soc.color,
                      child: Icon(soc.icon, color: Colors.white, size: 20),
                    ),
                    title: Text(soc.name),
                    subtitle: const Text('Short description here'),
                    onTap: () {
                      // TODO: navigate to society detail page
                    },
                  );
                },
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
