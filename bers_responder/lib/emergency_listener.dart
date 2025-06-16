// emergency_listener.dart
import 'package:bers_responder/services/location_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latLng;
import '../models/emergency_model.dart';
import '../services/route_service.dart';
import '../services/firebase_service.dart';
import '../services/route_service.dart';
import 'map_controller_service.dart';
import '../secrets.dart';

class EmergencyListener {
  final FirebaseService firebaseService;
  final RouteService routeService;
  final FirebaseAuth auth;
  final Function(Emergency?, bool, RouteData?) onEmergencyUpdate;
  final Function() onEmergencyCleared;

  EmergencyListener({
    required this.firebaseService,
    required this.routeService,
    required this.auth,
    required this.onEmergencyUpdate,
    required this.onEmergencyCleared,
  });

void listenToEmergencies() {
  firebaseService.getEmergencyStreamFromResponderUnits().listen((emergencies) async {
    debugPrint("📡 EmergencyListener received ${emergencies.length} emergencies");

    if (emergencies.isNotEmpty) {
      for (var emergencyMap in emergencies) {
        debugPrint("🆕 Incoming emergency data: $emergencyMap");

        final emergency = Emergency.fromMap(emergencyMap["emergencyId"], emergencyMap);
        final isTracking = emergency.status == "Responding";

        final route = await _fetchRouteIfNeeded(emergency);
        debugPrint("🗺️ Route fetched: ${route?.distance}, ${route?.duration}");

        onEmergencyUpdate(emergency, isTracking, route);
        return; // only process one emergency
      }
    } else {
      debugPrint("❌ No active emergencies. Triggering clear handler.");
      onEmergencyCleared();
    }
  });
}

  Future<RouteData?> _fetchRouteIfNeeded(Emergency emergency) async {
    final currentLocation = await LocationService().getCurrentLocation();
    if (currentLocation == null || emergency.latitude == null || emergency.longitude == null) {
      return null;
    }

    final routes = await routeService.fetchRoutes(
      currentLocation,
      latLng.LatLng(emergency.latitude, emergency.longitude),
      openRouteServiceApiKey,
    );

    return routes.isNotEmpty ? routes.first : null;
  }
}
