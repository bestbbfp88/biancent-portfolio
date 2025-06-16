import 'package:bohol_emergency_response_system/main_navigation/advisory_details_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdvisoryPage extends StatefulWidget {
  const AdvisoryPage({super.key});

  @override
  State<AdvisoryPage> createState() => _AdvisoryPageState();
}

class _AdvisoryPageState extends State<AdvisoryPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('advisories');
  String selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes back button
        backgroundColor: Colors.white,
        elevation: 0, // Removes shadow
        centerTitle: true,
        title: const Text(
          'NEWS',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.red,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search News...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.orange),
                  onPressed: () {}, // Implement search action
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 🔹 Latest News Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Latest News",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),

          // 🔹 Fetch & Display Latest News from Firebase
          SizedBox(
            height: 180,
            child: FutureBuilder<DataSnapshot>(
              future: _dbRef.get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null || snapshot.data!.value == null) {
                  return const Center(child: Text('No latest news available.'));
                }

                Map<dynamic, dynamic> advisoriesData = snapshot.data!.value as Map<dynamic, dynamic>;

                List<Map<String, dynamic>> advisoryList = advisoriesData.entries
                  .map((entry) => entry.value as Map<dynamic, dynamic>)
                  .where((data) => data["advisory_status"] == "Active")
                  .map((data) => {
                    "headline": data["headline"] ?? "No headline",
                    "image_url": data["image_url"] ?? "",
                    "message": data["message"] ?? "No details available",
                    "timestamp": data["timestamp"] ?? 0,
                  })
                  .toList();


                advisoryList.sort((a, b) => (b["timestamp"] as int).compareTo(a["timestamp"] as int));

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: advisoryList.length,
                  itemBuilder: (context, index) {
                    final advisory = advisoryList[index];
                    return _buildNewsCard(advisory["image_url"], advisory["headline"]);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 Categories Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryButton("All", isSelected: selectedCategory == "All"),
                _buildCategoryButton("Weather", isSelected: selectedCategory == "Weather"),
                _buildCategoryButton("Health", isSelected: selectedCategory == "Health"),
                _buildCategoryButton("Incidents", isSelected: selectedCategory == "Incidents"),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 🔹 List of News Items
          Expanded(
            child: FutureBuilder<DataSnapshot>(
              future: _dbRef.get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null || snapshot.data!.value == null) {
                  return const Center(child: Text('No advisories available.'));
                }

                Map<dynamic, dynamic> advisoriesData = snapshot.data!.value as Map<dynamic, dynamic>;

                List<Map<String, dynamic>> advisoryList = advisoriesData.entries
                  .map((entry) => entry.value as Map<dynamic, dynamic>)
                  .where((data) => data["advisory_status"] == "Active")
                  .map((data) => {
                    "headline": data["headline"] ?? "No headline",
                    "image_url": data["image_url"] ?? "",
                    "message": data["message"] ?? "No details available",
                    "timestamp": data["timestamp"] ?? 0,
                  })
                  .toList();


                advisoryList.sort((a, b) => (b["timestamp"] as int).compareTo(a["timestamp"] as int));

               return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: advisoryList.length,
                itemBuilder: (context, index) {
                  final advisory = advisoryList[index];
                  
                  // Use default values in case of null
                  final headline = advisory["headline"] ?? "No headline available";
                  final imageUrl = advisory["image_url"] ?? "";
                  final message = advisory["message"] ?? "No details available";

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: SizedBox(
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset("assets/images/news_placeholder.jpg", fit: BoxFit.cover);
                                    },
                                  )
                                : const Icon(Icons.image, size: 40),
                          ),
                        ),

                      title: Text(
                        headline,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,  // Show message preview with ellipsis
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                        // Navigate to AdvisoryDetailPage with data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdvisoryDetailPage(
                              headline: headline,
                              imageUrl: imageUrl,
                              message: message, createdAt: '',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );

              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Builds News Item (for ListView) ✅ Removed `author`
  Widget _buildNewsItem(String imageUrl, String title) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return Image.asset("assets/images/news_placeholder.jpg", width: 80, height: 80); // Fallback image
            },
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Handle news article tap (can navigate to full details page)
        },
      ),
    );
  }

  /// 🔹 Builds Individual News Card for Latest News ✅ Removed `author`
  Widget _buildNewsCard(String imageUrl, String title) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
          ),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// 🔹 Category Button Builder
  Widget _buildCategoryButton(String text, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
