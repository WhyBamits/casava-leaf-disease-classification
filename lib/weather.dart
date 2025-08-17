import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherTipsPage extends StatefulWidget {
  const WeatherTipsPage({super.key});

  @override
  State<WeatherTipsPage> createState() => _WeatherTipsPageState();
}

class _WeatherTipsPageState extends State<WeatherTipsPage> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  String? error;

  // Replace with your API key
  final String apiKey = '35fdf1af2f2c3b00e6507d2eb218809f';
  // Default location (you can make this dynamic based on user's location)
  final String city = 'Sunyani'; 
  final String country = 'GH'; // Changed from 'NG' to 'GH' for Ghana

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city,$country&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherData = {
            'temperature': '${data['main']['temp'].round()}°C',
            'humidity': '${data['main']['humidity']}%',
            'rainfall': data['rain']?['1h']?.toString() ?? '0mm',
            'condition': data['weather'][0]['main'],
            'description': data['weather'][0]['description'],
          };
          isLoading = false;
        });
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          error = 'Error: ${errorData['message'] ?? 'Failed to load weather data'}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error: Please check your internet connection';
        isLoading = false;
      });
    }
  }

  // Weather-based tips mapping
  Map<String, List<Map<String, dynamic>>> weatherBasedTips = {
    'Clear': [
      {
        'title': 'Sunny Day Care',
        'content': 'Water your cassava plants early morning or late evening to prevent evaporation',
        'icon': Icons.wb_sunny,
      },
      {
        'title': 'Heat Protection',
        'content': 'Apply mulch to protect roots from excessive heat',
        'icon': Icons.thermostat,
      },
    ],
    'Rain': [
      {
        'title': 'Wet Weather Alert',
        'content': 'Check drainage systems and monitor for disease development',
        'icon': Icons.umbrella,
      },
    ],
    'Clouds': [
      {
        'title': 'Cloudy Conditions',
        'content': 'Good time for fertilizer application as less risk of nutrient burn',
        'icon': Icons.cloud,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Weather & Tips',
          style: TextStyle(color: Color(0xFF5D7C4A), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5D7C4A)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchWeatherData();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF6FAF3), Colors.white],
                    ),
                  ),
                  child: RefreshIndicator(
                    onRefresh: fetchWeatherData,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildWeatherCard(),
                        const SizedBox(height: 20),
                        _buildWeatherBasedTips(),
                        const SizedBox(height: 20),
                        _buildGeneralTips(),
                      ],
                    ),
                  ),
                ),
    );
  }

  // Update your _buildWeatherCard() method
  Widget _buildWeatherCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Weather',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D7C4A),
                  ),
                ),
                Text(
                  weatherData!['condition'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherInfo('Temperature', weatherData!['temperature'], Icons.thermostat),
                _buildWeatherInfo('Humidity', weatherData!['humidity'], Icons.water_drop),
                _buildWeatherInfo('Rainfall', weatherData!['rainfall'], Icons.umbrella),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: const Color(0xFF5D7C4A)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherBasedTips() {
    final currentCondition = weatherData?['condition'];
    final tips = weatherBasedTips[currentCondition] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Today\'s Recommendations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D7C4A),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...tips.map((tip) => _buildTipCard(
              tip['title'],
              tip['content'],
              tip['icon'],
            )),
      ],
    );
  }

  Widget _buildGeneralTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'General Care Tips',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D7C4A),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          'Regular Monitoring',
          'Check your cassava plants weekly for any signs of diseases or pest infestations',
          Icons.remove_red_eye,
        ),
        _buildTipCard(
          'Soil Health',
          'Maintain good soil fertility through proper fertilization and organic matter management',
          Icons.grass,
        ),
      ],
    );
  }

  Widget _buildTipCard(String title, String content, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF5D7C4A)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}