import 'dart:convert';
import 'dart:io';

import 'package:bohol_emergency_response_system/main_navigation/call_screen.dart';
import 'package:bohol_emergency_response_system/services/call_service.dart';
import 'package:bohol_emergency_response_system/services/make_call.dart';
import 'package:bohol_emergency_response_system/services/network_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:latlong2/latlong.dart';

import 'package:http/http.dart' as http;

class DispatcherTracking extends StatefulWidget {
  final String emergencyId;

  const DispatcherTracking({super.key, required this.emergencyId});

  @override
  DispatcherTrackingState createState() => DispatcherTrackingState();
}

class DispatcherTrackingState extends State<DispatcherTracking> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final NetworkService _networkService = NetworkService();


  String? _responderName;
  String? _responderPhone;
  bool isResponderAssigned = false;
  bool isLoading = true;

  double? responderLatitude;
  double? responderLongitude;

  double? emergencyLatitude;
  double? emergencyLongitude;
  bool _autoCallTriggered = false;


  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];

  @override
  void initState() {
    super.initState();
    _trackEmergencyStatus();
  }

 void _trackEmergencyStatus() {
  _dbRef.child('emergencies/${widget.emergencyId}').onValue.listen((event) async {
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> emergencyData = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

      emergencyLatitude = double.tryParse(emergencyData['live_es_latitude'].toString());
      emergencyLongitude = double.tryParse(emergencyData['live_es_longitude'].toString());
      responderLatitude = double.tryParse(emergencyData['live_responder_latitude'].toString());
      responderLongitude = double.tryParse(emergencyData['live_responder_longitude'].toString());

    if (emergencyData['report_Status'] == "Pending"){
      if (!_autoCallTriggered) {
          final isGood = await _networkService.isNetworkGoodEnough();

          if (isGood) {
            _autoCallTriggered = true;
            print("📞 Auto-calling — Good network detected");
            _startInAppCall();
          } else {
            print("📶 Skipping auto-call — Weak or no internet");
          }
        }
    }

      if (emergencyData['report_Status'] == "Responding" && emergencyData['responder_ID'] != null) {
        String responderId = emergencyData['responder_ID'];
        _trackResponder(responderId);

      }

      if (mounted) {
        setState(() {
          isResponderAssigned = emergencyData['responder_ID'] != null;
          isLoading = false;
        });
        _updateMap(); 
      }
    }
  });
}

void _trackResponder(String responderIDs) {
  print("🚨 Tracking responders from responder_unit for: $responderIDs");

  final responderIdList = responderIDs.split(',').map((id) => id.trim()).toList();

  _dbRef.child('responder_unit').onValue.listen((snapshot) async {
    if (snapshot.snapshot.value == null) return;

    final responderUnits = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
    List<Map<String, dynamic>> validUnits = [];

    for (final entry in responderUnits.entries) {
      final unit = Map<String, dynamic>.from(entry.value);
      if (responderIdList.contains(unit['ER_ID']) && unit['unit_Status'] == 'Responding') {
        validUnits.add(unit);
      }
    }

    if (validUnits.isEmpty) {
      print("❌ No active responder units matched or are 'Responding'");
      return;
    }

    await _updateMapWithResponders(validUnits);
  });
}


