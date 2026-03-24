import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:unisoc/services/api_services.dart';
import 'admin_bottom_nav.dart';
import 'admin_dropdown_menu.dart';
//admin hompage with a carousel of top societies, a section to browse societies by category and a section for upcoming events. Also includes a search bar that searches both events and societies and shows results in a dropdown as the user types. Admin can also filter and sort societies in the browse section. This is the default page when admin logs in
class AdminHomepage extends StatefulWidget {
  const AdminHomepage({super.key});

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
<<<<<<< HEAD
  final CarouselSliderController _societyController = CarouselSliderController();
final CarouselSliderController _eventController = CarouselSliderController();
  String adminName = "John Smith"; // Later from backend
=======
  final CarouselSliderController _societyController =
      CarouselSliderController();
  final CarouselSliderController _eventController = CarouselSliderController();
  String adminName = "John Smith"; // Later from backend
  final CarouselSliderController _societyController =
      CarouselSliderController();
  final CarouselSliderController _eventController = CarouselSliderController();

  List societies = [];
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
    "Academic": const Color(0xFF5C6BC0), //indgo
    "Cultural": const Color(0xFF26A69A), //teal
    "Sports": const Color(0xFF7E57C2), //medium purple
    "Extra-curricular": const Color(0xFF42A5F5), //light blue
    "All": const Color(0xFF7B1FA2), //deep purple     
    };

  final List<Color> carouselColours = [
    const Color(0xFF7B1FA2), //deep purple
    const Color(0xFF6A1B9A), //darker purple
    const Color(0xFF9C27B0), // purple
    const Color(0xFF8E24AA), // medium purple
    const Color(0xFF6D1F7B), // darkest purple
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // load societies and events from backend
  Future<void> loadData() async {
    await Future.wait([loadSocieties(), loadEvents()]);
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
          events = data
              .where((e) => DateTime.parse(e["start_time"]).isAfter(now))
              .toList();
        });
      }
    } catch (e) {
      print("Error loading events: $e");
    }
  }
>>>>>>> b3dbb94 (Accept admin homepage changes)

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
              _buildSearchBar(),
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

  // gradient header with UniSoc, welcome and dropdown
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
                ),
              ),
              AdminDropdownMenu(),
            ],
          ),
          const SizedBox(height: 8),

          // shows society name from login instead of hardcoded name
          Text(
            "Welcome $adminName",
<<<<<<< HEAD
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
=======
            "Welcome — ${ApiService.societyName ?? 'Admin'}",
            style: const TextStyle(fontSize: 18, color: Colors.grey),
>>>>>>> b3dbb94 (Accept admin homepage changes)
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
//searchbar code
  Widget _buildSearchBar() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: TextField(
      onChanged: (query) {
        // 🔥 debounce (prevents spam requests)
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

        // 🔥 loading indicator
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
          leading: const Icon(Icons.search),
          title: Text(item["name"] ?? item["title"] ?? ""),
          subtitle: Text(item["type"] ?? ""),

          onTap: () {
            if (item["type"] == "society") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SocietyProfilePage(
                    societyId: item["id"],
                    isAdmin: false,
                  ),
                ),
              );
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
    // sort by member count and take top 5
    final topSocieties = [...societies]
      ..sort(
        (a, b) => (b["member_count"] ?? 0).compareTo(a["member_count"] ?? 0),
      );
    final top5 = topSocieties.take(5).toList();

    return Column(
      children: [
        const Text(
          "Top Societies",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
                items: top5.asMap().entries.map((entry) {
                  final index = entry.key;
                  final society = entry.value;
                  final colour =
                      carouselColours[index % carouselColours.length];

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
                        gradient: LinearGradient(
                          colors: [colour, colour.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage("assets/images/society_placeholder.png"),
                          fit: BoxFit.cover,
                          opacity: 0.2, // placeholder — replace with real image
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              society["name"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
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

  // browse soc

<<<<<<< HEAD
 Widget _buildBrowseSocietiesSection() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row (MATCHES USER PAGE STYLE)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'All Societies (A–Z)',
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
=======
  // all societies A-Z
  Widget _buildBrowseSocietiesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row (MATCHES USER PAGE STYLE)
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
>>>>>>> b3dbb94 (Accept admin homepage changes)
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Filter by',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
<<<<<<< HEAD
                ),
              ],
            ),
          ],
        ),

          const SizedBox(height: 12),

        // Scrollable box (ADMIN ONLY DIFFERENCE)
        Container(
          height: 260,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text("Society ${index + 1}"),
                subtitle: const Text("Short description here"),
                onTap: () {},
              );
            },
          ),
        ),
      ],
    ),
  );
}
=======
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

          // Scrollable box (ADMIN ONLY DIFFERENCE)
          const SizedBox(height: 12),
          Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text("Society ${index + 1}"),
                  subtitle: const Text("Short description here"),
                  onTap: () {},
                );
              },
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
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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
>>>>>>> b3dbb94 (Accept admin homepage changes)

  // events

  Widget _buildEventsCarousel() {
    List<String> topEvents = [
      "Hackathon 2024",
      "Gaming Tournament",
      "Art Exhibition",
    ];

    return Column(
      children: [
        const Text(
          "Events",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        CarouselSlider(
          carouselController: _eventController,
          options: CarouselOptions(
            height: 160,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            enlargeCenterPage: true,
            viewportFraction: 0.8,
          ),
          items: topEvents.map((event) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  event,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
<<<<<<< HEAD
<<<<<<< HEAD
=======

>>>>>>> Maya-up2266552
=======
>>>>>>> b3dbb94 (Accept admin homepage changes)
