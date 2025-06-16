// emergency_actions.dart
import 'package:bers_responder/services/route_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/emergency_model.dart';
import '../services/firebase_service.dart';
import '../services/navigation_tts_service.dart';
import '../services/location_service.dart';

class EmergencyActions {
  final FirebaseService firebaseService;
  final NavigationTTSService ttsService;

  EmergencyActions({
    required this.firebaseService,
    required this.ttsService,
  });

Future<void> acceptEmergency({
  required Emergency emergency,
  required RouteData? route,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final uid = user.uid;
  final emergencyId = emergency.id;

  await firebaseService.stopEmergencySound();

  final db = FirebaseDatabase.instance.ref();
  final responderUnitRef = db.child("responder_unit");

  // ✅ 1. Update this unit's status to Responding
  final responderSnapshot = await responderUnitRef.orderByChild("ER_ID").equalTo(uid).once();
  if (responderSnapshot.snapshot.exists) {
    final units = responderSnapshot.snapshot.value as Map;
    for (final entry in units.entries) {
      final unitKey = entry.key;
      final unit = Map<String, dynamic>.from(entry.value);
      if (unit["emergency_ID"] == emergencyId) {
        await responderUnitRef.child(unitKey).update({
          "unit_Status": "Responding",
        });
      }
    }
  }

  // ✅ 2. Check if all responders accepted (unit_Status == "Responding")
  final emergencyRef = db.child("emergencies/$emergencyId");
  final emergencySnap = await emergencyRef.once();

  if (!emergencySnap.snapshot.exists) {
    print("⚠️ Emergency not found.");
    return;
  }

  final emergencyData = Map<String, dynamic>.from(emergencySnap.snapshot.value as Map);
  final dispatchId = emergencyData["dispatch_ID"];
  final responderIDsRaw = emergencyData["responder_ID"] ?? "";

  List<String> responderIds = responderIDsRaw
      .toString()
      .split(",")
      .map((e) => e.trim())
      .where((id) => id.isNotEmpty)
      .toList();

  // Check each responder unit if already Responding
  final unitSnapshot = await responderUnitRef.get();
  bool allResponding = true;

  if (unitSnapshot.exists) {
    final allUnits = Map<String, dynamic>.from(unitSnapshot.value as Map);
    for (final unit in allUnits.values) {
      final unitData = Map<String, dynamic>.from(unit);
      final erId = unitData["ER_ID"];
      final unitStatus = unitData["unit_Status"];
      final unitEmergency = unitData["emergency_ID"];

      if (responderIds.contains(erId) &&
          unitEmergency == emergencyId &&
          unitStatus != "Responding") {
        allResponding = false;
        break;
      }
    }
  }

  // ✅ 3. Only update report_Status if ALL responders are now Responding
  if (allResponding) {
    await emergencyRef.update({
      "report_Status": "Responding",
    });
  }

  // ✅ 4. Store dispatch_time for this responder
  if (dispatchId != null) {
    final ticketRef = db.child("tickets/$dispatchId/responder_data/$uid/dispatch");
    await ticketRef.update({
      "dispatch_time": ServerValue.timestamp,
    });
  } else {
    print("⚠️ dispatch_ID not found in emergency record.");
  }
}

Future<void> declineEmergency({
  required Emergency emergency,
  required String reason,
}) async {
  final currentUid = FirebaseAuth.instance.currentUser?.uid;
  if (currentUid == null) return;

  final dbRef = FirebaseDatabase.instance.ref();
  final emergencyRef = dbRef.child("emergencies/${emergency.id}");
  final responderUnitRef = dbRef.child("responder_unit");

  // Step 1: Get existing responder_ID list
  final snapshot = await emergencyRef.child("responder_ID").get();
  if (!snapshot.exists) return;

  String responderRaw = snapshot.value as String? ?? "";
  List<String> responderIds = responderRaw
      .split(',')
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty && id != currentUid)
      .toList();

  final updatedResponderString = responderIds.join(",");

  // Step 2: Update responder_ID without the current user
  await emergencyRef.update({
    "responder_ID": updatedResponderString.isEmpty ? null : updatedResponderString,
  });

  // Step 3: Remove emergency_ID from current user's unit


  final unitSnapshot = await responderUnitRef.get();
  if (unitSnapshot.exists) {
    final units = unitSnapshot.value as Map;
    for (final entry in units.entries) {
      final unitKey = entry.key;
      final unit = Map<String, dynamic>.from(entry.value);

      if (unit["ER_ID"] == currentUid && unit["emergency_ID"] == emergency.id) {
        await responderUnitRef.child(unitKey).update({
          "emergency_ID": null,
          "unit_Status": "Active", // ✅ mark own unit as Responding after decline
        });
      }
    }
  }

  // Step 4: Check if any remaining responder is Responding
  bool noOneIsResponding = true;

  if (updatedResponderString.isNotEmpty && unitSnapshot.exists) {
    final units = Map<String, dynamic>.from(unitSnapshot.value as Map);
    for (final unit in units.values) {
      final unitData = Map<String, dynamic>.from(unit);
      final erId = unitData["ER_ID"];
      final emergencyID = unitData["emergency_ID"];
      final status = unitData["unit_Status"];

      if (responderIds.contains(erId) &&
          emergencyID == emergency.id &&
          status == "Responding") {
        noOneIsResponding = false;
        break;
      }
    }
  }

  // Step 5: Only reset report_Status to Assigning if no responders left or none are Responding
  if (updatedResponderString.isEmpty || noOneIsResponding) {
    await emergencyRef.update({
      "report_Status": "Assigning",
    });
    print("🔄 Status set to Assigning (no one left or no one accepted).");
  }

  // ✅ Step 6: Check if all remaining responders are Responding — set to "Responding" if so
  if (updatedResponderString.isNotEmpty) {
    bool allRemainingAreResponding = true;

    if (unitSnapshot.exists) {
      final units = Map<String, dynamic>.from(unitSnapshot.value as Map);
      for (final unit in units.values) {
        final unitData = Map<String, dynamic>.from(unit);
        final erId = unitData["ER_ID"];
        final emergencyID = unitData["emergency_ID"];
        final status = unitData["unit_Status"];

        if (responderIds.contains(erId) &&
            emergencyID == emergency.id &&
            status != "Responding") {
          allRemainingAreResponding = false;
          break;
        }
      }
    }

    if (allRemainingAreResponding) {
      await emergencyRef.update({
        "report_Status": "Responding",
      });
      print("✅ All remaining responders are Responding. Status updated.");
    }
  }

  // Step 7: Log decline in notifications
  final notificationRef = dbRef.child("notifications").push();
  await notificationRef.set({
    "type": "decline",
    "For": emergency.id,
    "From": currentUid,
    "Content": reason,
    "timestamp": ServerValue.timestamp,
    "status": "unread",
  });

  await firebaseService.stopEmergencySound();
}


  void showDeclineDialog(BuildContext context, Emergency emergency) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Decline Emergency"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please provide a reason for declining the emergency:"),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter reason",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  await declineEmergency(emergency: emergency, reason: reason);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a reason.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Decline"),
            ),
          ],
        );
      },
    );
  }
}
