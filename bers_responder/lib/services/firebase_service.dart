import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:collection/collection.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final AudioPlayer _audioPlayer = AudioPlayer(); // ✅ Sound for emergency alerts

  User? get currentUser => FirebaseAuth.instance.currentUser;

Stream<List<Map<String, dynamic>>> getEmergencyStreamFromResponderUnits() {
  final uid = currentUser?.uid;
  if (uid == null) {
    print("🚫 No current user found, returning empty stream.");
    return const Stream.empty();
  }

  final responderUnitRef = _dbRef.child("responder_unit");
  final emergenciesRef = _dbRef.child("emergencies");

  final equality = const DeepCollectionEquality.unordered();
  List<Map<String, dynamic>> lastEmitted = [];

  return responderUnitRef.onValue.asyncMap((event) async {
    final unitData = event.snapshot.value as Map<dynamic, dynamic>?;

    if (unitData == null) {
      print("📭 No responder_unit data found.");
      return [];
    }

    final emergencyIDs = <String>{};

    for (final entry in unitData.entries) {
      final unit = Map<String, dynamic>.from(entry.value);
      if (unit['ER_ID'] == uid && unit['emergency_ID'] != null) {
        emergencyIDs.add(unit['emergency_ID'].toString());
      }
    }

    if (emergencyIDs.isEmpty) {
      print("🧑‍🚒 No active emergencies assigned to user: $uid");
      return [];
    }

    print("🆔 Matched emergency IDs: $emergencyIDs");

    final emergencySnapshot = await emergenciesRef.get();
    final allEmergencies = emergencySnapshot.value as Map<dynamic, dynamic>?;

    if (allEmergencies == null) {
      print("📭 No emergencies data found.");
      return [];
    }

    final matchedEmergencies = <Map<String, dynamic>>[];

    for (final id in emergencyIDs) {
      if (allEmergencies.containsKey(id)) {
        final emergency = Map<String, dynamic>.from(allEmergencies[id]);
        matchedEmergencies.add({
          "emergencyId": id,
          ...emergency,
        });
      }
    }

    print("📦 Matched emergencies: ${matchedEmergencies.length}");

    // ✅ Strip live-changing fields before comparison
    final filteredCurrent = matchedEmergencies
        .map((e) => Map<String, dynamic>.from(e)
          ..removeWhere((key, _) => ['latitude', 'longitude', 'timestamp'].contains(key)))
        .toList();

    final filteredLast = lastEmitted
        .map((e) => Map<String, dynamic>.from(e)
          ..removeWhere((key, _) => ['latitude', 'longitude', 'timestamp'].contains(key)))
        .toList();

    if (!equality.equals(filteredCurrent, filteredLast)) {
      print("✅ Data changed → Emitting updated emergency list.");
      lastEmitted = matchedEmergencies;
      return matchedEmergencies;
    } else {
      print("⏸ No significant change in data → Skipping emission.");
      return lastEmitted;
    }
  });
}


Future<void> updateEmergencyStatus(String emergencyId, String status) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("⚠️ No signed-in user.");
      return;
    }

    final currentUid = user.uid;
    final emergencyRef = _dbRef.child("emergencies/$emergencyId");
    final emergencySnapshot = await emergencyRef.once();

    if (!emergencySnapshot.snapshot.exists || emergencySnapshot.snapshot.value == null) {
      print("⚠️ Emergency not found.");
      return;
    }

    final emergencyData = Map<String, dynamic>.from(
      emergencySnapshot.snapshot.value as Map<dynamic, dynamic>,
    );
    final responderRaw = emergencyData["responder_ID"] as String?;

    if (responderRaw == null || responderRaw.trim().isEmpty) {
      print("⚠️ No responder_ID found for this emergency.");
      return;
    }

    final responderIds = responderRaw.split(",").map((id) => id.trim()).toList();
    print("🧩 Parsed responder IDs: $responderIds");

    if (!responderIds.contains(currentUid)) {
      print("⛔ Current user is not assigned to this emergency.");
      return;
    }

    final unitSnapshot = await _dbRef
        .child("responder_unit")
        .orderByChild("ER_ID")
        .equalTo(currentUid)
        .once();

    if (!unitSnapshot.snapshot.exists || unitSnapshot.snapshot.value == null) {
      print("⚠️ No responder unit found for current user: $currentUid.");
      return;
    }

    final unitData = Map<String, dynamic>.from(unitSnapshot.snapshot.value as Map);
    final unitId = unitData.keys.first;

    await emergencyRef.update({
      "report_Status": status,
    });

    await _dbRef.child("responder_unit/$unitId").update({
      "unit_Status": status == "Responding" ? "Responding" : "Idle",
    });

    print("✅ Updated emergency and responder unit [$unitId] for user $currentUid");

  } catch (e) {
    print("❌ Error updating emergency status: $e");
  }
}


  /// ✅ Update responder's live location in responder_unit and emergency
Future<void> updateResponderLocation(double lat, double lng) async {
  final user = currentUser;
  if (user == null) return;

  final userRef = _dbRef.child("users/${user.uid}");

  // 🔍 Check if location_status is 'Active'
  final userSnapshot = await userRef.child("location_status").get();
  final status = userSnapshot.value?.toString();

  if (status != "Active") {
    print("⛔ Location update skipped. Status is not 'Active'.");
    return;
  }

  // 🔍 Find responder unit
  final responderSnapshot = await _dbRef
      .child("responder_unit")
      .orderByChild("ER_ID")
      .equalTo(user.uid)
      .get();

  if (!responderSnapshot.exists) {
    print("⚠️ No responder unit found for UID: ${user.uid}");
    return;
  }

  final responderData = Map<String, dynamic>.from(responderSnapshot.value as Map);
  final responderUnitId = responderData.keys.first;

  // ✅ Update location in responder_unit
  await _dbRef.child("responder_unit/$responderUnitId").update({
    "latitude": lat,
    "longitude": lng,
    "timestamp": DateTime.now().toIso8601String(),
  });

  // ✅ Update emergency if status is 'Responding'
  final emergencySnapshot = await _dbRef
      .child("emergencies")
      .orderByChild("responder_ID")
      .equalTo(user.uid)
      .get();

  if (emergencySnapshot.exists) {
    final emergencies = Map<String, dynamic>.from(emergencySnapshot.value as Map);

    for (var entry in emergencies.entries) {
      final emergencyId = entry.key;
      final emergencyData = Map<String, dynamic>.from(entry.value);

      if (emergencyData['report_Status'] == "Responding") {
        await _dbRef.child("emergencies/$emergencyId").update({
          "live_responder_latitude": lat,
          "live_responder_longitude": lng,
          "last_updated_responder_location": DateTime.now().toIso8601String(),
        });

        print("✅ Emergency location updated for ID: $emergencyId");
        return;
      }
    }
  }
}


  Future<void> playEmergencySound() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // 🔁 Looping mode
      await _audioPlayer.setVolume(1.0); // ensure volume is up
      await _audioPlayer.play(AssetSource('audio/alert.mp3'));
      print("🔊 Emergency sound playing in loop.");
    } catch (e) {
      print("❌ Error playing emergency sound: $e");
    }
  }

  // Call this to stop the alert sound
  Future<void> stopEmergencySound() async {
    try {
      await _audioPlayer.stop();
      print("🔇 Emergency sound stopped.");
    } catch (e) {
      print("❌ Error stopping emergency sound: $e");
    }
  }

  
}


