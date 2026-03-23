import 'package:flutter/material.dart';
import '../../navbar.dart';
import '../../models/soc_model.dart';
import '../../models/event_model.dart';
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

  @override
  void initState() {
    super.initState();
    _societyPageController = PageController(viewportFraction: 0.35);

    // Auto-advance every 5 seconds
    _societyTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || featuredSocieties.isEmpty) return;

      setState(() {
        _currentSocietyPage =
            (_currentSocietyPage + 1) % featuredSocieties.length;
      });

      _societyPageController.animateToPage(
        _currentSocietyPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UniSoc',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: PageView.builder(
                  controller: _societyPageController,
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredSocieties.length,
                  // itemBuilder: (context, index) {
                  //   final soc = featuredSocieties[index];
                  //   return _SocietyLogoCard(
                  //     label: soc.name,
                  //     color: soc.color,
                  //     icon: soc.icon,
                  //   );
                  // },
                  //changing one of the feature socs to be a button that goes to a different page for now
                  itemBuilder: (context, index) {
                    final soc = featuredSocieties[index];
                    if (index == 0) {
                      return _SocietyLogoCard(
                        label: soc.name,
                        color: soc.color,
                        icon: soc.icon,
                        UserSocietyPage: const UserSocietyPage(
                          societyId: 1,
                          societyName: "Gaming Society",
                          description:
                              "A society for gaming enthusiasts to share and learn about the latest in gaming.",
                        ),
                      );
                    }
                    return _SocietyLogoCard(
                      label: soc.name,
                      color: soc.color,
                      icon: soc.icon,
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
                      itemCount: featuredSocieties.length,
                      itemBuilder: (context, index) {
                        final soc = featuredSocieties[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: soc.color,
                            child: Icon(
                              soc.icon,
                              color: Colors.white,
                              size: 20,
                            ),
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

              const SizedBox(height: 24),

              // Upcoming events carousel
              const Text(
                'Upcoming Events',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
  final Color color;
  final IconData icon;
  final Widget? UserSocietyPage;

  const _SocietyLogoCard({
    required this.label,
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
