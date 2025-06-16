// map_ui_elements.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as latLng;
import '../models/emergency_model.dart';

class MapUIElements {
      static List<fm.Marker> buildMarkers({
        required latLng.LatLng? currentLocation,
        required double heading,
        required Emergency? emergency,
      }) {
        final markers = <fm.Marker>[];

        if (currentLocation != null) {
          markers.add(
            fm.Marker(
              width: 40,
              height: 40,
              point: currentLocation,
              rotate: true,
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: heading * pi / 180,
                child: Icon(
                  Icons.navigation,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
            ),
          );
        }

        if (emergency != null && emergency.latitude != null && emergency.longitude != null) {
          markers.add(
            fm.Marker(
              width: 50,
              height: 50,
              point: latLng.LatLng(emergency.latitude, emergency.longitude),
              child: Image.asset('assets/images/emergency_pin.png'),
            ),
          );
        }

        return markers;
      }


  static List<fm.CircleMarker> buildAccuracyCircle({
    required latLng.LatLng? location,
    required double accuracy,
  }) {
    if (location == null) return [];

    final safeAccuracy = accuracy.clamp(5.0, 100.0);

    return [
      fm.CircleMarker(
        point: location,
        color: Colors.blue.withOpacity(0.3),
        borderColor: Colors.blue,
        borderStrokeWidth: 1,
        radius: safeAccuracy,
      )
    ];
  }

  static IconData getDirectionIcon(int type) {
    switch (type) {
      case 0:
        return Icons.turn_left;
      case 1:
        return Icons.turn_right;
      case 10:
        return Icons.flag;
      case 11:
        return Icons.navigation;
      default:
        return Icons.directions;
    }
  }

  
}