Future<void> _updateMapWithResponders(List<Map<String, dynamic>> units) async {
  List<Marker> newMarkers = [];
  List<Polyline> newPolylines = [];
  List<String> responderNames = [];

  for (final unit in units) {
    final erID = unit['ER_ID'];
    final lat = double.tryParse(unit['latitude'].toString());
    final lng = double.tryParse(unit['longitude'].toString());
    final unitName = unit['unit_Name'] ?? 'Unit';

    if (lat == null || lng == null) continue;

    final userSnap = await _dbRef.child("users/$erID").get();
    final user = userSnap.exists ? Map<String, dynamic>.from(userSnap.value as Map) : {};

    final responderType = user['responder_type'] ?? "Unknown";
    if (responderType == "Police") continue;

    responderNames.add("$unitName - ${user['f_name'] ?? ''} ${user['l_name'] ?? ''}");

    newMarkers.add(
      Marker(
        point: LatLng(lat, lng),
        width: 100,
        height: 100,
        child: Column(
          children: [
            const Icon(Icons.location_on, color: Colors.blue, size: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
              ),
              child: Text(unitName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    final polyline = await _getPolylineFor(lat, lng);
    if (polyline != null) newPolylines.add(polyline);
  }

  newMarkers.add(
    Marker(
      point: LatLng(emergencyLatitude ?? 0.0, emergencyLongitude ?? 0.0),
      width: 100,
      height: 100,
      child: Column(
        children: [
          const Icon(Icons.local_hospital, color: Colors.red, size: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
            ),
            child: const Text("Emergency", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );

  if (mounted) {
    setState(() {
      _responderName = responderNames.join(", ");
      _responderPhone = "Multiple";
      isResponderAssigned = true;
      isLoading = false;
      _markers = newMarkers;
      _polylines = newPolylines;
    });
    _fitMapToMarkers();
  }
}


void _fitMapToMarkers() {
  if (_markers.length < 2) return;

  final latLngs = _markers.map((m) => m.point).toList();
  final bounds = LatLngBounds.fromPoints(latLngs);

  final cameraFit = CameraFit.bounds(
    bounds: bounds,
    padding: const EdgeInsets.all(80),
  );

  _mapController.fitCamera(cameraFit);
}


Future<Polyline?> _getPolylineFor(double lat, double lng) async {
  if (emergencyLatitude == null || emergencyLongitude == null) return null;

  final url = "https://api.openrouteservice.org/v2/directions/driving-car";
  final headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
    'Authorization': '5b3ce3597851110001cf6248fea3c11e56ea4db28f82d1f7ef7a6b71',
  };

  final body = jsonEncode({
    "coordinates": [
      [lng, lat],
      [emergencyLongitude, emergencyLatitude],
    ]
  });

  print("📤 ORS Body: $body");

  try {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    print("📡 ORS Status Code: ${response.statusCode}");
    print("📡 ORS Response Body: ${response.body}");

    final data = json.decode(response.body);

    if (data == null || data['routes'] == null || data['routes'].isEmpty) {
      print("⚠️ ORS returned empty or malformed data");
      return null;
    }

    final encodedGeometry = data['routes'][0]['geometry'];
    print("🧭 Decoding polyline: $encodedGeometry");

    final decoded = _decodePolyline(encodedGeometry);
    if (decoded.isEmpty) {
      print("⚠️ Failed to decode polyline");
      return null;
    }

    return Polyline(points: decoded, color: Colors.blue, strokeWidth: 4.0);
  } catch (e) {
    print("❌ ORS Exception: $e");
  }

  return null;
}

List<LatLng> _decodePolyline(String encoded) {
  List<LatLng> points = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;

    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lat += dlat;

    shift = 0;
    result = 0;

    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lng += dlng;

    points.add(LatLng(lat / 1E5, lng / 1E5));
  }

  return points;
}



void _updateMap() {
  print("🗺️ _updateMap() called");

  if (responderLatitude != null && responderLongitude != null &&
      emergencyLatitude != null && emergencyLongitude != null) {
    print("📍 Responder Location: $responderLatitude, $responderLongitude");
    print("📍 Emergency Location: $emergencyLatitude, $emergencyLongitude");
    if(mounted){
        setState(() {
          _markers = [
            Marker(
              point: LatLng(responderLatitude!, responderLongitude!),
              width: 80,
              height: 80,
              child: Column(
                children: const [
                  Icon(Icons.person_pin, color: Colors.blue, size: 40),
                  Text("Responder", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Marker(
              point: LatLng(emergencyLatitude!, emergencyLongitude!),
              width: 80,
              height: 80,
              child: Column(
                children: const [
                  Icon(Icons.local_hospital, color: Colors.red, size: 40),
                  Text("Emergency", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ];
        });
    }
  } else {
    print("⚠️ One or more coordinates are null:");
    print("Responder: $responderLatitude, $responderLongitude");
    print("Emergency: $emergencyLatitude, $emergencyLongitude");
  }
}

 void _startInAppCall() async {
  final String callId = "call_${DateTime.now().millisecondsSinceEpoch}";
  final DatabaseReference usersRef = _dbRef.child("users");

  final usersSnapshot = await usersRef.get();
  final List<String> filteredReceiverIds = [];

  if (usersSnapshot.exists) {
    final usersMap = Map<String, dynamic>.from(usersSnapshot.value as Map);

    for (final entry in usersMap.entries) {
      final userId = entry.key;
      final userData = Map<String, dynamic>.from(entry.value);

      final role = userData["user_role"];
      if (role == "Communicator" || role == "Admin") {
        // Check if already accepted in another call
        final callStatusSnap = await _dbRef
            .child("calls")
            .orderByChild("receivers/$userId")
            .equalTo("accepted")
            .limitToFirst(1)
            .get();

        if (!callStatusSnap.exists) {
          filteredReceiverIds.add(userId);
        } else {
          print("⚠️ Skipping $userId — already in an accepted call.");
        }
      }
    }
  }

  if (filteredReceiverIds.isEmpty) {
    print("❌ No available communicators/admins found.");
    return;
  }

  final WebRTCCallerService callerService = WebRTCCallerService();
  await callerService.startCall(context, filteredReceiverIds, callId);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CallScreen(
        callID: callId, 
        isCaller: true,
      ),
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("Emergency Tracking")),
    body: Stack(
      children: [
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (isResponderAssigned)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(9.651574, 123.866857),
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=jd2AEjGrt9Hd159cJ4E3',
                userAgentPackageName: 'com.example.app',
              ),
              PolylineLayer(polylines: _polylines),
              MarkerLayer(markers: _markers),
            ],
          )
        else
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_searching, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No responder assigned yet.\nPlease wait...",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),

        // ✅ Always show the call button
          Positioned(
              bottom: 20,
              left: 80,
              right: 80,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 13, 37, 79),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  shadowColor: Colors.black45,
                ),
                icon: const Icon(Icons.call, size: 24, color: Colors.white),
                label: const Text(
                  "Start In-App Call",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: _startInAppCall,
              ),
            )

      ],
    ),
  );
}

}
