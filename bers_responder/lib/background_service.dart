import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
import 'package:meta/meta.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  print("Background service started!");

  // Initialize Firebase in the background
  await Firebase.initializeApp(); // Initialize Firebase before accessing any Firebase services
  print("Firebase initialized in the background");

  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Location _location = Location();

    bool serviceEnabled = false;
    try {
      serviceEnabled = await _location.serviceEnabled();
    } catch (e) {
      print("⚠️ Error checking service status: $e");
      return;
    }

  if (!serviceEnabled) {
    // Try to enable the location service
    serviceEnabled = await _location.requestService();
    if (!serviceEnabled) {
      print("Location service is not enabled. Retrying...");
      // Retry the service enabling process after a delay
      await Future.delayed(Duration(seconds: 3)); // Retry after a short delay
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        print("Location service is still not enabled after retry.");
        return;
      }
    }
  }

  // Request location permission
  PermissionStatus _permissionGranted = await _location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    // If the permission is denied, request permission
    _permissionGranted = await _location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      print("Location permission denied.");
      return;
    }
  }


  // Periodic task every 10 seconds
  Timer.periodic(Duration(seconds: 10), (timer) async {
    print("Updating location...");
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        final user = _auth.currentUser;
        if (user == null) {
          print("User is not authenticated.");
          return;
        }

        try {
          // Get current location
          final locationData = await _location.getLocation();
          
          if (locationData.latitude == null || locationData.longitude == null) {
            print("Failed to get valid location.");
            return;
          }

          final responderRef = _db.ref("responder_unit");

          // Update responder location in the database
          await responderRef.child(user.uid).update({
            "latitude": locationData.latitude,
            "longitude": locationData.longitude,
            "timestamp": DateTime.now().toIso8601String(),
          });

          print("✅ Location updated in background: ${locationData.latitude}, ${locationData.longitude}");
        } catch (e) {
          print("Error updating location: $e");
        }
      }
    }
  });
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      notificationChannelId: "emergency_tracking", // Channel ID for notifications
      initialNotificationTitle: "Emergency Response Active",
      initialNotificationContent: "Tracking location...",
      foregroundServiceNotificationId: 888, // Unique notification ID
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      autoStart: true,
    ),
  );

  // Start the service after configuration
  await service.startService();
}
