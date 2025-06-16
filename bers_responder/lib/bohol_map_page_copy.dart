// import 'dart:math';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart' as fm;
// import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
// import 'package:latlong2/latlong.dart' as latLng;
// import '../secrets.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import '../models/emergency_model.dart';
// import '../services/firebase_service.dart';
// import '../services/location_service.dart';
// import '../services/route_service.dart';
// import '../widgets/info_card.dart';
// import 'package:audioplayers/audioplayers.dart';
// import '../services/navigation_tts_service.dart';

// class BoholMapPageCopy extends StatefulWidget {
//   const BoholMapPageCopy({super.key});

//   @override
//   State<BoholMapPageCopy> createState() => _BoholMapPageStateCopy();
// }

// class _BoholMapPageStateCopy extends State<BoholMapPageCopy> {
//   final FirebaseService _firebaseService = FirebaseService();
//   final LocationService _locationService = LocationService();
//   final RouteService _routeService = RouteService();
//   double? accuracy;
//   RouteData? _latestRoute;
//   double _currentHeading = 0.0;
//   int _lastSpokenStepIndex = -1;
//   double _lastHeading = 0.0;
//   double _mapRotation = 0.0;


//   final List<fm.Marker> _markers = [];
//   final List<fm.Polyline> _polylines = [];
//   final List<fm.CircleMarker> _circles = [];
//   bool _mapReady = false;
//   double _currentZoom = 18.0;
//   String _currentInstruction = "";
//   int _currentStepIndex = 0;

//   latLng.LatLng? _lastCameraPosition;
//   DateTime _lastCameraUpdate = DateTime.now();
//   Emergency? _previousEmergency;
//   bool _userInteractedWithMap = false;
//   late NavigationTTSService _ttsService;

//   late final fm.MapController _mapController = fm.MapController();
//   latLng.LatLng? _currentLocation;

//   Emergency? _assignedEmergency;
//   bool _isTracking = false;

//   String _routeDuration = "";
//   String _routeDistance = "";
  
//   late FlutterTts _flutterTts;
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   TextEditingController _declineReasonController = TextEditingController();
  
//   @override
//   void initState() {
//     super.initState();
//     _flutterTts = FlutterTts();
//     _flutterTts.setLanguage("en-US");
//     _flutterTts.setSpeechRate(0.5);
//     _ttsService = NavigationTTSService();
//     _initializeMap();
//     _listenToEmergencies();
//   }

//  Future<void> _initializeMap() async {
//   final hasPermission = await _locationService.requestLocationPermission();
//   if (!hasPermission) return;


// _locationService.locationStream.listen((locationData) async {
//   final updatedLocation = latLng.LatLng(locationData.latitude!, locationData.longitude!);
//   final heading = locationData.heading ?? 0;
//   _currentHeading = heading;
//   accuracy = locationData.accuracy ?? 10.0;

//   if (mounted) {
//     setState(() {
//       _currentLocation = updatedLocation;
//       _setupMarkers();
//       _updateDynamicCircle(accuracy!);
//     });
//   }

//   await _firebaseService.updateResponderLocation(
//     updatedLocation.latitude,
//     updatedLocation.longitude,
//   );

//   await _fetchRoute();

//   if (_isTracking && _latestRoute != null) {
//     _updateNavigationInstruction();
//   }

//   if (_isTracking) {
//     final currentToNextPoint = await _locationService.calculateTravelDistance(
//       updatedLocation,
//       latLng.LatLng(_assignedEmergency!.latitude, _assignedEmergency!.longitude),
//     );

//     if (currentToNextPoint > 100) {
//       print("🔁 Re-routing due to deviation...");
//       await _fetchRoute();
//     }

//     // ✅ Move without calling nonexistent rotateCamera
//     _mapController.move(updatedLocation, _currentZoom);

//     final distToDestination = latLng.Distance().as(
//       latLng.LengthUnit.Meter,
//       updatedLocation,
//       latLng.LatLng(
//         _assignedEmergency!.latitude,
//         _assignedEmergency!.longitude,
//       ),
//     );

//     if (distToDestination < 20) {
//         if (mounted) {
//           setState(() {
//             _isTracking = false;
//             _currentInstruction = "You have arrived.";
//           });
//         }

