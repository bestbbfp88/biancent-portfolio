import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Legal Information")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Terms of Service",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '''Effective Date: April 13, 2025
Last Updated: April 13, 2025

Welcome to the Bohol Emergency Response System (BERS) application. These Terms of Service ("Terms") govern your use of the BERS mobile and web platforms ("App", "Service", or "Platform") provided by the Bohol Emergency Response Team ("we", "our", or "us").

By accessing or using the App, you agree to be bound by these Terms. If you do not agree with any part of these Terms, you may not use our Service.''',
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 16),
            sectionTitle("1. Purpose of the App"),
            sectionBody(
              "The BERS App facilitates real-time emergency reporting, coordination of emergency response units, live location tracking, and communication between users and responders within the province of Bohol.",
            ),

            sectionTitle("2. Eligibility"),
            sectionBody(
              "You must be at least 13 years old to use the App. Users acting as emergency responders or administrators must be verified and approved by the Bohol Emergency Response System management.",
            ),

            sectionTitle("3. User Responsibilities"),
            sectionBody(
              "You agree to use the App only for lawful and legitimate emergency-related purposes, provide accurate information, and keep your credentials secure.",
            ),

            sectionTitle("4. Account Registration"),
            sectionBody(
              "To use certain features, you may be required to register for an account. You are responsible for all activity under your account.",
            ),

            sectionTitle("5. Privacy and Data"),
            sectionBody(
              "Your use of the App is governed by our Privacy Policy, which explains how we collect, use, and protect your data, including location and reports.",
            ),

            sectionTitle("6. Emergency Response Disclaimer"),
            sectionBody(
              "BERS facilitates emergency communication but does not guarantee response times or the availability of responders. Always call TaRSIER 117 in life-threatening situations.",
            ),

            sectionTitle("7. Prohibited Conduct"),
            sectionBody(
              "You must not submit false emergencies, harass others, gain unauthorized access to systems, or misuse the platform.",
            ),

            sectionTitle("8. Intellectual Property"),
            sectionBody(
              "All content and branding on the App belongs to BERS and its partners. You may not use it without permission.",
            ),

            sectionTitle("9. Termination"),
            sectionBody(
              "We may suspend or terminate your account if you violate these Terms or misuse the app's features.",
            ),

            sectionTitle("10. Limitation of Liability"),
            sectionBody(
              "BERS is not liable for delays, service interruptions, or any indirect damages resulting from app use.",
            ),

            sectionTitle("11. Modifications to Terms"),
            sectionBody(
              "We may update these Terms from time to time. Continued use of the App implies agreement to the latest version.",
            ),

            sectionTitle("12. Governing Law"),
            sectionBody(
              "These Terms are governed by the laws of the Republic of the Philippines. Legal disputes shall be settled in Bohol courts.",
            ),

            sectionTitle("13. Contact Us"),
            sectionBody(
              "For legal concerns, email us at: bershnu@gmail.com or call (038) 411-1234.",
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets for styling
  static Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  static Widget sectionBody(String content) {
    return Text(
      content,
      textAlign: TextAlign.justify,
      style: const TextStyle(fontSize: 14),
    );
  }
}
