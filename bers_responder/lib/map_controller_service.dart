// map_controller_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as latLng;
import 'dart:math';

class MapControllerService {
  static void zoomToResponderLocation({
    required fm.MapController mapController,
    required latLng.LatLng location,
    double zoom = 19.0,
  }) {
    mapController.move(location, zoom);
  }

  static Future<void> zoomToResponderAndEmergency({
    required fm.MapController mapController,
    required latLng.LatLng responderLocation,
    required latLng.LatLng emergencyLocation,
    double padding = 80.0,
  }) async {
    final bounds = fm.LatLngBounds.fromPoints([
      responderLocation,
      emergencyLocation,
    ]);

    final cameraFit = fm.CameraFit.bounds(
      bounds: bounds,
      padding: EdgeInsets.all(padding),
    );

    mapController.fitCamera(cameraFit);
  }

  static fm.LatLngBounds getLatLngBounds(latLng.LatLng p1, latLng.LatLng p2) {
    return fm.LatLngBounds(
      latLng.LatLng(
        min(p1.latitude, p2.latitude),
        min(p1.longitude, p2.longitude),
      ),
      latLng.LatLng(
        max(p1.latitude, p2.latitude),
        max(p1.longitude, p2.longitude),
      ),
    );
  }
}