//         await _flutterTts.speak("You have arrived at your destination.");

//         // ✅ Automatically log arrival to Firebase
//         if (_assignedEmergency != null) {
//           final emergencyId = _assignedEmergency!.id;

//           try {
//             final emergencySnapshot = await FirebaseDatabase.instance
//                 .ref("emergencies/$emergencyId/dispatch_ID")
//                 .get();

//             if (emergencySnapshot.exists) {
//               final dispatchId = emergencySnapshot.value.toString();

//               final ticketRef =
//                   FirebaseDatabase.instance.ref("tickets/$dispatchId");

//               await ticketRef.update({
//                 "time_at_scene": ServerValue.timestamp,
//               });

//               print("✅ Arrival logged to tickets/$dispatchId → time_at_scene");
//             } else {
//               print("⚠️ No dispatch_ID found for emergency $emergencyId");
//             }
//           } catch (e) {
//             print("🚫 Error updating time_at_scene: $e");
//           }
//         }
//       }

//   } 

//   // FIX: Throttle animation & check distance moved
//     if (_isTracking && !_userInteractedWithMap && _mapController != null && mounted) {
//       final now = DateTime.now();
//       final distanceMoved = _lastCameraPosition == null
//           ? double.infinity
//           : await _locationService.calculateTravelDistance(_lastCameraPosition!, updatedLocation);

//       if (distanceMoved > 5 && now.difference(_lastCameraUpdate) > const Duration(seconds: 2)) {
//         _lastCameraPosition = updatedLocation;
//         _lastCameraUpdate = now;
        
//       _mapController.move(updatedLocation, 18);
//       }
//     }else{
//           //_zoomToResponderLocation();
//         }
//     });

// }

// void _updateNavigationInstruction() {
//   if (_latestRoute == null || _latestRoute!.steps.isEmpty || _currentStepIndex >= _latestRoute!.steps.length) return;

//   final step = _latestRoute!.steps[_currentStepIndex];
//   final lat = step['way_points'][0];
//   final coords = _latestRoute!.geometry[lat];
//   _lastSpokenStepIndex = _currentStepIndex;


//   final dist = latLng.Distance().as(
//     latLng.LengthUnit.Meter,
//     _currentLocation!,
//     coords,
//   );

//   if (dist < 30 && _currentStepIndex != _lastSpokenStepIndex) {
//     setState(() {
//       _currentInstruction = step['instruction'] ?? '';
//       _currentStepIndex++;
//     });

//     _flutterTts.speak(_currentInstruction);
//   }
// }

// void _listenToEmergencies() {
//   print("🛰️ Listening to emergencies via responder_unit...");

//   _firebaseService.getEmergencyStreamFromResponderUnits().listen((emergencies) async {
//     print("📥 Emergency stream triggered. Found: ${emergencies.length}");

//     if (emergencies.isNotEmpty) {
//       for (var emergencyMap in emergencies) {
//         print("🆔 Processing emergency: ${emergencyMap["emergencyId"]}");

//         final emergency = Emergency.fromMap(emergencyMap["emergencyId"], emergencyMap);

//         if (!mounted) {
//           print("❌ Widget not mounted. Skipping...");
//           return;
//         }

//         final isNewEmergency = _previousEmergency?.id != emergency.id;
//         print("🧾 Status: ${emergency.status}, New: $isNewEmergency");

//         if (emergency.status == "Assigning" && isNewEmergency) {
//           print("🔊 New 'Assigning' emergency detected. Playing sound...");
//           await _firebaseService.playEmergencySound();
//         }

//         if (emergency.status == "Assigning" || emergency.status == "Responding") {
//           final hasCoords = emergency.latitude != null && emergency.longitude != null;
//           print("📍 Emergency coords present: $hasCoords");

//        // Set emergency first, without async inside setState
//           setState(() {
//             _assignedEmergency = emergency;
//             _isTracking = emergency.status == "Responding";
//             _previousEmergency = emergency;
//           });

//           print("📦 Emergency Data: latitude=${emergency.latitude}, longitude=${emergency.longitude}, hasCoords=$hasCoords");

//           if (hasCoords) {
//             final currentUid = FirebaseAuth.instance.currentUser?.uid;
//             print("🔍 Checking unit_Status for ER_ID: $currentUid...");

