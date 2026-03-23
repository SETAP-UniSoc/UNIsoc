import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:unisoc/services/api_services.dart';
import 'admin_bottom_nav.dart';
import 'admin_dropdown_menu.dart';

class AdminHomepage extends StatefulWidget {
  const AdminHomepage({super.key});

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
  final CarouselSliderController _societyController = CarouselSliderController();
  final CarouselSliderController _eventController = CarouselSliderController();
  List societies = [];
  List events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // load societies and events from backend
  Future<void> loadData() async {
    await Future.wait([
      loadSocieties(),
      loadEvents(),
    ]);
    setState(() => isLoading = false);
  }

  // fetch all societies
  Future<void> loadSocieties() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/societies/"),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        setState(() => societies = jsonDecode(response.body));
      }
    } catch (e) {
      print("Error loading societies: $e");
    }
  }

  // fetch events for admin's society
  Future<void> loadEvents() async {
    try {
      final id = ApiService.societyId;
      if (id == null) return;
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/society/$id/events/"),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final now = DateTime.now();
        // filter out past events
        setState(() {
          events = data.where((e) =>
            DateTime.parse(e["start_time"]).isAfter(now)
          ).toList();
        });
      }
    } catch (e) {
      print("Error loading events: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildTopSocietiesCarousel(),
              const SizedBox(height: 30),
              _buildBrowseSocietiesSection(),
              const SizedBox(height: 30),
              _buildEventsCarousel(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "UniSoc",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AdminDropdownMenu(),
            ],
          ),
          const SizedBox(height: 8),

          // shows society name from login instead of hardcoded name
          Text(
            "Welcome — ${ApiService.societyName ?? 'Admin'}",
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),

          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: "Search events or societies",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  // top societies by member count
  Widget _buildTopSocietiesCarousel() {
    // sort by member count and take top 5
    final topSocieties = [...societies]
      ..sort((a, b) => (b["member_count"] ?? 0).compareTo(a["member_count"] ?? 0));
    final top5 = topSocieties.take(5).toList();

    return Column(
      children: [
        const Text(
          "Top Societies",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const CircularProgressIndicator()
        else if (top5.isEmpty)
          const Text("No societies yet")
        else
          Stack(
            alignment: Alignment.center,
            children: [
              CarouselSlider(
                carouselController: _societyController,
                options: CarouselOptions(
                  height: 180,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  enlargeCenterPage: true,
                  viewportFraction: 0.8,
                ),
                items: top5.map((society) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminSocietyPage(),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              society["name"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${society["member_count"]} members",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Positioned(
                left: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => _societyController.previousPage(),
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () => _societyController.nextPage(),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // all societies A-Z
  Widget _buildBrowseSocietiesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'All Societies (A–Z)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Text('Sort by',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  SizedBox(width: 16),
                  Text('Filter by',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : societies.isEmpty
                    ? const Center(child: Text("No societies found"))
                    : ListView.builder(
                        itemCount: societies.length,
                        itemBuilder: (context, index) {
                          final soc = societies[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                soc["name"][0], // first letter of society name
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(soc["name"]),
                            subtitle: Text(soc["category"] ?? ""),
                            trailing: Text(
                              "${soc["member_count"]} members",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            onTap: () {},
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // events carousel for admin's society
  Widget _buildEventsCarousel() {
    return Column(
      children: [
        const Text(
          "Events",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const CircularProgressIndicator()
        else if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text("No upcoming events"),
          )
        else
          CarouselSlider(
            carouselController: _eventController,
            options: CarouselOptions(
              height: 160,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              enlargeCenterPage: true,
              viewportFraction: 0.8,
            ),
            items: events.map((event) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event["title"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event["location"] ?? "",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// Temporary Blank Page
class AdminSocietyPage extends StatelessWidget {
  const AdminSocietyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Society Page")),
      body: const Center(child: Text("Blank for now")),
    );
  }
}