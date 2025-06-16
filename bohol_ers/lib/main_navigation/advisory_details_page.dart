import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdvisoryDetailPage extends StatelessWidget {
  final String headline;
  final String imageUrl;
  final String message;
  final String createdAt;

  const AdvisoryDetailPage({
    super.key,
    required this.headline,
    required this.imageUrl,
    required this.message,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime parsedDate = DateTime.tryParse(createdAt) ?? DateTime.now();
    final String formattedDate = DateFormat('MMMM dd, yyyy – HH:mm').format(parsedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Advisory",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔵 Category Tag and Date
              Row(
                children: [
                 
                  const SizedBox(width: 10),
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 📰 Headline
              Text(
                headline,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const SizedBox(height: 20),

              // 📸 Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),

              const SizedBox(height: 20),

              // 📝 Message Body
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