//             final unitSnapshot = await FirebaseDatabase.instance
//                 .ref("responder_unit")
//                 .orderByChild("ER_ID")
//                 .equalTo(currentUid)
//                 .get();

//             print("📌 Hello"); // Confirm this is reached

//             bool isResponderActive = false;

//             if (unitSnapshot.exists) {
//               final unitData = unitSnapshot.value as Map;
//               print("🧭 Found ${unitData.length} responder unit(s).");

//               for (final entry in unitData.entries) {
//                 final unitKey = entry.key;
//                 final unit = Map<String, dynamic>.from(entry.value);

//                 final unitStatus = unit['unit_Status'];
//                 final unitEmergencyId = unit['emergency_ID'];

//                 print("🔎 Unit $unitKey → status: $unitStatus, emergency_ID: $unitEmergencyId");

//                 if (unitEmergencyId == emergency.id && unitStatus == "Responding") {
//                   print("✅ Matching responder unit is responding to this emergency.");
//                   isResponderActive = true;
//                   break;
//                 }
//               }
//             } else {
//               print("❌ No responder_unit entry found for this user.");
//             }

//             if (isResponderActive) {
//               print("📍 Proceeding to zoom to responder and emergency...");
//               _zoomToResponderLocation();
//             } else {
//               print("⛔ Skipping zoom: Responder not actively assigned.");
//             }
//           } else {
//             print("🚫 Skipping unit check — Emergency is missing coordinates.");
//           }


//           print("📌 Updating markers and fetching route...");
//           _setupMarkers();
//           _fetchRoute();
//           return;
//         } else {
//           print("⏩ Emergency status is not actionable. Skipping...");
//         }
//       }
//     } else {
//       print("🛑 No active emergencies assigned to this responder unit.");

//       if (mounted) {
//         setState(() {
//           _assignedEmergency = null;
//           _isTracking = false;
//           _previousEmergency = null;
//           _polylines.clear();
//         });
//       }

//       _setupMarkers();
//     }
//   });
// }


// Future<void> _fetchRoute() async {
//   if (_currentLocation == null || _assignedEmergency == null) return;

//   final routes = await _routeService.fetchRoutes(
//     _currentLocation!,
//     latLng.LatLng(_assignedEmergency!.latitude, _assignedEmergency!.longitude),
//     openRouteServiceApiKey,
//   );

//   if (mounted && routes.isNotEmpty) {
//     final primaryRoute = routes.first;
//     _latestRoute = primaryRoute; // ✅ store route for future TTS

//     setState(() {
//       _routeDuration = primaryRoute.duration;
//       _routeDistance = primaryRoute.distance;

//       _polylines.clear();
//       final decodedPoints = primaryRoute.geometry;

//       _polylines.add(fm.Polyline(
//         points: decodedPoints,
//         strokeWidth: 9.0,
//         color: Colors.white,
//       ));

//       _polylines.add(fm.Polyline(
//         points: decodedPoints,
//         strokeWidth: 6.0,
//         color: Colors.blue,
//       ));
//     });
//   }
// }


// void _setupMarkers() {
//   _markers.clear();

//   if (_currentLocation != null) {
//         _updateDynamicCircle(accuracy!);
//           _markers.add(
//               fm.Marker(
//               width: 40,
//               height: 40,
//               point: _currentLocation!,
//               rotate: true,
//               alignment: Alignment.center,
//               child: Transform.rotate(
//                 angle: (_currentHeading) * pi / 180, // convert degrees to radians
//                 child: Icon(
//                   Icons.navigation,
//                   size: 40,
//                   color: Colors.blue,
//                 ),
//               ),
//             ),

//             );

//       _circles.clear();
//           _circles.add(
//           fm.CircleMarker(
//             point: latLng.LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
//             color: Colors.blue.withOpacity(0.3),
//             borderColor: Colors.blue,
//             borderStrokeWidth: 1,
//             radius: accuracy!,
//           ),
//         );

//     }

//     if (_assignedEmergency != null &&
//     _assignedEmergency!.latitude != null &&
//     _assignedEmergency!.longitude != null) {
//   final emergencyPoint = latLng.LatLng(
//     _assignedEmergency!.latitude,
//     _assignedEmergency!.longitude,
//   );

