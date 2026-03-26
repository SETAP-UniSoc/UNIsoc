import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:unisoc/services/api_services.dart';
import 'package:unisoc/screens/society_profile_page.dart';
import 'admin_bottom_nav.dart';
import 'admin_dropdown_menu.dart';

class AdminHomepage extends StatefulWidget {
  const AdminHomepage({super.key});

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
  final CarouselSliderController _societyController = CarouselSliderController();

  List societies = [];
  List filteredSocieties = [];
  List events = [];
  bool isLoading = true;

  String selectedCategory = "All";
  String sortBy = "A-Z";
  bool showingCategories = true;

  List searchResults = [];
  Timer? debounce;
  bool isSearching = false;

  final List<String> categories = [
    "All", "Academic", "Cultural", "Sports", "Religious", "Extra-curricular"
  ];

  final Map<String, Color> categoryColours = {
    "Academic": const Color(0xFF5C6BC0),
    "Cultural": const Color(0xFF26A69A),
    "Sports": const Color(0xFF7E57C2),
    "Religious": const Color(0xFF8D6E63),
    "Extra-curricular": const Color(0xFF42A5F5),
    "All": const Color(0xFF7B1FA2),
  };

  final List<Color> carouselColours = [
    const Color(0xFF7B1FA2),
    const Color(0xFF6A1B9A),
    const Color(0xFF9C27B0),
    const Color(0xFF8E24AA),
    const Color(0xFF6D1F7B),
  ];

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  Future<void> loadData() async {
    await loadSocieties();
    await loadEvents();
    setState(() => isLoading = false);
  }

  Future<void> loadSocieties() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/societies/"),
        headers: ApiService.headers,
      );
      print("SOC RESPONSE: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          societies = data;
          filteredSocieties = data;
        });
        print("Loaded ${societies.length} societies");
      }
    } catch (e) {
      print("Error loading societies: $e");
    }
}

