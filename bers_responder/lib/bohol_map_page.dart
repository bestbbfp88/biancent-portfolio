// bohol_map_page.dart (FINAL FIX)
import 'dart:async';
import 'dart:math';
import 'package:bers_responder/models/emergency_model.dart';
import 'package:bers_responder/secrets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as latLng;
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/info_card.dart';
import '../../services/navigation_tts_service.dart';
import '../../services/firebase_service.dart';
import '../../services/location_service.dart';
import '../../services/route_service.dart';
import 'map_controller_service.dart';
import 'emergency_listener.dart';
import 'responder_location_service.dart';
import 'map_ui_elements.dart';
import 'emergency_actions.dart';

class BoholMapPage extends StatefulWidget {
  const BoholMapPage({super.key});

  @override
  State<BoholMapPage> createState() => _BoholMapPageState();
}

class _BoholMapPageState extends State<BoholMapPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final LocationService _locationService = LocationService();
  final RouteService _routeService = RouteService();
  late final fm.MapController _mapController = fm.MapController();
  late final NavigationTTSService _ttsService = NavigationTTSService();
  late final EmergencyActions _emergencyActions;

  latLng.LatLng? _currentLocation;
  List<fm.Marker> _markers = [];
  List<fm.CircleMarker> _circles = [];
  List<fm.Polyline> _polylines = [];
  Emergency? _assignedEmergency;
  Emergency? _previousEmergency;
  RouteData? _latestRoute;
  String _routeDuration = '';
  String _routeDistance = '';
  double _heading = 0;
  double _accuracy = 30.0;
  bool _isDrivingMode = false;
  String _currentInstruction = '';
  int _currentStepIndex = 0;
  bool _hasFitCameraOnce = false;
  bool _hasSpokenCurrentStep = false;
  bool _hasArrived = false;
  String? _currentUnitStatus;
  DateTime? _lastRouteUpdate;

  double _zoomBasedOnSpeed(double speed) {
    if (speed < 1) return 18.5;
    if (speed < 10) return 17.5;
    if (speed < 30) return 16.5;
    return 15.0;
  }

 @override
void initState() {
  super.initState();
  _startLocationTracking();
  _startEmergencyListener();
  _fetchUnitStatus(); // 👈 Add this
  _emergencyActions = EmergencyActions(
    firebaseService: _firebaseService,
    ttsService: _ttsService,
  );
}

@override
void dispose() {
  _unitStatusSubscription?.cancel();
  super.dispose();
}

 StreamSubscription<DatabaseEvent>? _unitStatusSubscription;

