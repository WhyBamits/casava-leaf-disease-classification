import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:plant_disease_detection/providers/theme_provider.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(left: 60, top: 56, bottom: 16),
      child: Theme(
        data: Theme.of(context),
        child: Drawer(
          elevation: 8,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(32)),
          ),
          child: ListView(
          padding: EdgeInsets.zero,
          children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/new.png'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Cassava Doctor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Theme Option
          ListTile(
            leading: Icon(
              ref.watch(themeProvider) == ThemeMode.dark 
                ? Icons.dark_mode 
                : Icons.light_mode,
              size: 28
            ),
            title: Text(
              ref.watch(themeProvider) == ThemeMode.dark 
                ? "Dark Theme" 
                : "Light Theme",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () async {
              await ref.read(themeProvider.notifier).toggleTheme();
            },
            trailing: Switch.adaptive(
              value: ref.watch(themeProvider) == ThemeMode.dark,
              onChanged: (_) async {
                await ref.read(themeProvider.notifier).toggleTheme();
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          // Language Option
          ListTile(
            leading: Icon(Icons.language, color: const Color.fromARGB(255, 43, 65, 45), size: 28),
            title: const Text(
              "Language",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              // Language switching logic to be implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language options coming soon!')),
              );
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          // Share App Option
          ListTile(
            leading: Icon(Icons.share, color: const Color.fromARGB(255, 5, 5, 5), size: 28),
            title: const Text(
              "Share App",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              Share.share('Check out this amazing Cassava Plant Disease Detection app!');
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}