import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_disease_detection/ui/screens/onboarding_page.dart';
import 'package:plant_disease_detection/providers/theme_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      home: OnboardingPage(),
      theme: lightTheme.copyWith(
        colorScheme: lightTheme.colorScheme.copyWith(
          primary: const Color.fromARGB(255, 31, 37, 37),
          secondary: const Color.fromARGB(255, 89, 117, 117),
        ),
      ),
      darkTheme: darkTheme.copyWith(
        colorScheme: darkTheme.colorScheme.copyWith(
          primary: const Color.fromARGB(255, 168, 205, 226),
          secondary: const Color.fromARGB(255, 184, 233, 245),
        ),
      ),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}
