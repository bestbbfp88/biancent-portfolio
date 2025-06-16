import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart' as latLng;
import '../secrets.dart';

class LocationService {
  final Location _location = Location();

Future<bool> requestLocationPermission() async {
  bool serviceEnabled = await _location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await _location.requestService();
    if (!serviceEnabled) return false;
  }

  var permissionGranted = await _location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await _location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) return false;
  }

  // ✅ Set location update frequency and precision
  _location.changeSettings(
    accuracy: LocationAccuracy.high,
    interval: 1000,       // every 1 second
    distanceFilter: 1,    // every 1 meter of movement
  );

  return true;
}


  Stream<LocationData> get locationStream => _location.onLocationChanged;

  Future<String> getAddressFromLatLng(latLng.LatLng position) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'YourAppName/1.0 (your@email.com)',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['display_name'] ?? 'Unknown address';
      } else {
        print('🌐 Nominatim Error: ${response.statusCode}');
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      print('❌ Nominatim Exception: $e');
      return 'Error: $e';
    }
  }

  Future<latLng.LatLng?> getCurrentLocation() async {
    try {
      final data = await _location.getLocation();
      if (data.latitude != null && data.longitude != null) {
        return latLng.LatLng(data.latitude!, data.longitude!);
      }
    } catch (e) {
      print("❌ Error getting current location: $e");
    }
    return null;
  }
}

class RouteService {
  final int maxRetries = 3;
  final Duration retryDelay = const Duration(seconds: 1);
  final _distanceCalc = latLng.Distance();

  latLng.LatLng? _lastStart;
  latLng.LatLng? _lastEnd;
  double? _lastBearing;
  List<RouteData>? _cachedRoutes;

  // Reset the cache manually if needed
  void clearRouteCache() {
    _lastStart = null;
    _lastEnd = null;
    _lastBearing = null;
    _cachedRoutes = null;
    print("🧹 Route cache cleared.");
  }

  // Calculate bearing in degrees
  double _calculateBearing(latLng.LatLng start, latLng.LatLng end) {
    final dLon = (end.longitude - start.longitude) * (pi / 180);
    final lat1 = start.latitude * (pi / 180);
    final lat2 = end.latitude * (pi / 180);

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final bearing = atan2(y, x) * (180 / pi);

    return (bearing + 360) % 360;
  }

  // Round coordinates for cleaner API calls
  latLng.LatLng _roundCoord(latLng.LatLng coord) {
    double round(double value) => double.parse(value.toStringAsFixed(5));
    return latLng.LatLng(round(coord.latitude), round(coord.longitude));
  }

  bool _isOffRoute(latLng.LatLng current, List<latLng.LatLng> geometry, double thresholdMeters) {
  for (final point in geometry) {
    final dist = _distanceCalc(current, point);
    if (dist < thresholdMeters) return false; // Still on path
  }
  print("🚨 Detected off-route!");
  return true;
}


  Future<List<RouteData>> fetchRoutes(
    latLng.LatLng start,
    latLng.LatLng end,
    List<String> apiKeys,
  ) async {
    final currentBearing = _calculateBearing(start, end);
    final movedEnough = _lastStart == null || _distanceCalc(start, _lastStart!) > 3;
    final destinationChanged = _lastEnd == null || _distanceCalc(end, _lastEnd!) > 5;
    final bearingChanged = _lastBearing == null ||
        (currentBearing - _lastBearing!).abs() > 10;

    print("📍 Route Check:");
    print("- Moved: ${_lastStart != null ? _distanceCalc(start, _lastStart!).toStringAsFixed(2) : 'N/A'} m");
    print("- Dest Changed: ${_lastEnd != null ? _distanceCalc(end, _lastEnd!).toStringAsFixed(2) : 'N/A'} m");
    print("- Bearing Change: ${_lastBearing != null ? (currentBearing - _lastBearing!).abs().toStringAsFixed(2) : 'N/A'}°");

   bool isOffRoute = _cachedRoutes != null &&
    _isOffRoute(start, _cachedRoutes!.first.geometry, 5) ||
    (_lastBearing != null && (currentBearing - _lastBearing!).abs() > 15);

  if (!movedEnough && !destinationChanged && !bearingChanged && _cachedRoutes != null && !isOffRoute) {
    print("🧊 Using cached route: no significant movement/change.");
    return _cachedRoutes!;
  }

    print("📡 Fetching new route...");
    final roundedStart = _roundCoord(start);
    final roundedEnd = _roundCoord(end);
    final url = Uri.parse("https://api.openrouteservice.org/v2/directions/driving-car/geojson");

    final body = {
      "coordinates": [
        [roundedStart.longitude, roundedStart.latitude],
        [roundedEnd.longitude, roundedEnd.latitude],
      ]
    };

    for (int attempts = 0; attempts < maxRetries; attempts++) {
      for (final apiKey in apiKeys) {
        try {
          final response = await http.post(
            url,
            headers: {
              'Authorization': apiKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final segment = data['features'][0]['properties']['segments'][0];
            final coordinates = data['features'][0]['geometry']['coordinates'];

            final routes = [
              RouteData(
                duration: "${(segment['duration'] / 60).round()} min",
                distance: "${(segment['distance'] / 1000).toStringAsFixed(2)} km",
                polyline: coordinates.toString(),
                steps: segment['steps'] ?? [],
                geometry: List<latLng.LatLng>.from(
                  coordinates.map((coord) => latLng.LatLng(coord[1], coord[0])),
                ),
              ),
            ];

            _lastStart = start;
            _lastEnd = end;
            _lastBearing = currentBearing;
            _cachedRoutes = routes;

            print("✅ New route fetched and cached.");
            return routes;
          } else {
            print("❌ Failed with key $apiKey | Status: ${response.statusCode}");
          }
        } catch (e) {
          print("❌ Exception with key $apiKey: $e");
        }
      }

      await Future.delayed(retryDelay);
    }

    print("❌ Failed to fetch route after $maxRetries retries.");
    return [];
  }

  Future<double> calculateTravelDistance(
    latLng.LatLng start,
    latLng.LatLng end,
    List<String> apiKeys,
  ) async {
    final routes = await fetchRoutes(start, end, apiKeys);
    if (routes.isNotEmpty) {
      final distanceStr = routes[0].distance.replaceAll(" km", "");
      return double.tryParse(distanceStr) ?? -1;
    }
    return -1;
  }
}

class RouteData {
  final String duration;
  final String distance;
  final String polyline;
  final List<dynamic> steps;
  final List<latLng.LatLng> geometry;

  RouteData({
    required this.duration,
    required this.distance,
    required this.polyline,
    required this.steps,
    required this.geometry,
  });
}