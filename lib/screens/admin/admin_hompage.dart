import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';
import 'admin_bottom_nav.dart';
import 'admin_dropdown_menu.dart';
//admin hompage with a carousel of top societies, a section to browse societies by category and a section for upcoming events. Also includes a search bar that searches both events and societies and shows results in a dropdown as the user types. Admin can also filter and sort societies in the browse section. This is the default page when admin logs in
class AdminHomepage extends StatefulWidget {
  const AdminHomepage({super.key});

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
  final CarouselController _societyController = CarouselController();
  final CarouselController _eventController = CarouselController();

  String adminName = "John Smith"; // Later from backend

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
              _buildEventsSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // header

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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              AdminDropdownMenu(),
            ],
          ),
          const SizedBox(height: 8),

          // Welcome + Name (same line)
          Text(
            "Welcome $adminName",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 16),

          // Search bar
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

  // Top socs

  Widget _buildTopSocietiesCarousel() {
    List<String> topSocieties = [
      "Gaming Society",
      "Art Society",
      "Tech Society",
    ];

    return Column(
      children: [
        const Text(
          "Top Societies",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
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
              items: topSocieties.map((society) {
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
                      child: Text(
                        society,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildBrowseSocietiesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row (MATCHES USER PAGE STYLE)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Browse Societies",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  DropdownButton<String>(
                    hint: const Text("Sort by"),
                    items: const [
                      DropdownMenuItem(
                        value: "name",
                        child: Text("Name"),
                      ),
                      DropdownMenuItem(
                        value: "members",
                        child: Text("Members"),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    hint: const Text("Filter by"),
                    items: const [
                      DropdownMenuItem(
                        value: "category",
                        child: Text("Category"),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
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
>>>>>>> b3dbb94 (Accept admin homepage changes)

  // events

  // events carousel for admin's society
  Widget _buildEventsCarousel() {
    return Column(
      children: [
        const Text(
          "Events",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
