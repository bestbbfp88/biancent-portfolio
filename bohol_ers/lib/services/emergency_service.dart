import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../emergency_request/dispatcher_tracking.dart';
import '../services/network_service.dart';

final NetworkService _networkService = NetworkService();

class EmergencyService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final LocationService _locationService = LocationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _locationUpdateTimer;


  EmergencyService() {
    _dbRef.keepSynced(true); // Offline sync
  }

Future<void> sendEmergencyData(BuildContext context, String type) async {
  _showLoadingDialog(context);
  try {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final userId = user.uid;
    final result = await _locationService.getCurrentLocation();
    if (result == null) throw Exception("Location unavailable");

    final position = result.position; // ✅ Extract the Position from result

    final emergencyId = await _getOrCreateEmergencyID();

    // 🔹 Step 1: Send coordinates first (critical)
    await _dbRef.child('emergencies/$emergencyId').update({
      'report_ID': emergencyId,
      'user_ID': userId,
      'live_es_latitude': position.latitude,
      'live_es_longitude': position.longitude,
      'live_es_accuracy': position.accuracy,
      'date_time': DateTime.now().toIso8601String(),
      'report_Status': 'Pending',
      'is_User': type,
    });
    // 🔹 Step 2: Send details in background
    unawaited(_sendEmergencyDetails(emergencyId, userId));

    if (context.mounted) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DispatcherTracking(emergencyId: emergencyId)),
      );
    }
  } catch (e) {
    print("❌ Location-only submission failed: $e");
    if (context.mounted) {
      Navigator.pop(context);
      _showErrorDialog(context, "Failed to send coordinates. Please check your internet.");
    }
  }
}


  Future<void> _sendEmergencyDetails(String emergencyId, String userId) async {
    try {
      _networkService.collectNetworkStatus();
      final locationAddress = await _locationService.getAddress();

      final medicalQuery = _dbRef.child("medical")
        .orderByChild("user_ID")
        .equalTo(userId)
        .limitToLast(1);
      final snapshot = await medicalQuery.once();
      final medicalId = snapshot.snapshot.children.firstOrNull?.key;

      await _dbRef.child('emergencies/$emergencyId').update({
        'medical_ID': medicalId,
        'location': locationAddress,
        'reponder_ID': null,
        'dispatch_ID': null,
        'formA_ID': null,
      });

      await _removeStoredEmergencyId();
    } catch (e) {
      print("⚠️ Failed to send emergency details: $e");
    }
  }

  Future<String> _getOrCreateEmergencyID() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('pending_emergency_id');

    if (id == null || id.isEmpty) {
      id = _dbRef.child('emergencies').push().key!;
      await prefs.setString('pending_emergency_id', id);
    }

    return id;
  }

  Future<void> _removeStoredEmergencyId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_emergency_id');
  }


  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[50],
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(height: 80, width: 80, child: CircularProgressIndicator(strokeWidth: 4)),
            SizedBox(height: 20),
            Text("Submitting Emergency Report...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text("Please wait while we process your request.", textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Error', style: TextStyle(color: Colors.red)),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}
