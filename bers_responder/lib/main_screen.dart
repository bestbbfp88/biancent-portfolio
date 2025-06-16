import 'dart:async';

import 'package:bers_responder/login_page.dart';
import 'package:bers_responder/screens/ticket_details.dart/ticket_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page.dart';
import 'screens/er_form_page.dart';
import 'bohol_map_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  bool isActive = true; // Default status
  bool isUnitResponding = false; // true = Responding, false = Active
  
  Timer? _responderHealthTimer;
  LatLng? _lastKnownLocation;
  bool isUnitInDistress = false;


  final List<Widget> pages = [
    const BoholMapPage(),
    const TicketDetailsPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchLocationStatus(); // ✅ Fetch status when the app starts
    _fetchUnitStatus(); // 👈 Add this
    _startResponderHealthCheck();

  }


void _startResponderHealthCheck() {
  _responderHealthTimer?.cancel();

  // Every 1 minute, check if responder is stuck or unresponsive
  _responderHealthTimer = Timer.periodic(const Duration(minutes: 1), (_) {
    _checkResponderStuckOrOffline();
  });
}

Future<void> _checkResponderStuckOrOffline() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final responderRef = FirebaseDatabase.instance.ref("responder_unit");
  final snapshot = await responderRef.once();
  final responders = snapshot.snapshot.value as Map?;

  if (responders != null) {
    for (final entry in responders.entries) {
      final unit = entry.value as Map;
      if (unit['ER_ID'] == user.uid) {
        final lat = double.tryParse(unit['latitude'].toString());
        final lng = double.tryParse(unit['longitude'].toString());
        final lastUpdate = DateTime.tryParse(unit['last_location_update'] ?? '');

        if (lat == null || lng == null || lastUpdate == null) return;

        final now = DateTime.now();
        final stagnant = _lastKnownLocation != null &&
            (_lastKnownLocation!.latitude == lat && _lastKnownLocation!.longitude == lng);

        final noUpdate = now.difference(lastUpdate).inMinutes > 3;

        if (stagnant && noUpdate) {
          print("🚨 Responder not moving and not updating — UNRESPONSIVE.");
          await _markResponderUnresponsiveWithReassign(); 
        } else {
          _lastKnownLocation = LatLng(lat, lng);
        }
      }
    }
  }
}


void _showEmergencyAlert(bool reassigned) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("🚨 Distress Sent"),
      content: Text(
        reassigned
            ? "You’ve been marked as in distress. The emergency has been reassigned."
            : "You’ve been marked as in distress.",
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



void _fetchUnitStatus() async {
    final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final unitsRef = FirebaseDatabase.instance.ref("responder_unit");

  unitsRef.onValue.listen((DatabaseEvent event) {
    if (!event.snapshot.exists) return;

    final units = Map<String, dynamic>.from(event.snapshot.value as Map);

    for (final unit in units.values) {
      if (unit is Map && unit['ER_ID'] == user.uid) {
        final status = unit['unit_Status'];
        print("📡 [LISTEN] Unit Status from Firebase: $status");

        if (mounted) {
          setState(() {
            isUnitResponding = status == "Responding";
            isUnitInDistress = status == "Emergency";
          });
        }
        break;
      }
    }
  });
}


  /// 🔥 Fetch & Listen to `location_status` from Firebase
  void _fetchLocationStatus() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final databaseRef = FirebaseDatabase.instance.ref("users/${user.uid}/location_status");

    // 🔄 Listen for changes in `location_status`
    databaseRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        String status = event.snapshot.value.toString();
        setState(() {
          isActive = status == "Active"; // ✅ Update UI based on Firebase
        });
        print("📡 Fetched location_status: $status");
      }
    });
  }