//   _markers.add(
//     fm.Marker(
//       width: 50,
//       height: 50,
//       point: emergencyPoint,
//       child: Image.asset(
//         'assets/images/emergency_pin.png',
//         width: 50,
//         height: 50,
//       ),
//     ),
//   );
// }





//   setState(() {
//   });
// }


// /// Zoom to only the responder's current location
// void _zoomToResponderLocation() {
//   if (accuracy != null) {
//     _updateDynamicCircle(accuracy!);
//   }
//   if (_currentLocation != null) {
//     _mapController.move(_currentLocation!, 19.0); // simple zoom + move
//   }
// }


// /// Zoom to fit both responder and assigned emergency in view
// Future<void> _zoomToResponderAndEmergency() async {
//   _updateDynamicCircle(accuracy!);

//   final currentUid = FirebaseAuth.instance.currentUser?.uid;
//   if (currentUid == null) {
//     print("❌ Cannot zoom: No current user.");
//     return;
//   }

//   final unitSnapshot = await FirebaseDatabase.instance
//       .ref("responder_unit")
//       .orderByChild("ER_ID")
//       .equalTo(currentUid)
//       .get();

//   if (!unitSnapshot.exists) {
//     print("❌ Cannot zoom: No responder_unit found for this user.");
//     return;
//   }

//   final unitData = unitSnapshot.value as Map;
//   bool isValidResponderUnit = false;

//   for (final entry in unitData.entries) {
//     final unit = Map<String, dynamic>.from(entry.value);
//     final unitStatus = unit['unit_Status'];
//     final emergencyId = unit['emergency_ID'];

//     print("🔎 Checking unit: status=$unitStatus, emergency_ID=$emergencyId");

//     if (unitStatus == "Active" && emergencyId != null && emergencyId.toString().isNotEmpty) {
//       isValidResponderUnit = true;
//       break;
//     }
//   }

//   if (!isValidResponderUnit) {
//     print("⛔ Cannot zoom: No active responder unit with emergency_ID.");
//     return;
//   }

//   if (_currentLocation != null &&
//       _assignedEmergency != null &&
//       _assignedEmergency!.latitude != null &&
//       _assignedEmergency!.longitude != null) {

//     final emergencyLocation = latLng.LatLng(
//       _assignedEmergency!.latitude,
//       _assignedEmergency!.longitude,
//     );

//     final bounds = fm.LatLngBounds.fromPoints([
//       _currentLocation!,
//       emergencyLocation,
//     ]);

//     final cameraFit = fm.CameraFit.bounds(
//       bounds: bounds,
//       padding: const EdgeInsets.all(80),
//     );

//     _mapController.fitCamera(cameraFit);
//     print("✅ Zoomed to responder and emergency.");
//   } else {
//     print("⚠️ Cannot zoom: Missing responder or emergency coordinates.");
//   }
// }


// void _moveToCurrentLocation() {
//   if (accuracy != null) {
//     _updateDynamicCircle(accuracy!);
//   }

//   if (_assignedEmergency != null) {
//     _zoomToResponderAndEmergency(); // Assumes zoom already has proper validation
//   } else {
//     _zoomToResponderLocation();
//   }
// }


// fm.LatLngBounds _getLatLngBounds(latLng.LatLng p1, latLng.LatLng p2) {
//   return fm.LatLngBounds(
//     latLng.LatLng(
//       min(p1.latitude, p2.latitude),
//       min(p1.longitude, p2.longitude),
//     ),
//     latLng.LatLng(
//       max(p1.latitude, p2.latitude),
//       max(p1.longitude, p2.longitude),
//     ),
//   );
// }

// Future<void> _acceptEmergency() async {

//   _isTracking = true;

//   print("🚀 Attempting to accept emergency...");
//   await _firebaseService.stopEmergencySound();

//   if (_assignedEmergency != null) {
//     final emergencyId = _assignedEmergency!.id;
//     try {
//       await _firebaseService.updateEmergencyStatus(emergencyId, "Responding");

//       if (_latestRoute != null) {
//         await _ttsService.speakNavigationInstructions({
//           "legs": [
//             {
//               "steps": _latestRoute!.steps,
//             }
//           ]
//         });
//       }

