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
            },
          );
        },
      ),
    );
  }

  // ✅ FIXED EVENTS CAROUSEL (ADMIN VERSION)
  Widget _buildEventsCarousel() {
    final CarouselSliderController _eventsController =
        CarouselSliderController();

    if (_events.isEmpty) {
      return const Text(
        "No upcoming events",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        CarouselSlider(
          carouselController: _eventsController,
          options: CarouselOptions(
            height: 160,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: false,
            viewportFraction: 0.7,
            pauseAutoPlayOnTouch: true,
          ),
          items: _events.map((event) {
            DateTime? startTime;
            try {
              startTime =
                  DateTime.parse(event["start_time"]).toLocal();
            } catch (_) {}

            final int? societyId = event["society_id"] as int?;

            return GestureDetector(
              onTap: () {
                if (societyId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Cannot open: missing society information"),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserSocietyPage(
                      societyId: societyId,
                      societyName: event["society_name"] ?? "",
                      description: "",
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
                      event["title"] ?? "Untitled",
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
                              ? "${startTime.day}/${startTime.month}/${startTime.year}"
                              : "",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event["location"] ?? "",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (event["capacity_limit"] != null)
                          Text(
                            "Cap: ${event["capacity_limit"]}",
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        Positioned(
          left: 0,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => _eventsController.previousPage(),
          ),
        ),
        Positioned(
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
            onPressed: () => _eventsController.nextPage(),
          ),
        ),
      ],
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
                          style: const TextStyle(
                              fontSize: 18, color: Colors.grey),
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

                        _loading
                            ? const Center(
                                child: CircularProgressIndicator())
                            : _buildEventsCarousel(),
                      ],
                    ),
        ),
      ],
    );
  }
}