@override
Widget build(BuildContext context) {
  final bool isERFormPage = selectedIndex == 1;
  const selectedColor = Color.fromARGB(255, 16, 9, 74);
  const unselectedColor = Colors.grey;

  return Scaffold(
    appBar: isERFormPage
        ? null
        : AppBar(title: const Text('Emergency Responder')),

    drawer: isERFormPage ? null : _buildSidebar(context),

    body: IndexedStack(
      index: selectedIndex,
      children: pages,
    ),

    bottomNavigationBar: BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => setState(() => selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.map,
            color: selectedIndex == 0 ? selectedColor : unselectedColor,
          ),
          label: "Map",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.note_add,
            color: selectedIndex == 1 ? selectedColor : unselectedColor,
          ),
          label: "ER Form",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: selectedIndex == 2 ? selectedColor : unselectedColor,
          ),
          label: "Profile",
        ),
      ],
    ),
  );
}


Future<void> _updateUnitStatus(bool isResponding) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final unitsRef = FirebaseDatabase.instance.ref("responder_unit");
  final snapshot = await unitsRef.once();
  final units = snapshot.snapshot.value as Map?;

  if (units != null) {
    for (final entry in units.entries) {
      final unitKey = entry.key;
      final unit = entry.value;

      if (unit is Map && unit['ER_ID'] == user.uid) {
        await unitsRef.child(unitKey).update({
          "unit_Status": isResponding ? "Responding" : "Active",
        });
        print("✅ Unit status updated to ${isResponding ? "Responding" : "Active"}");
        break;
      }
    }
  }
}

  /// Sidebar with status toggle & logout
 Widget _buildSidebar(BuildContext context) {
  return SizedBox(
    width: 300, // 👈 Set your desired width here
    child: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.redAccent),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.settings, size: 32, color: Colors.white),
                SizedBox(width: 10),
                Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
          const Divider(thickness: 2),
          ListTile(
            leading: const Icon(Icons.sync, color: Colors.black),
            title: const Text('Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            trailing: Switch(
              value: isActive,
              onChanged: (bool value) {
                setState(() {
                  isActive = value;
                });
                _updateLocationStatus(value); // ✅ Update status in Firebase
              },
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
            ),
            subtitle: Text(
              isActive ? "Active" : "Inactive",
              style: TextStyle(color: isActive ? Colors.green : Colors.red),
            ),
          ),
          const Divider(thickness: 2),
          ListTile(
            leading: const Icon(Icons.directions_car, color: Colors.black),
            title: const Text('Unit Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            trailing: Switch(
              value: isUnitResponding,
              onChanged: (bool value) {
                setState(() => isUnitResponding = value);
                _updateUnitStatus(value); // 👈 Update in Firebase
              },
              activeColor: Colors.blue,
              inactiveThumbColor: Colors.green,
            ),
            subtitle: Text(
              isUnitResponding ? "Responding" : "Active",
              style: TextStyle(color: isUnitResponding ? Colors.blue : Colors.green),
            ),
          ),

          const Divider(thickness: 2),
          
         isUnitInDistress
          ? Builder(
              builder: (_) {
                debugPrint("🟢 DEBUG: Unit is in distress. Showing 'Mark Safe' tile.");
                return ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text(
                    'Mark Safe',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  subtitle: const Text("You're marked as in distress"),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: _showMarkSafeConfirmationDialog,
                    child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                  ),
                );
              },
            )
          : Builder(
              builder: (_) {
                debugPrint("🟡 DEBUG: Unit is NOT in distress. Showing 'Emergency SOS' tile.");
                return ListTile(
                  leading: const Icon(Icons.sos, color: Colors.red),
                  title: const Text(
                    'Emergency SOS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  subtitle: const Text("Mark yourself in danger"),
                  onTap: () => _showSosConfirmationDialog(),
                );
              },
            ),



          const Divider(thickness: 2),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            onTap: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
    ),
  );
}

void _showMarkSafeConfirmationDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("✅ Mark as Safe"),
      content: const Text("Are you sure you want to mark yourself as safe? This will notify the dispatcher that you're no longer in distress."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () async {
            Navigator.pop(context);
            await _markUnitSafe();
          },
          child: const Text("Yes, Mark Safe", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}


Future<void> _markUnitSafe() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final unitRef = FirebaseDatabase.instance.ref("responder_unit");

  final snapshot = await unitRef.once();
  final units = snapshot.snapshot.value as Map?;

  if (units != null) {
    for (final entry in units.entries) {
      final unitKey = entry.key;
      final unitData = entry.value as Map;

      if (unitData['ER_ID'] == user.uid) {
        await unitRef.child(unitKey).update({
          "unit_Status": "Active",
          "responder_unresponsive": false,
        });
            if(mounted){
                setState(() {
                  isUnitInDistress = false;
                  isUnitResponding = false;
                });
            }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ You are now marked as safe.")),
        );

        break;
      }
    }
  }
}

    void _showSosConfirmationDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("🚨 Emergency SOS"),
          content: const Text("Do you want to mark yourself in distress and reassign the emergency to another responder?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                await _markResponderUnresponsiveWithReassign();
              },
              child: const Text("Yes, Reassign", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

Future<void> _markResponderUnresponsiveWithReassign() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final db = FirebaseDatabase.instance;
  final unitsRef = db.ref("responder_unit");
  final emergenciesRef = db.ref("emergencies");

  final unitsSnapshot = await unitsRef.once();
  final emergenciesSnapshot = await emergenciesRef.once();

  String? emergencyIdToUpdate;

  // ✅ Step 1: Update unit_Status = "Emergency"
  if (unitsSnapshot.snapshot.value != null) {
    final units = Map<String, dynamic>.from(unitsSnapshot.snapshot.value as Map);

    for (final entry in units.entries) {
      final unitKey = entry.key;
      final unitData = Map<String, dynamic>.from(entry.value);
      if (unitData['ER_ID'] == user.uid) {
        await unitsRef.child(unitKey).update({
          "unit_Status": "Emergency",
          "responder_ID": null,
          "responder_unresponsive": true,
          "last_distress": DateTime.now().toIso8601String(),
        });
        break;
      }
    }
  }

  if (emergenciesSnapshot.snapshot.value != null) {
    final emergencies = Map<String, dynamic>.from(emergenciesSnapshot.snapshot.value as Map);

    for (final entry in emergencies.entries) {
      final emergencyId = entry.key;
      final emergencyData = Map<String, dynamic>.from(entry.value);
      if (emergenciesSnapshot.snapshot.value != null) {
        final emergencies = Map<String, dynamic>.from(emergenciesSnapshot.snapshot.value as Map);

        for (final entry in emergencies.entries) {
          final emergencyId = entry.key;
          final emergencyData = Map<String, dynamic>.from(entry.value);
          final rawResponderId = emergencyData['responder_ID'];

          if (rawResponderId != null) {
            final responders = rawResponderId.toString().split(',').map((e) => e.trim()).toList();

            if (responders.contains(user.uid)) {
              responders.remove(user.uid);
              emergencyIdToUpdate = emergencyId;

              await emergenciesRef.child(emergencyId).update({
                "responder_ID": responders.isEmpty ? null : responders.join(','),
                "report_Status": "Assigning",
              });

              break;
            }
          }
        }
      }

    }
  }

  _showEmergencyAlert(emergencyIdToUpdate != null);
}


  /// Update `location_status` in Firebase when toggling switch
  Future<void> _updateLocationStatus(bool status) async {
    _fetchUnitStatus();
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("❌ User is not logged in. Cannot update location status.");
      return;
    }

    final databaseRef = FirebaseDatabase.instance.ref("users/${user.uid}");

    await databaseRef.update({
      "location_status": status ? "Active" : "Inactive",
    });

    print("✅ Updated location_status: ${status ? 'Active' : 'Inactive'}");
  }

 void _showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              // Close dialog
              Navigator.pop(context);

              // Sign out from Firebase
              await FirebaseAuth.instance.signOut();

              // Clear shared preferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Optionally disable Firebase persistence temporarily
              FirebaseDatabase.instance.setPersistenceEnabled(false);
              FirebaseDatabase.instance.goOffline();
              FirebaseDatabase.instance.goOnline();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );

              // Rebuild UI based on new auth state
              // No navigation needed if you're using StreamBuilder in main.dart
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

}
