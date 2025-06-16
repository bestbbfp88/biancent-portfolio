import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormStorageHelper {
  static Future<void> saveAmbulanceForm({
    required Map<String, TextEditingController> controllers,
    required List<String> selectedSymptoms,
    required List<String> selectedMentalStates,
    required Map<String, String> selectedEyeStates,
    required Map<String, String> selectedBreathSounds,
    required Set<String> selectedMedicalConditions,
    required Set<String> selectedCardiacConditions,
    required Set<String> selectedOtherConditions,
    required TextEditingController customOtherConditionController,
    required DateTime? timeOnset,
    required List<Map<String, TextEditingController>> vitalsEntries,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    for (var entry in controllers.entries) {
      await prefs.setString(entry.key, entry.value.text);
    }

    await prefs.setStringList('selectedSymptoms', selectedSymptoms);
    await prefs.setStringList('selectedMentalStates', selectedMentalStates);
    await prefs.setStringList('selectedMedicalConditions', selectedMedicalConditions.toList());
    await prefs.setStringList('selectedCardiacConditions', selectedCardiacConditions.toList());
    await prefs.setStringList('selectedOtherConditions', selectedOtherConditions.toList());

    await prefs.setString('customOtherCondition', customOtherConditionController.text);
    await prefs.setString('timeOnset', timeOnset?.toIso8601String() ?? '');

    // Encode maps
    await prefs.setString('selectedEyeStates', jsonEncode(selectedEyeStates));
    await prefs.setString('selectedBreathSounds', jsonEncode(selectedBreathSounds));

    // Encode vitals list of maps
    final vitalsJson = jsonEncode(vitalsEntries.map((e) => e.map((k, v) => MapEntry(k, v.text))).toList());
    await prefs.setString('vitalsEntries', vitalsJson);

    await prefs.setString('isToScene', controllers['isToScene']?.text ?? '');
    await prefs.setString('locationType', controllers['locationType']?.text ?? '');
    await prefs.setString('responseType', controllers['responseType']?.text ?? '');
  }

   static Future<Map<String, String>> loadAmbulanceForm({
  required Map<String, TextEditingController> controllers,
  required List<String> selectedSymptoms,
  required List<String> selectedMentalStates,
  required Map<String, String> selectedEyeStates,
  required Map<String, String> selectedBreathSounds,
  required Set<String> selectedMedicalConditions,
  required Set<String> selectedCardiacConditions,
  required Set<String> selectedOtherConditions,
  required TextEditingController customOtherConditionController,
  required void Function(DateTime?) onTimeOnsetChanged,
  required List<Map<String, TextEditingController>> vitalsEntries,
  required void Function() onVitalsUpdated,
})
 async {
    final prefs = await SharedPreferences.getInstance();

    for (var entry in controllers.entries) {
      entry.value.text = prefs.getString(entry.key) ?? '';
    }

    selectedSymptoms.clear();
    selectedSymptoms.addAll(prefs.getStringList('selectedSymptoms') ?? []);

    selectedMentalStates.clear();
    selectedMentalStates.addAll(prefs.getStringList('selectedMentalStates') ?? []);

    selectedMedicalConditions.clear();
    selectedMedicalConditions.addAll(prefs.getStringList('selectedMedicalConditions') ?? []);

    selectedCardiacConditions.clear();
    selectedCardiacConditions.addAll(prefs.getStringList('selectedCardiacConditions') ?? []);

    selectedOtherConditions.clear();
    selectedOtherConditions.addAll(prefs.getStringList('selectedOtherConditions') ?? []);

    customOtherConditionController.text = prefs.getString('customOtherCondition') ?? '';

    final onsetString = prefs.getString('timeOnset');
    if (onsetString != null && onsetString.isNotEmpty) {
      final parsed = DateTime.tryParse(onsetString);
      onTimeOnsetChanged(parsed);
    }

    // Decode maps
    final eyeStatesString = prefs.getString('selectedEyeStates');
    if (eyeStatesString != null) {
      final decoded = jsonDecode(eyeStatesString) as Map<String, dynamic>;
      selectedEyeStates.clear();
      decoded.forEach((key, value) => selectedEyeStates[key] = value.toString());
    }

    final breathSoundsString = prefs.getString('selectedBreathSounds');
    if (breathSoundsString != null) {
      final decoded = jsonDecode(breathSoundsString) as Map<String, dynamic>;
      selectedBreathSounds.clear();
      decoded.forEach((key, value) => selectedBreathSounds[key] = value.toString());
    }

    final vitalsJson = prefs.getString('vitalsEntries');
    if (vitalsJson != null) {
      List<dynamic> data = jsonDecode(vitalsJson);
      vitalsEntries.clear();
      for (var entry in data) {
        Map<String, TextEditingController> newEntry = {};
        (entry as Map<String, dynamic>).forEach((key, value) {
          newEntry[key] = TextEditingController(text: value);
        });
        vitalsEntries.add(newEntry);
      }
      onVitalsUpdated();
    }

     return {
      'isToScene': prefs.getString('isToScene') ?? '',
      'locationType': prefs.getString('locationType') ?? '',
      'responseType': prefs.getString('responseType') ?? '',
    };
  }

  static Future<void> clearAmbulanceForm() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
