// import 'dart:convert';
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart' as latLng;

// class RouteService {
//   final int maxRetries = 3;
//   final Duration retryDelay = const Duration(seconds: 1);

//   latLng.LatLng? _lastStart;
//   latLng.LatLng? _lastEnd;
//   List<RouteData>? _cachedRoutes;

//   bool _areCoordsEqual(latLng.LatLng a, latLng.LatLng b, {double tolerance = 0.0001}) {
//     return (a.latitude - b.latitude).abs() < tolerance &&
//            (a.longitude - b.longitude).abs() < tolerance;
//   }

//   latLng.LatLng _roundCoord(latLng.LatLng coord) {
//     double round(double value) => double.parse(value.toStringAsFixed(5));
//     return latLng.LatLng(round(coord.latitude), round(coord.longitude));
//   }

//   Future<List<RouteData>> fetchRoutes(
//     latLng.LatLng start,
//     latLng.LatLng end,
//     String apiKey,
//   ) async {
//     // Normalize input for consistent comparison
//     final roundedStart = _roundCoord(start);
//     final roundedEnd = _roundCoord(end);

//     if (_lastStart != null &&
//         _lastEnd != null &&
//         _areCoordsEqual(_lastStart!, roundedStart) &&
//         _areCoordsEqual(_lastEnd!, roundedEnd)) {
//       print("🧊 Using cached route.");
//       return _cachedRoutes ?? [];
//     }

//     final url = Uri.parse("https://api.openrouteservice.org/v2/directions/driving-car/geojson");

//     final body = {
//       "coordinates": [
//         [roundedStart.longitude, roundedStart.latitude],
//         [roundedEnd.longitude, roundedEnd.latitude]
//       ]
//     };

//     int attempts = 0;

//     while (attempts < maxRetries) {
//       try {
//         final response = await http.post(
//           url,
//           headers: {
//             'Authorization': apiKey,
//             'Content-Type': 'application/json',
//           },
//           body: jsonEncode(body),
//         );

//         final status = response.statusCode;
//         final responseBody = response.body;

//         if (status == 200) {
//           final data = jsonDecode(responseBody);

//           if (data['features'] != null &&
//               data['features'] is List &&
//               data['features'].isNotEmpty &&
//               data['features'][0]['geometry'] != null &&
//               data['features'][0]['properties'] != null &&
//               data['features'][0]['properties']['segments'] != null) {

//             final segment = data['features'][0]['properties']['segments'][0];
//             final coordinates = data['features'][0]['geometry']['coordinates'];

//             final routes = [
//               RouteData(
//                 duration: "${(segment['duration'] / 60).round()} min",
//                 distance: "${(segment['distance'] / 1000).toStringAsFixed(2)} km",
//                 polyline: coordinates.toString(),
//                 steps: segment['steps'] ?? [],
//                 geometry: List<latLng.LatLng>.from(
//                   coordinates.map((coord) => latLng.LatLng(coord[1], coord[0])),
//                 ),
//               ),
//             ];

//             // ✅ Save to cache using rounded values
//             _lastStart = roundedStart;
//             _lastEnd = roundedEnd;
//             _cachedRoutes = routes;

//             return routes;
//           }
//         } else if (status == 429) {
//           print("❌ Rate limit hit (429). Retrying in 2 seconds...");
//           break;
//         } else {
//           print("❌ Failed with status $status: $responseBody");
//         }
//       } catch (e) {
//         print("❌ Exception on attempt ${attempts + 1}: $e");
//       }

//       attempts++;
//       await Future.delayed(retryDelay);
//     }

//     print("❌ Failed to fetch route after $maxRetries attempts.");
//     return [];
//   }
// }

// class RouteData {
//   final String duration;
//   final String distance;
//   final String polyline;
//   final List<dynamic> steps;
//   final List<latLng.LatLng> geometry;

//   RouteData({
//     required this.duration,
//     required this.distance,
//     required this.polyline,
//     required this.steps,
//     required this.geometry,
//   });
// }