void _fetchUnitStatus() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final ref = FirebaseDatabase.instance.ref("responder_unit");
  _unitStatusSubscription = ref.onValue.listen((event) {
    if (!event.snapshot.exists) return;

    final units = Map<String, dynamic>.from(event.snapshot.value as Map);
    for (final unit in units.entries) {
      final unitData = unit.value;
      if (unitData is Map && unitData['ER_ID'] == user.uid) {
        setState(() {
          _currentUnitStatus = unitData['unit_Status']?.toString();
        });
        break;
      }
    }
  });
}

 void _startLocationTracking() {
  final tracker = ResponderLocationService(
    firebaseService: _firebaseService,
    locationService: _locationService,
    flutterTts: _ttsService.flutterTts,
    ttsService: _ttsService,
    routeService: _routeService,
  );

  tracker.initializeTracking(
   onUpdate: (location, heading, accuracy, speed) async {
      setState(() {
        _currentLocation = location;
        _heading = heading;
        _accuracy = accuracy;
        _markers = MapUIElements.buildMarkers(
          currentLocation: _currentLocation,
          heading: _heading,
          emergency: _assignedEmergency,
        );
        _circles = MapUIElements.buildAccuracyCircle(
          location: _currentLocation,
          accuracy: _accuracy,
        );
      });

      // ✅ Real-time route & ETA update when driving
      if (_isDrivingMode && _assignedEmergency != null) {
        final destination = latLng.LatLng(
          _assignedEmergency!.latitude,
          _assignedEmergency!.longitude,
        );

        final routes = await _routeService.fetchRoutes(
          location, // current location
          destination,
          openRouteServiceApiKey,
        );

        if (routes.isNotEmpty) {
          final updatedRoute = routes.first;

          setState(() {
            _latestRoute = updatedRoute;
            _routeDuration = updatedRoute.duration;
            _routeDistance = updatedRoute.distance;
            _polylines = [
              fm.Polyline(
                points: updatedRoute.geometry,
                strokeWidth: 9.0,
                color: Colors.white,
              ),
              fm.Polyline(
                points: updatedRoute.geometry,
                strokeWidth: 6.0,
                color: Colors.blue,
              ),
            ];
          });

          if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("🔁 Rerouting..."),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.blue,
                ),
              );
          }
          // 👇 Animate map camera to follow the new route bounds
          final bounds = fm.LatLngBounds.fromPoints(updatedRoute.geometry);
          final fitCamera = fm.CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(60),
          );

          _mapController.fitCamera(fitCamera); // Smooth zoom & pan
        }

      }

      // ✅ Arrival check
      if (!_hasArrived && _latestRoute != null && _latestRoute!.steps.isNotEmpty) {
        final distToEnd = latLng.Distance().as(
          latLng.LengthUnit.Meter,
          location,
          _latestRoute!.geometry.last,
        );

        if (distToEnd < 20) {
          _hasArrived = true;
          await _updateAtSceneInFirebase(context);
        }
      }

      // ✅ Navigation instruction logic
      if (_isDrivingMode &&
          _latestRoute != null &&
          _currentStepIndex < _latestRoute!.steps.length) {
        final step = _latestRoute!.steps[_currentStepIndex];
        final lat = step['way_points'][0];
        final coords = _latestRoute!.geometry[lat];

        final dist = latLng.Distance().as(
          latLng.LengthUnit.Meter,
          _currentLocation!,
          coords,
        );

        if (dist < 80 && !_hasSpokenCurrentStep) {
          final instruction = step['instruction'] ?? '';
          final distanceText = dist >= 50 ? "${dist.round()} meters" : "less than 50 meters";
          final spokenInstruction = "In $distanceText, $instruction";

          _hasSpokenCurrentStep = true;
          setState(() {
            _currentInstruction = instruction;
          });

          await _ttsService.flutterTts.speak(spokenInstruction);

          Future.delayed(const Duration(seconds: 4), () {
            _hasSpokenCurrentStep = false;
            if (_currentStepIndex < _latestRoute!.steps.length - 1) {
              setState(() {
                _currentStepIndex++;
              });
            }
          });
        }

        final dynamicZoom = _zoomBasedOnSpeed(speed ?? 0);
        animatedMapMove(_currentLocation!, dynamicZoom);
      }
    },
    getEmergency: () => _assignedEmergency,
  );
}

    void animatedMapMove(latLng.LatLng dest, double zoom) {
      _mapController.moveAndRotate(dest, zoom, _heading);
    }

