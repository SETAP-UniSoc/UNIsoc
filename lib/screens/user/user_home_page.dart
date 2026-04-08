import 'package:flutter/material.dart';
import '../../navbar.dart';
import '../../models/event_model.dart';
import '../../services/api_services.dart';
import 'user_society_page.dart'; //importing user society page to be used as a button in the home page
import 'dart:async';

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

class HomeHeader extends StatefulWidget {
  final String studentName;

  const HomeHeader({
    super.key,
    this.studentName = 'Student', // later pass the real name
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  late final PageController _societyPageController;
  int _currentSocietyPage = 0;
  Timer? _societyTimer;

  List<dynamic> _societies = [];
  List<dynamic> _topSocieties = [];
  List<dynamic> _events = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _societyPageController = PageController(viewportFraction: 0.35);

    _loadData(); // ← new

    // Auto-advance every 5 seconds
    _societyTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _societies.isEmpty) return;

      setState(() {
        _currentSocietyPage = (_currentSocietyPage + 1) % _societies.length;
      });

      _societyPageController.animateToPage(
        _currentSocietyPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _loadData() async {
    try {
      final societies = await ApiService.getSocieties();
      // if you later add a "getHomeEvents", call it here too
      if (!mounted) return;
      final topSocieties = [...societies]
        ..sort(
          (a, b) => (b["member_count"] ?? 0).compareTo(a["member_count"] ?? 0),
        );

      setState(() {
        _societies = societies;
        _topSocieties = topSocieties.take(3).toList();
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _societyTimer?.cancel();
    _societyPageController.dispose();
    super.dispose();
  }

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
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UniSoc',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome ${widget.studentName}',
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: _topSocieties.isEmpty
                          ? const Center(
                              child: Text('No featured societies yet'),
                            )
                          : PageView.builder(
                              controller: _societyPageController,
                              scrollDirection: Axis.horizontal,
                              itemCount: _topSocieties.length, // use top 3
                              itemBuilder: (context, index) {
                                final soc =
                                    _topSocieties[index]
                                        as Map<String, dynamic>;
                                final name = soc['name'] as String? ?? '';
                                final description =
                                    soc['description'] as String? ?? '';
                                final id = soc['id'] as int? ?? 0;
                                final memberCount =
                                    (soc['member_count'] as int?) ?? 0;

                                return _SocietyLogoCard(
                                  label: name,
                                  subtitle:
                                      '$memberCount member${memberCount == 1 ? '' : 's'}',
                                  color: index == 0
                                      ? Colors.deepPurple
                                      : Colors.indigo,
                                  icon: Icons.group,
                                  UserSocietyPage: UserSocietyPage(
                                    societyId: id,
                                    societyName: name,
                                    description: description,
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 24),

                    // Box around A–Z section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          // A–Z list header with sort/filter labels
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'All Societies (A-Z)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Sort by',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    'Filter by',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Scrollable list of societies A–Z
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _societies.length,
                            itemBuilder: (context, index) {
                              final soc =
                                  _societies[index] as Map<String, dynamic>;
                              final id = soc['id'] as int? ?? 0;
                              final name = soc['name'] as String? ?? '';
                              final description =
                                  soc['description'] as String? ?? '';

                              return ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.deepPurple,
                                  child: Icon(
                                    Icons.group,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(name),
                                subtitle: Text(description),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserSocietyPage(
                                        societyId: id,
                                        societyName: name,
                                        description: description,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Upcoming events carousel
                    const Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: featuredEvents.length,
                        itemBuilder: (context, index) {
                          final event = featuredEvents[index];
                          return _EventCard(event: event);
                        },
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
  final String? subtitle;
  final Color color;
  final IconData icon;
  final Widget? UserSocietyPage;

  const _SocietyLogoCard({
    required this.label,
    this.subtitle,
    required this.color,
    required this.icon,
    this.UserSocietyPage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: UserSocietyPage == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserSocietyPage!),
              );
            },
      child: Container(
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
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: event.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            event.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.date,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            event.location,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
