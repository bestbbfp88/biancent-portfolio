import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class TicketSaveService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.path, 'compressed_${path.basename(file.path)}');

    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );

    if (compressed == null) {
      return file; // fallback to original if compression fails
    }

    return File(compressed.path);
  }

  Future<void> saveTicketData({
    required String dispatchId,
    required String emergencyId,
    required Map<String, dynamic> dispatchData,
    Map<String, dynamic>? ambulanceData,
    List<File>? documentationFiles,
    List<Map<String, String>>? vitalsData,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in.");

    final uid = user.uid;
    final ticketRef = _db.child("tickets/$dispatchId/responder_data/$uid");
    final emergencyRef = _db.child("emergencies/$emergencyId");

    final List<String> mediaUrls = [];
    if (documentationFiles != null && documentationFiles.isNotEmpty) {
      for (File file in documentationFiles) {
        final compressedFile = await _compressImage(file);
        final fileName = path.basename(compressedFile.path);
        final storageRef = _storage.ref().child('documentation/$dispatchId/$uid/$fileName');

        final uploadTask = await storageRef.putFile(compressedFile);
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        mediaUrls.add(downloadUrl);
      }

      if (mediaUrls.isNotEmpty) {
        await ticketRef.child("documentation").set(mediaUrls);
      }
    }

    final currentDispatchSnapshot = await ticketRef.child("dispatch").get();
    Map<String, dynamic> existingDispatchData = {};
    if (currentDispatchSnapshot.exists) {
      existingDispatchData = Map<String, dynamic>.from(currentDispatchSnapshot.value as Map);
    }

    Map<String, dynamic> fullDispatchData = {
      ...existingDispatchData,
      ...dispatchData,
    };

    final responderUnitsSnapshot = await _db.child("responder_unit").get();
    if (responderUnitsSnapshot.exists) {
      final units = Map<String, dynamic>.from(responderUnitsSnapshot.value as Map);
      for (final entry in units.entries) {
        final unitKey = entry.key;
        final unitData = Map<String, dynamic>.from(entry.value);

        if (unitData['ER_ID'] == uid) {
          final unitName = unitData['unit_Name'];
          if (unitName != null) {
            fullDispatchData['unit_Name'] = unitName;
          }

          await _db.child("responder_unit/$unitKey").update({
            "unit_Status": "Active",
            "emergency_ID": null,
          });
        }
      }
    }

    await ticketRef.child("dispatch").update(fullDispatchData);

    if (ambulanceData != null) {
      final newAmbulanceRef = _db.child("ambulance").push();
      await newAmbulanceRef.set(ambulanceData);
      final ambulanceId = newAmbulanceRef.key;

      // 🟢 Save ambulance_id under the responder_data root, not inside dispatch
      await ticketRef.child("ambulance_id").set(ambulanceId);

      if (vitalsData != null && vitalsData.isNotEmpty) {
        final newVitalsRef = _db.child("vitals").push();
        await newVitalsRef.set({"entries": vitalsData});
        final vitalsId = newVitalsRef.key;

        // Link vitals to ambulance
        await _db.child("ambulance/$ambulanceId/vitals_id").set(vitalsId);
      }
    }


    await emergencyRef.child("report_Status").set("Done");

    print("✅ Ticket data saved for responder: $uid");
  }
}