Future<void> _updateAtSceneInFirebase(BuildContext context) async {
  if (!context.mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Arrival"),
      content: const Text("Have you arrived at the scene?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("OK"),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final responderUnitSnapshot = await FirebaseDatabase.instance
        .ref("responder_unit")
        .orderByChild("ER_ID")
        .equalTo(user.uid)
        .get();

    if (!responderUnitSnapshot.exists) {
      print("❌ No matching responder_unit found.");
      return;
    }

    final responderUnits = Map<String, dynamic>.from(responderUnitSnapshot.value as Map);
    final firstUnit = responderUnits.values.first;
    final emergencyId = firstUnit['emergency_ID'];

    if (emergencyId == null) {
      print("❌ No emergency_ID found for responder.");
      return;
    }

    final dispatchSnapshot = await FirebaseDatabase.instance
        .ref("emergencies/$emergencyId/dispatch_ID")
        .get();

    if (!dispatchSnapshot.exists) {
      print("❌ dispatch_ID not found for emergency $emergencyId.");
      return;
    }

    final dispatchId = dispatchSnapshot.value.toString();

    // ✅ Update responder-specific `at_scene` field inside the ticket
    await FirebaseDatabase.instance
        .ref("tickets/$dispatchId/responder_data/${user.uid}/dispatch")
        .update({
      "time_at_scene": ServerValue.timestamp,
    });

    print("✅ Updated at_scene for ${user.uid} in ticket $dispatchId");

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Marked as arrived at scene ✅"),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    print("❌ Error updating at_scene: $e");

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update arrival: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Future<void> _updateAtDestinationInFirebase(BuildContext context) async {
  if (!context.mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Destination Arrival"),
      content: const Text("Have you arrived at the destination?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("OK"),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final responderUnitSnapshot = await FirebaseDatabase.instance
        .ref("responder_unit")
        .orderByChild("ER_ID")
        .equalTo(user.uid)
        .get();

    if (!responderUnitSnapshot.exists) {
      print("❌ No matching responder_unit found.");
      return;
    }

    final responderUnits = Map<String, dynamic>.from(responderUnitSnapshot.value as Map);
    final firstUnit = responderUnits.values.first;
    final emergencyId = firstUnit['emergency_ID'];

    if (emergencyId == null) {
      print("❌ No emergency_ID found for responder.");
      return;
    }

    final dispatchSnapshot = await FirebaseDatabase.instance
        .ref("emergencies/$emergencyId/dispatch_ID")
        .get();

    if (!dispatchSnapshot.exists) {
      print("❌ dispatch_ID not found for emergency $emergencyId.");
      return;
    }

    final dispatchId = dispatchSnapshot.value.toString();

    // ✅ Update responder-specific `at_scene` field inside the ticket
    await FirebaseDatabase.instance
        .ref("tickets/$dispatchId/responder_data/${user.uid}/dispatch")
        .update({
      "time_at_destination": ServerValue.timestamp,
    });


    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Marked as arrived at destination ✅"),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    print("❌ Error updating at_scene: $e");

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update arrival: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


Future<void> _updateAtBaseInFirebase(BuildContext context) async {
  if (!context.mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Base Arrival"),
      content: const Text("Have you arrived at the base?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("OK"),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final responderUnitSnapshot = await FirebaseDatabase.instance
        .ref("responder_unit")
        .orderByChild("ER_ID")
        .equalTo(user.uid)
        .get();

    if (!responderUnitSnapshot.exists) {
      print("❌ No matching responder_unit found.");
      return;
    }

    final responderUnits = Map<String, dynamic>.from(responderUnitSnapshot.value as Map);
    final firstUnit = responderUnits.values.first;
    final emergencyId = firstUnit['emergency_ID'];

    if (emergencyId == null) {
      print("❌ No emergency_ID found for responder.");
      return;
    }

    final dispatchSnapshot = await FirebaseDatabase.instance
        .ref("emergencies/$emergencyId/dispatch_ID")
        .get();

    if (!dispatchSnapshot.exists) {
      print("❌ dispatch_ID not found for emergency $emergencyId.");
      return;
    }

    final dispatchId = dispatchSnapshot.value.toString();

    // ✅ Update responder-specific `at_scene` field inside the ticket
    await FirebaseDatabase.instance
        .ref("tickets/$dispatchId/responder_data/${user.uid}/dispatch")
        .update({
      "time_at_base": ServerValue.timestamp,
    });

    print("✅ Updated at_scene for ${user.uid} in ticket $dispatchId");

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Marked as arrived at base ✅"),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    print("❌ Error updating at_scene: $e");

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update arrival: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

void _startEmergencyListener() {
  final listener = EmergencyListener(
    firebaseService: _firebaseService,
    routeService: _routeService,
    auth: FirebaseAuth.instance,
    onEmergencyUpdate: (emergency, isTracking, route) async {
      final isFirstLoad = _previousEmergency == null;

      if (emergency == null) {
        print("❌ Emergency is null. Skipping.");
        return;
      }


      if (!isFirstLoad &&
          _previousEmergency?.id == emergency.id &&
          _previousEmergency?.status == emergency.status) {
        return;
      }

      final isNewEmergency = _previousEmergency?.id != emergency.id;


      if (emergency.status == "Assigning" && isNewEmergency) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final responderRef = FirebaseDatabase.instance.ref("responder_unit");
          final snapshot = await responderRef.once();
          final units = snapshot.snapshot.value as Map?;

          if (units != null) {
            for (final entry in units.entries) {
              final unit = entry.value;
              if (unit is Map && unit['ER_ID'] == user.uid) {
                final currentStatus = unit['unit_Status']?.toString() ?? '';
                if (currentStatus != "Responding") {
                  await _firebaseService.playEmergencySound();

                }
                break;
              }
            }
          }
        }
      }


      _previousEmergency = emergency;
      _assignedEmergency = emergency;
      _latestRoute = route;
      _routeDuration = route?.duration ?? '';
      _routeDistance = route?.distance ?? '';
      _currentStepIndex = 0;
      _hasFitCameraOnce = false;

      _markers = MapUIElements.buildMarkers(
        currentLocation: _currentLocation,
        heading: _heading,
        emergency: _assignedEmergency,
      );

      _polylines = route != null
          ? [
              fm.Polyline(
                points: route.geometry,
                strokeWidth: 9.0,
                color: Colors.white,
              ),
              fm.Polyline(
                points: route.geometry,
                strokeWidth: 6.0,
                color: Colors.blue,
              ),
            ]
          : [];

      if (!_isDrivingMode && route != null && route.geometry.isNotEmpty) {
        final bounds = fm.LatLngBounds.fromPoints([
          _currentLocation ?? route.geometry.first,
          ...route.geometry,
        ]);

        final cameraFit = fm.CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(80),
        );
        _mapController.fitCamera(cameraFit);
        _hasFitCameraOnce = true;
        print("📸 Fitted camera to emergency bounds");
      }

      setState(() {});
    },
    onEmergencyCleared: () {
      print("🧹 Emergency cleared");

      setState(() {
        _assignedEmergency = null;
        _markers = MapUIElements.buildMarkers(
          currentLocation: _currentLocation,
          heading: _heading,
          emergency: null,
        );
        _polylines.clear();
        _routeDistance = '';
        _routeDuration = '';
        _currentInstruction = '';
        _currentStepIndex = 0;

        if (_currentLocation != null) {
          _mapController.move(_currentLocation!, 18.0);
        }
      });
    },
  );

  listener.listenToEmergencies();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          fm.FlutterMap(
            mapController: _mapController,
            options: fm.MapOptions(
              initialCenter: _currentLocation ?? latLng.LatLng(9.8500, 124.1435),
              initialZoom: 18.0,
            ),
            children: [
              fm.TileLayer(
                urlTemplate: 'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=jd2AEjGrt9Hd159cJ4E3',
                userAgentPackageName: 'com.example.app',
              ),
              fm.CircleLayer(circles: _circles),
              fm.PolylineLayer(polylines: _polylines),
              fm.MarkerLayer(markers: _markers),
            ],
          ),
          if (_routeDuration.isNotEmpty && _routeDistance.isNotEmpty)
            Positioned(
              top: 10,
              left: 20,
              right: 20,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: InfoCard(
                  key: ValueKey("ETA: $_routeDuration $_routeDistance"),
                  icon: Icons.directions_car,
                  text: "Estimated Time: $_routeDuration\nDistance: $_routeDistance",
                ),
              ),
            ),

          if (_currentInstruction.isNotEmpty)
            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: InfoCard(
                icon: Icons.navigation,
                text: _currentInstruction,
              ),
            ),
          Positioned(
            bottom: 10,
            left: 10,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isDrivingMode = !_isDrivingMode;

                  if (_currentLocation != null) {
                      if (_isDrivingMode) {
                        print("🚗 Driving Mode ENABLED");
                        _mapController.move(_currentLocation!, 18.5); // Zoom in
                      } else {
                        print("🛑 Driving Mode DISABLED");
                        _mapController.move(_currentLocation!, 16.0); // Zoom out when off
                      }
                    }

                });
              },
              icon: Icon(_isDrivingMode ? Icons.navigation : Icons.navigation_outlined,  color: Color.fromARGB(255, 16, 9, 74),),
              label: Text(_isDrivingMode ? 'Driving ON' : 'Driving OFF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: const StadiumBorder(),
              ),
            ),
          ),

          if (_assignedEmergency != null && _assignedEmergency!.status != 'Responding' && _currentUnitStatus != 'Responding')
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _emergencyActions.acceptEmergency(
                        emergency: _assignedEmergency!,
                        route: _latestRoute,
                      );
                      setState(() {
                        _assignedEmergency = _assignedEmergency!.copyWith(status: 'Responding');
                      });
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("Accept"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _emergencyActions.showDeclineDialog(context, _assignedEmergency!);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("Decline"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
            if (_assignedEmergency != null && _assignedEmergency!.status == 'Responding')
            Positioned(
              bottom: 10,
              right: 10,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _updateAtSceneInFirebase(context);
                },
                icon: const Icon(Icons.check,  color: Color.fromARGB(255, 16, 9, 74),),
                label: const Text(""),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  shape: const StadiumBorder(),
             
                ),
              ),
            ),
            if (_assignedEmergency != null && _assignedEmergency!.status == 'Responding')
            Positioned(
              bottom: 60,
              right: 10,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _updateAtDestinationInFirebase(context);
                },
                icon: const Icon(Icons.local_airport,  color: Color.fromARGB(255, 16, 9, 74),),
                label: const Text(""),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  shape: const StadiumBorder(),
             
                ),
              ),
            ),
            if (_assignedEmergency != null && _assignedEmergency!.status == 'Responding')
            Positioned(
              bottom: 110,
              right: 10,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _updateAtBaseInFirebase(context);
                },
                icon: const Icon(Icons.maps_home_work, color: Color.fromARGB(255, 16, 9, 74),),
                label: const Text(""),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 1),
                  shape: const StadiumBorder(),
             
                ),
              ),
            ),



        ],
      ),
    );
  }
}
