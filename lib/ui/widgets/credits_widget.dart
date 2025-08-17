import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsWidget extends StatelessWidget {
  final Color? textColor;
  const CreditsWidget({super.key, this.textColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()=> launchUrl(Uri.parse("https://www.bamits.com/")),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: RichText(
          text: TextSpan(
            text: "Developed by ",
            style: TextStyle(fontSize: 8, color: textColor),
            children: const [
              TextSpan(
                text: "UENR_IT 26 © 2025",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 41, 62, 80),
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