//     } catch (e) {
//       print("🚫 Error accepting emergency: $e");
//     }
//   } else {
//     print("⚠️ No assigned emergency detected.");
//   }
// }



// Future<void> _declineEmergency(String reason) async {
//   if (_assignedEmergency != null) {
//     final emergencyId = _assignedEmergency!.id;
//     final currentUid = FirebaseAuth.instance.currentUser?.uid;

//     final dbRef = FirebaseDatabase.instance.ref();
//     final emergencyRef = dbRef.child("emergencies/$emergencyId");
//     final responderUnitRef = dbRef.child("responder_unit");

//     final snapshot = await emergencyRef.child("responder_ID").get();

//     if (!snapshot.exists || currentUid == null) {
//       print("⚠️ No responder_ID or user not signed in.");
//       return;
//     }

//     // 🔁 Remove current UID from the emergency's responder_ID list
//     String responderRaw = snapshot.value as String? ?? "";
//     List<String> responderIds = responderRaw
//         .split(',')
//         .map((id) => id.trim())
//         .where((id) => id.isNotEmpty && id != currentUid)
//         .toList();

//     final updatedResponderString = responderIds.join(",");

//     // 📝 Update emergency responder list and status
//     await emergencyRef.update({
//       "report_Status": "Assigning",
//       "responder_ID": updatedResponderString.isEmpty ? null : updatedResponderString,
//     });

//     print("🚫 Responder $currentUid removed from responder_ID list.");

//     // 🧹 Remove emergency_ID from matching responder_unit entries
//     final unitSnapshot = await responderUnitRef.get();
//     if (unitSnapshot.exists) {
//       final units = unitSnapshot.value as Map;

//       for (final entry in units.entries) {
//         final unitKey = entry.key;
//         final unit = Map<String, dynamic>.from(entry.value);

//         if (unit["ER_ID"] == currentUid && unit["emergency_ID"] == emergencyId) {
//           await responderUnitRef.child(unitKey).child("emergency_ID").remove();
//           print("🧹 Removed emergency_ID from responder_unit $unitKey");
//         }
//       }
//     }

//     // 🔔 Send decline notification
//     final notificationRef = dbRef.child("notifications").push();
//     await notificationRef.set({
//       "type": "decline",
//       "For": emergencyId,
//       "From": currentUid,
//       "Content": reason,
//       "timestamp": ServerValue.timestamp,
//       "status": "unread"
//     });

//     await _firebaseService.stopEmergencySound();
//     print("✅ Notification sent to admin.");
//   }
// }



// void _showDeclineDialog(BuildContext context) {
//   TextEditingController reasonController = TextEditingController();

//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text("Decline Emergency"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("Please provide a reason for declining the emergency:"),
//             const SizedBox(height: 10),
//             TextField(
//               controller: reasonController,
//               maxLines: 3,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: "Enter reason",
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               String reason = reasonController.text.trim();
//               if (reason.isNotEmpty) {
//                 await _declineEmergency(reason);  
//                 Navigator.of(context).pop();
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Please enter a reason.")),
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text("Decline"),
//           ),
//         ],
//       );
//     },
//   );
// }

// Duration _parseDuration(String durationStr) {
//   final lower = durationStr.toLowerCase();
//   int totalMinutes = 0;

//   final hourMatch = RegExp(r'(\d+)\s*hour').firstMatch(lower);
//   final minMatch = RegExp(r'(\d+)\s*min').firstMatch(lower);

//   if (hourMatch != null) {
//     totalMinutes += int.parse(hourMatch.group(1)!)*60;
//   }
//   if (minMatch != null) {
//     totalMinutes += int.parse(minMatch.group(1)!);
//   }

//   return Duration(minutes: totalMinutes);
// }

// void _updateDynamicCircle(double? rawAccuracy) {
//   if (_currentLocation == null) return;

//   // ✅ Clamp accuracy between 5 and 100 meters to avoid absurd circles
//   final safeAccuracy = (rawAccuracy ?? 30.0).clamp(5.0, 100.0);

//   double zoomFactor = 18.0 - _currentZoom;
//   double dynamicRadius = 10 + (zoomFactor * 10);

//   // ✅ Clamp to prevent over-scaling
//   dynamicRadius = dynamicRadius.clamp(5.0, 50.0);

