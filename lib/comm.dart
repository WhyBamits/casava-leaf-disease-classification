import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EducationalContentPage extends StatelessWidget {
  const EducationalContentPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> articles = const [
     {
      "title": "Kenyan Farmers Turn to sApp & AI Tools to Combat Cassava Diseases",
      "description":
          "Farmers in Kenya are using PlantVillage’s Nuru AI tool and sApp to fight cassava disease outbreaks.",
      "image": "https://i0.wp.com/news.mongabay.com/wp-content/uploads/sites/20/2024/06/Kenya-cassava-disease.jpg?fit=720%2C480&ssl=1",
      "url": "https://news.mongabay.com/2024/06/kenyan-farmers-turn-to-sapp-ai-tools-to-combat-crop-diseases/"
    },
    {
      "title": "Plantix App: From Fighting Pesticides to Selling Them",
      "description":
          "Plantix began to fight pesticide overuse but now connects farmers to suppliers via their platform.",
      "image": "https://media.wired.com/photos/662b3a0865b9294e5ddf45df/master/w_1600,c_limit/AI-Farming-App-Gear.jpg",
      "url": "https://www.wired.com/story/plantix-pesticides-venture-capital-app/"
    },
    {
      "title": "Agrio: AI-Powered Plant Disease Diagnosis",
      "description":
          "Agrio uses machine learning to detect plant diseases and offers expert insights to farmers.",
      "image": "https://agrio.app/wp-content/uploads/2023/03/AI-crop-diagnosis.jpg",
      "url": "https://agrio.app/An-app-that-identifies-plant-diseases-and-pests/"
    },
    {
      "title": "AI App Nuru Empowers Farmers Against Cassava Mosaic Virus",
      "description":
          "A study shows Nuru helps diagnose cassava mosaic virus early, aiding smallholder decision-making.",
      "image": "https://www.mdpi.com/agriculture/agriculture-14-02001/article_deploy/html/images/agriculture-14-02001-g001.png",
      "url": "https://www.mdpi.com/2077-0472/14/11/2001"
    },
    {
      'title': 'Cassava Farming Best Practices',
      'description': 'Learn grow healthy cassava with step-by-step guides.',
      'url': 'https://www.fao.org/3/a0154e/A0154E06.htm',
    },
    {
      'title': 'Cassava Disease Prevention',
      'description': 'Tips and methods to prevent common cassava diseases.',
      'url': 'https://www.cabi.org/isc/datasheet/11956',
    },
    {
      'title': 'Video: Identifying Cassava Mosaic Disease',
      'description': 'Watch this video to identify symptoms and management strategies.',
      'url': 'https://www.youtube.com/watch?v=8vQwQ1QwQn4',
    },
    {
      'title': 'Cassava Leaf Spot: Symptoms & Control',
      'description': 'Article on recognizing and controlling leaf spot in cassava.',
      'url': 'https://www.plantwise.org/KnowledgeBank/factsheetforfarmers/20147800002',
    },
    {
      'title': 'Cassava Harvesting and Storage Tips',
      'description': 'harvest and store cassava for best quality.',
      'url': 'https://www.ctc-n.org/technologies/cassava-harvesting-and-storage',
    },
   
  ];

  void _launchUrl(BuildContext context, String urlStr) async {
    final url = Uri.parse(urlStr);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Educational & Blogs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6FAF3),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: articles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final article = articles[index];
          final hasImage = article.containsKey('image') && article['image'] != null;

          return GestureDetector(
            onTap: () => _launchUrl(context, article['url']),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasImage)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        article['image'],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox(height: 180),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article['title'] ?? 'Untitled',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Color(0xFF5D7C4A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article['description'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
