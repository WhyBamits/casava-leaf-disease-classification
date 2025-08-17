import 'package:flutter/material.dart';
import 'package:plant_disease_detection/ui/screens/select_scan_page.dart';
import 'package:plant_disease_detection/chat_page.dart';
import 'package:plant_disease_detection/comm.dart';
import 'package:plant_disease_detection/faq_page.dart';
import 'package:plant_disease_detection/weather.dart';
import 'package:plant_disease_detection/ui/screens/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:plant_disease_detection/main_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F3),
      endDrawer: const MainDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), // Reduced vertical padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with search and avatar
              Builder(
                builder: (context) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        "Find Cassava plant \nhealth solutions",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color.fromARGB(255, 15, 15, 15),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.account_box_rounded,
                            size: 32,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              const SizedBox(height: 18),
              // Categories
              Text(
                "Easy Help",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 120, // Increased height for bigger cards
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _CategoryActionCard(
                      icon: Icons.chat,
                      label: "Chat",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CassavaChatScreen()),
                        );
                      },
                    ),
                    _CategoryActionCard(
                      icon: Icons.menu_book,
                      label: "Blogs",
                      onTap: () {
                       Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EducationalContentPage()),
                        );
                      },
                    ),
                    
                    _CategoryActionCard(
                      icon: Icons.notifications_none,
                      label: "FAQs",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const FAQPage()),
                        );
                      },
                    ),
                     _CategoryActionCard(
                      icon: Icons.notifications_none,
                      label: "Weather",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const WeatherTipsPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12), // Reduced from 18
              // Mission card
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 13, 15, 15).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF5D7C4A).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Health of your plants is our mission",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16, // Reduced font size if needed
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Send us photos of the Cassava plant leaf for detection and you'll get an answer on whether it is healthy or affected.",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 15,
                              height: 1.3,
                            ),
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image(
                        image: AssetImage("assets/images/5.png"),
                        width: 120,
                        height: 170,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Common Problems
              const Text(
                "Common Diseases",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 16), // Reduced from 24
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1, // Adjusted from 1.2 for better fit
                  children: [
                    _ProblemCard(
                      image: "assets/images/mosaic.png",
                      title: "Mosaic",
                      onTap: () async {
                        final Uri url = Uri.parse('https://www.iita.org/news-item/cassava-mosaic-disease/');
                        if (!await launchUrl(url)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open the website')),
                          );
                        }
                      },
                    ),
                    _ProblemCard(
                      image: "assets/images/blight.png",
                      title: "Blight",
                      onTap: () async {
                        final Uri url = Uri.parse('https://www.plantwise.org/KnowledgeBank/factsheetforfarmers/20147800831');
                        if (!await launchUrl(url)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open the website')),
                          );
                        }
                      },
                    ),
                    _ProblemCard(
                      image: "assets/images/brown.png",
                      title: "Brown Streak",
                      onTap: () async {
                        final Uri url = Uri.parse('https://www.cabi.org/isc/datasheet/2747');
                        if (!await launchUrl(url)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open the website')),
                          );
                        }
                      },
                    ),
                    _ProblemCard(
                      image: "assets/images/green.png",
                      title: "Green Mite",
                      onTap: () async {
                        final Uri url = Uri.parse('https://www.plantwise.org/KnowledgeBank/datasheet/35126');
                        if (!await launchUrl(url)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open the website')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Theme.of(context).colorScheme.primary, size: 32),
                onPressed: () {},
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 34),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SelectScanPage()),
                    );
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary, size: 34),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Category Icon ---
// ignore: unused_element
class _CategoryIcon extends StatelessWidget {
  final String label;
  final String image;
  const _CategoryIcon({required this.label, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color.fromARGB(255, 172, 214, 241),
            backgroundImage: AssetImage(image),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// --- Category Action Card ---
class _CategoryActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.transparent,
              child: Icon(icon, color: Theme.of(context).colorScheme.onBackground, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Problem Card ---
class _ProblemCard extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback onTap;
  const _ProblemCard({
    required this.image,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
              child: Image.asset(
                image,
                height: 85, // Slightly reduced from 90
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0), // Reduced from 14.0
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  fontSize: 16, // Reduced from 18
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