//   _circles.clear();

//   _circles.add(
//     fm.CircleMarker(
//       point: latLng.LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
//       color: Colors.blue.withOpacity(0.3),
//       borderColor: Colors.blue,
//       borderStrokeWidth: 1,
//       radius: safeAccuracy, // ✅ Use safe, clamped value
//     ),
//   );

//   setState(() {});
// }





// IconData _getDirectionIcon(int type) {
//   switch (type) {
//     case 0: return Icons.turn_left;
//     case 1: return Icons.turn_right;
//     case 10: return Icons.flag;
//     case 11: return Icons.navigation; // 'Head' direction
//     default: return Icons.directions;
//   }
// }


//   @override
// Widget build(BuildContext context) {
 
//   String formattedETA = "";
//   if (_routeDuration.isNotEmpty) {
//     final duration = _parseDuration(_routeDuration);
//     final eta = DateTime.now().add(duration);
//     formattedETA = TimeOfDay.fromDateTime(eta).format(context);
//   }

//   return Scaffold(
//     body: Stack(
//       children: [
//        fm.FlutterMap(
//           mapController: _mapController,
//             options: fm.MapOptions(
//             initialCenter: _currentLocation ?? latLng.LatLng(9.8500, 124.1435),
//             initialZoom: _currentZoom,
//             interactionOptions: const fm.InteractionOptions(
//               flags: fm.InteractiveFlag.all,
//             ),
//             onPositionChanged: (pos, hasGesture) {
//               if (hasGesture) {
//                 setState(() {
//                   _mapReady = true;
//                   _userInteractedWithMap = true;
//                   _currentZoom = pos.zoom!;
//                   _updateDynamicCircle(accuracy!);
//                 });
//               }
//             },
//           ),

//             children: [
//               fm.TileLayer(
//                 tileProvider: FMTCTileProvider(
//                   stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
//                 ),
//                 urlTemplate: 'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=yLZK07MqFMX2jDswZ4Fv',
//                 userAgentPackageName: 'com.example.app',
//               ),



//               fm.CircleLayer(circles: _circles),
//               fm.PolylineLayer(polylines: _polylines),
//               fm.MarkerLayer(markers: _markers),
//             ],
//           ),

//           if (_routeDuration.isNotEmpty && _routeDistance.isNotEmpty)
          
//             Positioned(
//               top: 50,
//               left: 20,
//               right: 20,
              
//               child: InfoCard(
//                 icon: Icons.directions_car,
//                 text: "Estimated Time: $_routeDuration\nDistance: $_routeDistance\nETA: $formattedETA",
//               ),
//             ),


//         // ✅ Accept & Decline Buttons
//         if (_assignedEmergency != null && _assignedEmergency!.status == "Assigning")
//           Positioned(
//             bottom: 40,
//             left: 20,
//             right: 20,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: _acceptEmergency,   // ✅ Accept the emergency
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   ),
//                   icon: const Icon(Icons.check, color: Colors.white),
//                   label: const Text("Accept", style: TextStyle(color: Colors.white)),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () => _showDeclineDialog(context),  // ✅ Show decline dialog
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   ),
//                   icon: const Icon(Icons.close, color: Colors.white),
//                   label: const Text("Decline", style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ),
//           ),

//         //✅ Floating Action Button to move to current location
//         Positioned(
//             top: 5,
//             right: 20,
//             child: ElevatedButton.icon(
//               onPressed: _moveToCurrentLocation,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//                 foregroundColor: const Color.fromARGB(255, 0, 0, 0),
//                 shape: const StadiumBorder(),
//               ),
//               icon: const Icon(Icons.my_location),
//               label: const Text("Re-center"),
//             ),
//           ),
//           if (_isTracking && _currentInstruction.isNotEmpty)
//             Positioned(
//               bottom: 110,
//               left: 20,
//               right: 20,
//               child: InfoCard(
//                 icon: _getDirectionIcon(
//                   (_latestRoute != null && _currentStepIndex < _latestRoute!.steps.length)
//                       ? _latestRoute!.steps[_currentStepIndex]['type']
//                       : 0,
//                 ),
//                 text: _currentInstruction,
//               ),
//             ),
//       ],
      
//     ),
    
//   );
// }
// }