import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class NetworkService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("network_status");
  final Uuid _uuid = Uuid();

  /// Collect and Store User's Network Information
  Future<void> collectNetworkStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint("❌ No user is logged in. Skipping network data collection.");
      return;
    }

    try {
      debugPrint("📡 Collecting network data for user: ${currentUser.uid}");

      String networkType = await _getNetworkType();
      String isp = await _getISPName();
      double speedMbps = await _testNetworkSpeed();

      debugPrint("✅ Network Type: $networkType");
      debugPrint("✅ ISP: $isp");
      debugPrint("✅ Speed: $speedMbps Mbps");

      // Generate a unique ID for this record
      String recordId = _uuid.v4();

      // Store Data in Firebase
      await _dbRef.child(recordId).set({
        "record_ID": recordId,
        "user_ID": currentUser.uid,
        "network_type": networkType,
        "speed_mbps": speedMbps,
        "isp": isp,
        "timestamp": ServerValue.timestamp,
      });

      debugPrint("✅ Network data stored successfully with ID: $recordId");
    } catch (e) {
      debugPrint("❌ Error storing network data: $e");
    }
  }

Future<bool> isNetworkGoodEnough({double thresholdMbps = 0.3}) async {
  try {
    String type = await _getNetworkType();
    double speed = await _testNetworkSpeed();

    debugPrint("📊 Network Check — Type: $type, Speed: $speed Mbps");

    // Simple logic: return true if speed meets threshold and connection is valid
    return type != "No Connection" && speed >= thresholdMbps;
  } catch (e) {
    debugPrint("❌ Network evaluation failed: $e");
    return false;
  }
}


  /// Get Network Type (Wi-Fi, Mobile Data, etc.)
Future<String> _getNetworkType() async {
  try {
    final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    debugPrint("📶 Connectivity Results: $results");

    if (results.contains(ConnectivityResult.wifi)) {
      return "Wi-Fi";
    } else if (results.contains(ConnectivityResult.mobile)) {
      return "Mobile Data";
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return "Ethernet";
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      return "Bluetooth";
    } else if (results.contains(ConnectivityResult.none)) {
      return "No Connection";
    } else {
      return "Unknown";
    }
  } catch (e) {
    debugPrint("❌ Error detecting network type: $e");
    return "Unknown";
  }
}

  Future<String> _getISPName() async {
    try {
      final result = await InternetAddress.lookup("google.com");
      debugPrint("🌍 ISP Lookup Result: $result");
      return result.isNotEmpty ? result.first.host : "Unknown ISP";
    } catch (e) {
      debugPrint("❌ Error getting ISP: $e");
      return "Unknown ISP";
    }
  }


  Future<double> _testNetworkSpeed() async {
    try {
      final Uri url = Uri.parse("https://speed.cloudflare.com/__down?bytes=100000"); // 100KB
      final Stopwatch stopwatch = Stopwatch()..start();

      final HttpClient httpClient = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5); // ⏱ Emergency-safe timeout
      final HttpClientRequest request = await httpClient.getUrl(url);
      final HttpClientResponse response = await request.close();

      final Uint8List data = await consolidateHttpClientResponseBytes(response);
      stopwatch.stop();

      if (data.isEmpty) {
        debugPrint("❌ No data downloaded.");
        return 0.0;
      }

      final double fileSizeMb = (data.lengthInBytes * 8) / (1024 * 1024); // bits → megabits
      final double speedMbps = fileSizeMb / (stopwatch.elapsedMilliseconds / 1000);

      debugPrint("🚀 Quick speed test: ${speedMbps.toStringAsFixed(2)} Mbps");
      return double.parse(speedMbps.toStringAsFixed(2));
    } catch (e) {
      debugPrint("❌ Speed test failed (likely timeout or poor net): $e");
      return 0.0;
    }
  }

}
