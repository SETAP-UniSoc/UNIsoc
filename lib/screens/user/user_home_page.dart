import 'package:flutter/material.dart';
import '../../navbar.dart';
import '../../services/api_services.dart';
import 'user_society_page.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatelessWidget {
  final Future<List<dynamic>> Function()? getSocieties;
  final Future<List<dynamic>> Function()? getEventsForJoinedSocieties;
  const HomePage({
    super.key,
    this.getSocieties,
    this.getEventsForJoinedSocieties,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HomeHeader(
                getSocieties: getSocieties,
                getEventsForJoinedSocieties: getEventsForJoinedSocieties,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeHeader extends StatefulWidget {
  final String studentName;
  final Future<List<dynamic>> Function()? getSocieties;
  final Future<List<dynamic>> Function()? getEventsForJoinedSocieties;

  const HomeHeader({
    super.key,
    this.studentName = 'Student',
    this.getSocieties,
    this.getEventsForJoinedSocieties,
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
  List<dynamic> _filteredSocieties = [];
  final List<dynamic> _events = [];
  bool _loading = true;
  String? _error;
  List<dynamic> _searchResults = [];
  Timer? _debounce;
  bool _isSearching = false;

  String selectedCategory = "All";
  String sortBy = "A-Z";
  bool showingCategories = true;

  final List<String> categories = [
    "All",
    "Academic",
    "Cultural",
    "Sports",
    "Religious",
    "Extra-curricular",
  ];

  void applyFilters() {
    List result = [..._societies];

    if (selectedCategory != "All") {
      result = result.where((s) => s["category"] == selectedCategory).toList();
    }

    if (sortBy == "A-Z") {
      result.sort((a, b) => a["name"].compareTo(b["name"]));
    } else if (sortBy == "Z-A") {
      result.sort((a, b) => b["name"].compareTo(a["name"]));
    } else if (sortBy == "Most Members") {
      result.sort(
        (a, b) => (b["member_count"] ?? 0).compareTo(a["member_count"] ?? 0),
      );
    } else if (sortBy == "Least Members") {
      result.sort(
        (a, b) => (a["member_count"] ?? 0).compareTo(b["member_count"] ?? 0),
      );
    }

    setState(() {
      _filteredSocieties = result;
      showingCategories = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _societyPageController = PageController(viewportFraction: 0.35);

    _loadData();

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
      final societies =
          await (widget.getSocieties ?? ApiService.getSocieties)();
      final events =
          await (widget.getEventsForJoinedSocieties ??
              ApiService.getEventsForJoinedSocieties)();

      if (!mounted) return;
      final topSocieties = [...societies];

      setState(() {
        _societies = societies;
        _filteredSocieties = societies;
        _topSocieties = topSocieties.take(3).toList();
        _events.clear();
        _events.addAll(events);
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
    _debounce?.cancel();
    _societyPageController.dispose();
    super.dispose();
  }

  Widget _buildSearchDropdown() {
    if (_searchResults.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final item = _searchResults[index] as Map<String, dynamic>;
          final type = (item['type'] ?? '') as String;
          final name = item['name'] ?? item['title'] ?? '';

          return ListTile(
            leading: Icon(
              type == 'event' ? Icons.event : Icons.group,
              color: Colors.deepPurple,
            ),
            title: Text(name.toString()),
            subtitle: Text(type),
            onTap: () {
              setState(() => _searchResults = []);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserSocietyPage(
                    societyId: item['id'],
                    societyName: item['name'] ?? '',
                    description: item['description'] ?? '',
                  ),
                ),
              );
              setState(() {
                _searchResults = [];
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildEventsCarousel() {
    if (_events.isEmpty) {
      return const Center(child: Text('No upcoming events available.'));
    }

    return SizedBox(
      height: 160,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 160,
          autoPlay: _events.length > 1,
          enableInfiniteScroll: _events.length > 1,
          autoPlayInterval: const Duration(seconds: 4),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: false,
          viewportFraction: 0.75,
          pauseAutoPlayOnTouch: true,
        ),
        items: _events.map((event) {
          DateTime? startTime;
          try {
            startTime = DateTime.parse(event['start_time']).toLocal();
          } catch (_) {
            startTime = null;
          }

          final int? societyId = event['society_id'] as int?;

          return GestureDetector(
            onTap: () {
              if (societyId == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserSocietyPage(
                    societyId: societyId,
                    societyName: event['society_name'] ?? '',
                    description: '',
                  ),
                ),
              );
            },
            child: Container(
              width: 200,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    event['title'] ?? 'Untitled',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startTime != null
                            ? '${startTime.day}/${startTime.month}/${startTime.year}'
                            : '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event['location'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
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
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF9C27B0),
                        ),
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Color(0xFF9C27B0),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                      ),
                      onChanged: (query) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();

                        _debounce = Timer(
                          const Duration(milliseconds: 300),
                          () async {
                            if (query.isEmpty) {
                              setState(() {
                                _searchResults = [];
                              });
                              return;
                            }

                            setState(() => _isSearching = true);

                            try {
                              final url =
                                  "${ApiService.baseUrl}/search?q=$query";
                              print("USER SEARCH URL: $url");

                              final response = await http.get(
                                Uri.parse(url),
                                headers: ApiService.headers,
                              );

                              print(
                                "USER SEARCH STATUS: ${response.statusCode}",
                              );
                              print("USER SEARCH BODY: ${response.body}");

                              if (response.statusCode == 200) {
                                setState(() {
                                  _searchResults = json.decode(response.body);
                                  _isSearching = false;
                                });
                              } else {
                                setState(() => _isSearching = false);
                              }
                            } catch (e) {
                              print("User search error: $e");
                              setState(() => _isSearching = false);
                            }
                          },
                        );
                      },
                    ),
                    _buildSearchDropdown(),
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
                      height: 120,
                      child: _topSocieties.isEmpty
                          ? const Center(
                              child: Text('No featured societies yet'),
                            )
                          : PageView.builder(
                              controller: _societyPageController,
                              scrollDirection: Axis.horizontal,
                              itemCount: _topSocieties.length,
                              itemBuilder: (context, index) {
                                final soc =
                                    _topSocieties[index]
                                        as Map<String, dynamic>;
                                final name = soc['name'] as String? ?? '';
                                final description =
                                    soc['description'] as String? ?? '';
                                final id = soc['id'] as int? ?? 0;

                                return _SocietyLogoCard(
                                  label: name,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Text(
                                  'All Societies (A-Z)',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PopupMenuButton<String>(
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Sort by",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF9C27B0),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: Color(0xFF9C27B0),
                                        ),
                                      ],
                                    ),
                                    onSelected: (value) {
                                      setState(() {
                                        sortBy = value;
                                        applyFilters();
                                      });
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: "A-Z",
                                        child: Text("A-Z"),
                                      ),
                                      PopupMenuItem(
                                        value: "Z-A",
                                        child: Text("Z-A"),
                                      ),
                                      PopupMenuItem(
                                        value: "Most Members",
                                        child: Text("Most Members"),
                                      ),
                                      PopupMenuItem(
                                        value: "Least Members",
                                        child: Text("Least Members"),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<String>(
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Filter by",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF9C27B0),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: Color(0xFF9C27B0),
                                        ),
                                      ],
                                    ),
                                    onSelected: (value) {
                                      setState(() {
                                        selectedCategory = value;
                                        applyFilters();
                                      });
                                    },
                                    itemBuilder: (_) => categories
                                        .map(
                                          (category) => PopupMenuItem(
                                            value: category,
                                            child: Text(category),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredSocieties.length,
                            itemBuilder: (context, index) {
                              final soc =
                                  _filteredSocieties[index]
                                      as Map<String, dynamic>;
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
                    const Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildEventsCarousel(),
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