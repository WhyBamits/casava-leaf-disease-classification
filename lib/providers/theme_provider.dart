import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = state == ThemeMode.dark;
    await prefs.setBool('isDarkMode', !isDark);
    state = isDark ? ThemeMode.light : ThemeMode.dark;
  }
}

// Light theme
final lightTheme = ThemeData(
  useMaterial3: true,
  primaryColor: const Color(0xFF5D7C4A),
  scaffoldBackgroundColor: const Color(0xFFF6FAF3),
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF5D7C4A),
    secondary: Colors.green[700]!,
    background: const Color(0xFFF6FAF3),
    surface: Colors.white,
    onSurface: Colors.black87,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green[700],
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Colors.white,
  ),
  listTileTheme: ListTileThemeData(
    iconColor: Colors.green[700],
    textColor: Colors.black87,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black87),
    titleMedium: TextStyle(color: Colors.black87),
    titleLarge: TextStyle(color: Colors.black87),
  ),
  iconTheme: IconThemeData(
    color: Colors.green[700],
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.green[700],
    unselectedItemColor: Colors.grey,
  ),
);

// Dark theme
final darkTheme = ThemeData(
  useMaterial3: true,
  primaryColor: const Color(0xFF5D7C4A),
  scaffoldBackgroundColor: const Color(0xFF121212),
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF5D7C4A),
    secondary: Colors.green[700]!,
    background: const Color(0xFF121212),
    surface: const Color(0xFF1E1E1E),
    onSurface: Colors.white70,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green[900],
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  cardTheme: CardTheme(
    color: const Color(0xFF1E1E1E),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF1E1E1E),
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: Color(0xFF7CB342),
    textColor: Colors.white70,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white70),
    bodyMedium: TextStyle(color: Colors.white70),
    titleMedium: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(color: Colors.white70),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFF7CB342),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    selectedItemColor: Colors.green[400],
    unselectedItemColor: Colors.grey,
  ),
);