Future<void> loadEvents() async {
try {
final response = await http.get(
Uri.parse("${ApiService.baseUrl}/events/all/"),
headers: ApiService.headers,
);

if (response.statusCode == 200) {
final data = jsonDecode(response.body) as List;

setState(() {
events = data;
});

print("Loaded ${events.length} global events");
}
} catch (e) {
print("Error loading events: $e");
}
}


  void applyFilters() {
    List result = [...societies];

    if (selectedCategory != "All") {
      result = result.where((s) => s["category"] == selectedCategory).toList();
    }

    if (sortBy == "A-Z") {
      result.sort((a, b) => a["name"].compareTo(b["name"]));
    } else if (sortBy == "Z-A") {
      result.sort((a, b) => b["name"].compareTo(a["name"]));
    } else if (sortBy == "Most Members") {
      result.sort((a, b) => (b["member_count"] ?? 0).compareTo(a["member_count"] ?? 0));
    } else if (sortBy == "Least Members") {
      result.sort((a, b) => (a["member_count"] ?? 0).compareTo(b["member_count"] ?? 0));
    }

    setState(() {
      filteredSocieties = result;
      showingCategories = false;
    });
  }

  void resetToCategories() {
    setState(() {
      selectedCategory = "All";
      sortBy = "A-Z";
      filteredSocieties = [...societies];
      showingCategories = true;
    });
  }

  // Helper method to navigate to society page with correct isAdmin flag
  void navigateToSociety(int societyId, String societyName) {
    // Check if this is the admin's own society
    final bool isOwnSociety = societyId == ApiService.societyId;
    
    print("🔍 Navigating to society: $societyName (ID: $societyId)");
    print("👤 Admin's own society ID: ${ApiService.societyId}");
    print("🏷️ Setting isAdmin: $isOwnSociety");
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SocietyProfilePage(
          societyId: societyId,
          isAdmin: isOwnSociety,  // Only true if it's their own society
        ),
      ),
    );
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
              const SizedBox(height: 8),
              Column(
                children: [
                  _buildSearchBar(),
                  _buildSearchDropdown(),
                ],
              ),
              const SizedBox(height: 20),
              _buildTopSocietiesCarousel(),
              const SizedBox(height: 30),
              _buildBrowseSocietiesSection(),
              const SizedBox(height: 30),
              _buildEventsSection(),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCE93D8), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
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
                  color: Colors.white,
                ),
              ),
              AdminDropdownMenu(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Welcome — ${ApiService.societyName ?? 'Admin'}",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (query) {
          if (debounce?.isActive ?? false) debounce!.cancel();

          debounce = Timer(const Duration(milliseconds: 300), () async {
            if (query.isEmpty) {
              setState(() {
                searchResults = [];
              });
              return;
            }

            setState(() => isSearching = true);

            try {
              final response = await http.get(
                Uri.parse("${ApiService.baseUrl}/search?q=$query"),
                headers: ApiService.headers,
              );

              if (response.statusCode == 200) {
                setState(() {
                  searchResults = json.decode(response.body);
                  isSearching = false;
                });
              }
            } catch (e) {
              print("Search error: $e");
              setState(() => isSearching = false);
            }
          });
        },
        decoration: InputDecoration(
          hintText: "Search events or societies",
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9C27B0)),
          suffixIcon: isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Color(0xFF9C27B0)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchDropdown() {
    if (searchResults.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final item = searchResults[index];

          return ListTile(
            leading: item["type"] == "society" 
                ? const Icon(Icons.business, color: Color(0xFF9C27B0))
                : const Icon(Icons.event, color: Color(0xFF3B82F6)),
            title: Text(item["name"] ?? item["title"] ?? ""),
            subtitle: Text(item["type"] == "society" 
                ? "Society • ${item["category"] ?? ''}" 
                : "Event • ${item["society_name"] ?? ''}"),
            onTap: () {
              if (item["type"] == "society") {
                navigateToSociety(item["id"], item["name"]);
              } else if (item["type"] == "event") {
                navigateToSociety(item["society_id"], item["society_name"]);
              }
              setState(() {
                searchResults = [];
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildTopSocietiesCarousel() {
    final topSocieties = [...societies]
      ..sort((a, b) => (b["member_count"] ?? 0).compareTo(a["member_count"] ?? 0));
    final top5 = topSocieties.take(5).toList();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Top Societies",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 50),
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
                items: top5.asMap().entries.map((entry) {
                  final index = entry.key;
                  final society = entry.value;
                  final colour = carouselColours[index % carouselColours.length];

                  return GestureDetector(
                    onTap: () {
                      navigateToSociety(society["id"], society["name"]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colour, colour.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              society["name"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              society["category"] ?? "",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Text(
                            //   "${society["member_count"]} members",
                            //   style: const TextStyle(
                            //     color: Colors.white60,
                            //     fontSize: 13,
                            //   ),
                            //   textAlign: TextAlign.center,
                            // ),
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

  Widget _buildBrowseSocietiesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Browse Societies",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  PopupMenuButton<String>(
                    child: const Row(
                      children: [
                        Text("Sort by",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF9C27B0))),
                        Icon(Icons.arrow_drop_down,
                            color: Color(0xFF9C27B0)),
                      ],
                    ),
                    onSelected: (value) {
                      setState(() => sortBy = value);
                      applyFilters();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: "A-Z", child: Text("A-Z")),
                      PopupMenuItem(value: "Z-A", child: Text("Z-A")),
                      PopupMenuItem(
                          value: "Most Members",
                          child: Text("Most Members")),
                      PopupMenuItem(
                          value: "Least Members",
                          child: Text("Least Members")),
                    ],
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    child: const Row(
                      children: [
                        Text("Filter by",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF9C27B0))),
                        Icon(Icons.arrow_drop_down,
                            color: Color(0xFF9C27B0)),
                      ],
                    ),
                    onSelected: (value) {
                      setState(() => selectedCategory = value);
                      applyFilters();
                    },
                    itemBuilder: (_) => categories
                        .map((cat) =>
                            PopupMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!showingCategories)
            TextButton.icon(
              onPressed: resetToCategories,
              icon: const Icon(Icons.arrow_back, color: Color(0xFF9C27B0)),
              label: const Text(
                "Back to Categories",
                style: TextStyle(color: Color(0xFF9C27B0)),
              ),
            ),
          const SizedBox(height: 8),
          if (showingCategories)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: categories
                  .where((c) => c != "All")
                  .map((category) {
                final colour = categoryColours[category] ?? Colors.purple;
                final count = societies
                    .where((s) => s["category"] == category)
                    .length;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                      showingCategories = false;
                    });
                    applyFilters();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colour, colour.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$count societies",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredSocieties.isEmpty ? 1 : filteredSocieties.length,
              itemBuilder: (context, index) {
                if (filteredSocieties.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("No societies in this category"),
                    ),
                  );
                }

                final soc = filteredSocieties[index];
                final colour = categoryColours[soc["category"]] ?? Colors.purple;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colour,
                      child: Text(
                        soc["name"][0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      soc["name"],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(soc["category"] ?? ""),
                    trailing: Text(
                      "${soc["member_count"]} members",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      navigateToSociety(soc["id"], soc["name"]);
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
  // Create a controller for the events carousel
  final CarouselSliderController _eventsController = CarouselSliderController();
  
  // Only show upcoming events (future dates)
  final now = DateTime.now();
  final upcomingEvents = events.where((e) => 
    DateTime.parse(e["start_time"]).isAfter(now)
  ).toList();
  
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upcoming Events",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (upcomingEvents.isEmpty)
          const Text(
            "No upcoming events",
            style: TextStyle(color: Colors.grey),
          )
        else
          Stack(
            alignment: Alignment.center,
            children: [
              CarouselSlider(
                carouselController: _eventsController,
                options: CarouselOptions(
                  height: 160,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  enlargeCenterPage: true,
                  viewportFraction: 0.8,
                ),
                items: upcomingEvents.map((event) {
                  final startTime = DateTime.parse(event["start_time"]).toLocal();
                  
                  return GestureDetector(
                    onTap: () {
                      navigateToSociety(event["society_id"], event["society_name"]);
                    },
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
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
                            event["title"],
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
                                "${startTime.day}/${startTime.month}/${startTime.year}",
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
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.purple),
                  onPressed: () => _eventsController.previousPage(),
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.purple),
                  onPressed: () => _eventsController.nextPage(),
                ),
              ),
            ],
          ),
      ],
    ),
  );
}