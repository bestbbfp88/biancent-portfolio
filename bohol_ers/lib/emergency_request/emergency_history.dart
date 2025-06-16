// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart'; // 📅 For formatting timestamps

class EmergencyHistoryScreen extends StatefulWidget {
  const EmergencyHistoryScreen({super.key});

  @override
  _EmergencyHistoryScreenState createState() => _EmergencyHistoryScreenState();
}

class _EmergencyHistoryScreenState extends State<EmergencyHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _emergencyHistoryFuture;

  @override
  void initState() {
    super.initState();
    _emergencyHistoryFuture = fetchEmergencyHistory();
  }

  /// 🔹 Fetch Emergency Requests from Firebase
  Future<List<Map<String, dynamic>>> fetchEmergencyHistory() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    try {
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref("emergencies");
      final DataSnapshot snapshot = await dbRef.get();

      if (!snapshot.exists || snapshot.value == null) return [];

      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      List<Map<String, dynamic>> emergencyHistory = [];

      // ✅ Loop through each emergency request ID (e.g., "OK4Hac_oQoZAuFuHk9n")
      data.forEach((requestId, requestData) {
        if (requestData is Map && requestData.containsKey('user_ID')) {
          if (requestData['user_ID'] == currentUser.uid) {
            emergencyHistory.add({
              "id": requestId, // Request ID (e.g., "OK4Hac_oQoZAuFuHk9n")
              "date_time": requestData['date_time'] ?? 'Unknown Date',
              "location": requestData['location'] ?? 'Unknown Location',
              "report_Status": requestData['report_Status'] ?? 'Pending',
              "is_User": requestData['is_User'] ?? 'Unknown User',
              "latitude": requestData['live_es_latitude'] ?? 0.0,
              "longitude": requestData['live_es_longitude'] ?? 0.0,
            });
          }
        }
      });

      return emergencyHistory.reversed.toList(); // 🔄 Show most recent first
    } catch (e) {
      debugPrint('❌ Error fetching emergency history: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emergency History")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _emergencyHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No emergency history found."));
          }

          final emergencyRequests = snapshot.data!;

          return ListView.builder(
            itemCount: emergencyRequests.length,
            itemBuilder: (context, index) {
              final request = emergencyRequests[index];
              String formattedDate = request['date_time'] != 'Unknown Date'
                  ? DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(request['date_time']))
                  : 'Unknown Date';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text(request['location'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Status: ${request['report_Status']}\nDate: $formattedDate"),
                  
                ),
              );
            },
          );
        },
      ),
    );
  }
}
