// // models/route_data.dart
// import 'package:latlong2/latlong.dart';

// class RouteData {
//   final String duration;
//   final String distance;
//   final List<LatLng> geometry;
//   final List<dynamic> steps;

//   RouteData({
//     required this.duration,
//     required this.distance,
//     required this.geometry,
//     required this.steps,
//   });

//   factory RouteData.fromOpenRouteService(Map<String, dynamic> json) {
//     final summary = json['summary'];
//     final geometryRaw = json['geometry'] as List<dynamic>;
//     final stepsRaw = json['steps'] as List<dynamic>;

//     final decodedGeometry = geometryRaw.map<LatLng>((point) {
//       return LatLng(point[1], point[0]); // lat, lng
//     }).toList();

//     return RouteData(
//       duration: _formatDuration(summary['duration']),
//       distance: _formatDistance(summary['distance']),
//       geometry: decodedGeometry,
//       steps: stepsRaw,
//     );
//   }

//   static String _formatDuration(dynamic seconds) {
//     if (seconds == null) return '';
//     final duration = Duration(seconds: seconds.round());
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     return hours > 0 ? '$hours hour${hours > 1 ? 's' : ''} $minutes min' : '$minutes min';
//   }

//   static String _formatDistance(dynamic meters) {
//     if (meters == null) return '';
//     if (meters >= 1000) {
//       return "${(meters / 1000).toStringAsFixed(1)} km";
//     } else {
//       return "${meters.toStringAsFixed(0)} m";
//     }
//   }
// }
