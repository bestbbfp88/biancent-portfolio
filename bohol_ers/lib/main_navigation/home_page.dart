import 'dart:async';
import 'package:bohol_emergency_response_system/styles/FigureEightAnimation%20.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/location_service.dart';
import '../services/emergency_service.dart';
import '../emergency_request/dispatcher_tracking.dart'; // Ensure correct import
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final LocationService _locationService = LocationService();
  final EmergencyService _emergencyService = EmergencyService();
  String locationAddress = 'Fetching location...';
  bool isLoading = false;
  double _sosSize = 180; // Initial SOS Button Size
  late Timer _timer;
  Map<String, dynamic>? pendingEmergency; // Stores Pending Emergency Request
  bool _isFlashing = true;
  Color _colorStart = const Color(0xFF2D3748); // Deep navy
  Color _colorEnd = const Color(0xFFFF3B30);   // Emergency red


  @override
  void initState() {
    super.initState();
    _startFlashing();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStoredLocation();
      _checkPendingEmergency(); // Check for pending requests on startup

    });

    // Create a timer for the pulsating (glow) effect
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        setState(() {
          _sosSize = _sosSize == 180 ? 200 : 180; // Toggle size for glow effect
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Stop timer when widget is disposed
    super.dispose();
  }

  void _startFlashing() {
  Timer.periodic(const Duration(milliseconds: 600), (timer) {
    if (pendingEmergency == null && mounted) {
      setState(() {
        _isFlashing = !_isFlashing;
        _colorEnd = _isFlashing ? const Color(0xFFFF3B30) : const Color(0xFFFF8A80); // Lighter red
        _colorStart = _isFlashing ? const Color(0xFF2D3748) : const Color(0xFF4A5568); // Lighter navy
      });
    }
  });
}

Future<void> _fetchStoredLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedLocation = prefs.getString('last_location');

    if (storedLocation != null) {
      if(mounted){
        setState(() {
          locationAddress = storedLocation;
        });
      }
    }

    _fetchAddress(); // Check if we need to update location
  }

  /// Fetch User's Address
Future<void> _fetchAddress() async {
  final prefs = await SharedPreferences.getInstance();

  try {
    final result = await _locationService.getAddress();
    final newLocation = result.address;

    final lastStoredLocation = prefs.getString('last_location');

    if (newLocation != lastStoredLocation) {
      await prefs.setString('last_location', newLocation);
    }

    if (mounted) {
      setState(() => locationAddress = newLocation);
    }

    if (result.isLowAccuracy) {
      _showLowAccuracyDialog(result.accuracy ?? 0);
    }

  } catch (e) {
    print("❌ Error fetching address: $e");
    if (mounted) {
      setState(() => locationAddress = 'Failed to get location');
    }
  }
}


void _showLowAccuracyDialog(double accuracy) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("📡 Low Location Accuracy"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FigureEightAnimation(),
          const SizedBox(height: 16),
          Text(
            "Your current location accuracy is ${accuracy.toStringAsFixed(1)} meters.\n\n"
            "Please wave your phone in a figure 8 motion or move to an open area.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

  /// Check for Pending Emergency Requests
Future<void> _checkPendingEmergency() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("emergencies");

  try {
        final event = await dbRef
            .orderByChild("user_ID")
            .equalTo(currentUser.uid)
            .once();

    final DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      for (var entry in data.entries) {
        final requestData = entry.value as Map<dynamic, dynamic>;
        final status = requestData['report_Status'] ?? "";
       
        if (status == "Pending" || status == "Responding" || status == "Assigning") {
          if (mounted) {
            setState(() {
              pendingEmergency = {
                "id": entry.key,
                "location": requestData['location'] ?? "Unknown Location",
                "date_time": requestData['date_time'] ?? "Unknown Date",
                "status": status,  // ✅ Store the status
              };
            });
          }
          return; // Stop after finding the first pending or responding request
        }
      }
    }
   
    if (mounted) {
      setState(() {
        pendingEmergency = null;
      });
    }
  } catch (e) {
    debugPrint('❌ Error fetching emergencies: $e');
  }
}


  /// Show Emergency Type Selection Pop-up
  void _showEmergencyTypeDialog() {
    if (pendingEmergency != null) return; // Prevent dialog if there's a pending request

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Who are you calling for?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
            ),
            const SizedBox(height: 24),

            // Patient User Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _sendEmergency("Patient User"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 22, 5, 72),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("Patient User", style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 12),

            // Concerned User Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _sendEmergency("Concerned User"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 22, 5, 72),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("Concerned User", style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 20),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Cancel", style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );

  }

  /// Send Emergency Data
  void _sendEmergency(String type) async {
    if (isLoading) return;
      if(mounted){
      setState(() {
        isLoading = true;
      });
    }
    await _emergencyService.sendEmergencyData(context, type);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
      _checkPendingEmergency(); // Refresh pending emergency status after sending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Location Display Section
            Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFC), // soft background
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.teal.shade100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.my_location, size: 26, color: Colors.teal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Current Location',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              locationAddress.isNotEmpty ? locationAddress : 'Fetching location...',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

            if (pendingEmergency != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DispatcherTracking(emergencyId: pendingEmergency!['id']),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "${pendingEmergency!['status']} at ${pendingEmergency!['location']}",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                    ],
                  ),
                ),
              ),
            // SOS Button Section with Text Block
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: pendingEmergency != null ? null : _showEmergencyTypeDialog,
                    child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: _sosSize,
                    height: _sosSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                          BoxShadow(
                            color: pendingEmergency == null
                                ? _colorEnd.withOpacity(0.6) // 🔥 Match red from gradient
                                : Colors.grey.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 20,
                          ),
                          BoxShadow(
                            color: pendingEmergency != null
                                ? _colorStart.withOpacity(0.3) // 🔹 Match dark navy
                                : Colors.transparent,
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      gradient: pendingEmergency == null
                          ? LinearGradient(
                              colors: [_colorStart, _colorEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: pendingEmergency != null
                          ? const Color(0xFF7D7C7C)
                          : null,
                    ),
                    child: const Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Are you in an emergency?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: Text(
                      'Press the SOS button, your live location will be shared with the nearest help center and your emergency contacts.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
