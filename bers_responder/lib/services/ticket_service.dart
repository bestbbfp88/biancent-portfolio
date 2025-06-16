import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

Stream<Map<String, dynamic>?> listenToTicketDataForResponder() {
  final controller = StreamController<Map<String, dynamic>?>();
  final db = FirebaseDatabase.instance.ref();
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    controller.add(null);
    controller.close();
    return controller.stream;
  }

  late StreamSubscription unitSub;
  StreamSubscription? emergencySub;
  StreamSubscription? ticketSub;

  String? currentEmergencyId;
  Map<String, dynamic>? lastData;
  final equality = const DeepCollectionEquality().equals;

  unitSub = db.child("responder_unit")
      .orderByChild("ER_ID")
      .equalTo(user.uid)
      .onValue
      .listen((event) async {
    final units = event.snapshot.value as Map?;
    if (units == null || units.isEmpty) {
      print("⚠️ No responder_unit found");
      controller.add(null);
      return;
    }

    final unitEntry = units.entries.first;
    final unit = Map<String, dynamic>.from(unitEntry.value);
    final unitKey = unitEntry.key;
    final newEmergencyId = unit['emergency_ID'];

    final baseData = {
      'responder_unit': unit,
      'responder_unit_id': unitKey,
    };

    if (newEmergencyId == null || newEmergencyId.toString().trim().isEmpty) {
      print("🧩 No emergency_ID assigned in responder_unit");
      controller.add(baseData);
      return;
    }

    if (newEmergencyId == currentEmergencyId) {
      return;
    }
    currentEmergencyId = newEmergencyId;

    // Cancel old listeners
    await emergencySub?.cancel();
    await ticketSub?.cancel();

    // Fetch and listen to emergency
    final emergencyRef = db.child("emergencies/$newEmergencyId");
    emergencySub = emergencyRef.onValue.listen((eEvent) async {
      if (!eEvent.snapshot.exists) return;

      final emergency = Map<String, dynamic>.from(eEvent.snapshot.value as Map);
      final dispatchId = emergency["dispatch_ID"];
      if (dispatchId == null) return;

      final ticketRef = db.child("tickets/$dispatchId");
      ticketSub = ticketRef.onValue.listen((ticketEvent) {
        if (!ticketEvent.snapshot.exists) return;

        final ticket = Map<String, dynamic>.from(ticketEvent.snapshot.value as Map);

        final combined = {
          ...baseData,
          "emergency": emergency,
          "emergencyId": newEmergencyId,
          "ticket": ticket,
        };

        if (!equality(combined, lastData)) {
          lastData = combined;
          controller.add(combined);
        } else {
          print("⏸️ No change in unit/emergency/ticket, skipping emit.");
        }
      });
    });

    controller.add(baseData);
  });

  return controller.stream;
}
