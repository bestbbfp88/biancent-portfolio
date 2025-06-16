// responder_location_service.dart (assumed filename)
import 'package:bers_responder/models/emergency_model.dart';
import 'package:bers_responder/secrets.dart';
import 'package:bers_responder/services/location_service.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:location/location.dart';
import '../services/firebase_service.dart';
import '../services/navigation_tts_service.dart';

class ResponderLocationService {
  final FirebaseService firebaseService;
  final LocationService locationService;
  final RouteService routeService;
  final NavigationTTSService ttsService;
  final dynamic flutterTts;

  ResponderLocationService({
    required this.firebaseService,
    required this.locationService,
    required this.ttsService,
    required this.flutterTts,
    required this.routeService,
  });

  void initializeTracking({
    required Function(latLng.LatLng location, double heading, double accuracy, double? speed) onUpdate,
    required Emergency? Function() getEmergency,
  }) async {
    final hasPermission = await locationService.requestLocationPermission();
    if (!hasPermission) return;

    locationService.locationStream.listen((data) async {
      final location = latLng.LatLng(data.latitude!, data.longitude!);
      final heading = data.heading ?? 0;
      final accuracy = data.accuracy ?? 10.0;
      final speed = data.speed;

      onUpdate(location, heading, accuracy, speed);
      await firebaseService.updateResponderLocation(location.latitude, location.longitude);

      final emergency = getEmergency();
      if (emergency != null) {
        final distance = await routeService.calculateTravelDistance(
          location,
          latLng.LatLng(emergency.latitude, emergency.longitude),
          openRouteServiceApiKey, 
        );

      }
    });
  }
}