import 'dart:io';

import 'package:bers_responder/helpers/form_storage_helper.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/ambulatory.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/breathing.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/responsiveness_modal.dart';
import 'package:bers_responder/screens/ticket_details.dart/ticket_ambulance_form.dart';
import 'package:bers_responder/screens/ticket_details.dart/ticket_documentation_form.dart';
import 'package:bers_responder/services/ticket_save_service.dart';
import 'package:bers_responder/services/ticket_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ticket_dispatch_form.dart'; // correct import
import 'package:bers_responder/widgets/top_tab_switcher.dart';
import 'package:bers_responder/screens/history_form.dart';
import 'package:collection/collection.dart'; // Already used in other parts


class TicketDetailsPage extends StatefulWidget {
  const TicketDetailsPage({super.key});

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {


  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController complaintController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController patientNumberController = TextEditingController();
  final TextEditingController responsivenessController = TextEditingController();
  final TextEditingController bleedingController = TextEditingController();
  final TextEditingController hazardController = TextEditingController();
  final TextEditingController firstResponderController = TextEditingController();
  final TextEditingController ambulatoryController = TextEditingController();
  final TextEditingController breathingController = TextEditingController();
  final TextEditingController preArrivalController = TextEditingController();
  final TextEditingController actionsTakenController = TextEditingController();

  // Controllers
  final TextEditingController pcrAlarmController = TextEditingController();
  final TextEditingController signsSympController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController currentMediController = TextEditingController();
  final TextEditingController preMedController = TextEditingController();
  final TextEditingController mentalStatController = TextEditingController();
  final TextEditingController eyesStatController = TextEditingController();
  final TextEditingController breathSoundController = TextEditingController();
  final TextEditingController skinTempController = TextEditingController();
  final TextEditingController skinColorController = TextEditingController();
  final TextEditingController skinCapillaryRefController = TextEditingController();
  final TextEditingController painProvokeController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
  final TextEditingController vitalsqualityController = TextEditingController();
  final TextEditingController radiateController = TextEditingController();
  final TextEditingController severityController = TextEditingController();
  final TextEditingController skinMoistureController = TextEditingController();
  final TextEditingController timeOnsetDisplayController = TextEditingController();
  final TextEditingController customOtherConditionController = TextEditingController();
  final TextEditingController otherSymptomController = TextEditingController();
  final TextEditingController isToSceneController = TextEditingController();
  final TextEditingController locationTypeController = TextEditingController();
  final TextEditingController responseTypeController = TextEditingController();
  final TextEditingController emergencyTypeController = TextEditingController();
  final TextEditingController otherEmergencyTypeController = TextEditingController();
  final TextEditingController mvcTypeController = TextEditingController();


  // State
  DateTime? timeOnset;
  List<Map<String, TextEditingController>> vitalsEntries = [];
  List<String> selectedMentalStates = [];
  Set<String> selectedMedicalConditions = {};
  Set<String> selectedCardiacConditions = {};
  Set<String> selectedOtherConditions = {};
  List<String> selectedSymptoms = [];
  List<String> selectedBreathSounds = [];
  List<String> selectedEyeStates = [];
  bool _hasInitializedForm = false;
  bool _hasNewData = false;
  bool _isSaving = false;
  String? _lastReportStatus;
  bool? _lastAssigned;




  int _tabIndex = 0;
  int _currentStep = 0;
  String? userRole;
  final saveService = TicketSaveService();

  Map<String, dynamic>? _cachedTicketData;

  final equality = const DeepCollectionEquality().equals;
  late final Stream<Map<String, dynamic>?> _ticketStream;
  Key _formRefreshKey = UniqueKey();

@override
void initState() {
  super.initState();
  fetchUserRole();
  _ticketStream = listenToTicketDataForResponder().asBroadcastStream(); // 👈 fix here
}


void _populateControllers(
  Map<String, dynamic> newData, {
  bool preserveUserInput = false,
  Map<String, dynamic>? previousTicket,
}) {
  final newTicket = newData['ticket'] ?? {};
  final newEmergency = newData['emergency'] ?? {};

  final prevTicket = previousTicket ?? {};

  void smartUpdate(TextEditingController controller, String key, String? newValue) {
    final previousValue = prevTicket[key];
    final currentText = controller.text;
    final newText = newValue ?? '';

    print("🧪 smartUpdate → key: $key | prev: '$previousValue' | current: '$currentText' | new: '$newText'");

    if (!preserveUserInput) {
      controller.text = newText;
      print("✅ Overwrite [$key] with Firebase: '$newText'");
    } else {
      final firebaseEmpty = newText.trim().isEmpty;
      final userHasValue = currentText.trim().isNotEmpty;

      if (firebaseEmpty && userHasValue) {
        print("🛑 Skipped [$key] (Firebase empty, user has value)");
        // Don't overwrite – user input is preserved
      } else {
        controller.text = newText;
        print("✅ Updated [$key] from Firebase (Firebase won or user input empty): '$newText'");
      }
    }
  }

  smartUpdate(nameController, 'reporter_name', newTicket['reporter_name']);
  smartUpdate(emailController, 'reporter_email', newTicket['reporter_email']);
  smartUpdate(phoneController, 'reporter_contact', newTicket['reporter_contact']);
  smartUpdate(dobController, 'patient_birth', newTicket['patient_birth']);
  smartUpdate(addressController, 'location', newEmergency['location']);
  smartUpdate(complaintController, 'complaint_incident', newTicket['complaint_incident']);
  smartUpdate(notesController, 'notes', newTicket['notes']);
  smartUpdate(patientNumberController, 'number_of_patients', newTicket['number_of_patients']);
  smartUpdate(responsivenessController, 'responsiveness', newTicket['responsiveness']);
  smartUpdate(bleedingController, 'bleeding_site', newTicket['bleeding_site']);
  smartUpdate(breathingController, 'breathing', newTicket['breathing']);
  smartUpdate(hazardController, 'hazard_site', newTicket['hazard_site']);
  smartUpdate(ambulatoryController, 'ambulatory_status', newTicket['ambulatory_status']);
  smartUpdate(emergencyTypeController, 'emergencyType', newTicket['emergencyType']);
  smartUpdate(otherEmergencyTypeController, 'otherEmergencyType', newTicket['otherEmergencyType']);
  smartUpdate(mvcTypeController, 'mvcType', newTicket['mvcType']);
  
}



  Future<void> fetchUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final roleSnapshot = await FirebaseDatabase.instance.ref('users/$uid/responder_type').get();
    if (roleSnapshot.exists) {
      setState(() {
        userRole = roleSnapshot.value.toString();
      });
    }
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color.fromARGB(255, 150, 149, 149), // Label text color
      ),
      hintStyle: const TextStyle(
        color: Color.fromARGB(255, 102, 102, 102), // Hint text color (optional)
      ),
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }


 Widget buildDispatchForm() {

  return Column(
    children: [
     
      /// 🟩 Emergency Type Dropdown
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Emergency Type", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFFF5F5F5),
              ),
              child: Text(
                emergencyTypeController.text,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),

      /// 🟨 Show otherEmergencyType if "Other" is selected
      if (emergencyTypeController.text == "Other")
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text("Other Emergency Type", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFFF5F5F5),
              ),
              child: Text(
                otherEmergencyTypeController.text,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),

        if (emergencyTypeController.text == "MVC")
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text("MVC Type", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                  color: const Color(0xFFF5F5F5),
                ),
                child: Text(
                  mvcTypeController.text,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),

      const SizedBox(height: 12),
      TextFormField(controller: nameController, decoration: buildInputDecoration("First name")),
      const SizedBox(height: 12),
      TextFormField(controller: emailController, enabled: false, decoration: buildInputDecoration("Email")),
      const SizedBox(height: 12),
      TextFormField(controller: phoneController, decoration: buildInputDecoration("Phone")),
      const SizedBox(height: 12),
      TextFormField(
        controller: dobController,
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
        decoration: buildInputDecoration("Date of Birth"),
      ),
      const SizedBox(height: 12),
      TextFormField(controller: addressController, enabled: false, decoration: buildInputDecoration("Address")),
      const SizedBox(height: 12),
      TextFormField(controller: complaintController, decoration: buildInputDecoration("Complaint")),
      const SizedBox(height: 12),
      TextFormField(controller: notesController, decoration: buildInputDecoration("Notes")),
      const SizedBox(height: 12),
      TextFormField(controller: patientNumberController, decoration: buildInputDecoration("Affected Individuals")),
      const SizedBox(height: 12),

      const SizedBox(height: 12),
      GestureDetector(
        onTap: () => showResponsivenessModal(
          context: context,
          controller: responsivenessController,
        ),
        child: AbsorbPointer(
          child: TextFormField(
            controller: responsivenessController,
            decoration: buildInputDecoration("Responsiveness"),
          ),
        ),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () => showAmbulatoryModal(
          context: context,
          controller: ambulatoryController,
        ),
        child: AbsorbPointer(
          child: TextFormField(
            controller: ambulatoryController,
            decoration: buildInputDecoration('Ambulatory Status'),
          ),
        ),
      ),

      const SizedBox(height: 12),

      GestureDetector(
        onTap: () => showBreathingModal(
          context: context,
          controller: breathingController,
        ),
        child: AbsorbPointer(
          child: TextFormField(
            controller: breathingController,
            decoration: buildInputDecoration('Breathing'),
          ),
        ),
      ),

      const SizedBox(height: 12),
      TextFormField(controller: bleedingController, decoration: buildInputDecoration("Bleeding Site")),
      const SizedBox(height: 12),
      TextFormField(controller: hazardController, decoration: buildInputDecoration("Hazard Site")),
      const SizedBox(height: 12),
      TextFormField(controller: actionsTakenController, decoration: buildInputDecoration("Actions Taken")),
      const SizedBox(height: 12),
      TextFormField(controller: preArrivalController, decoration: buildInputDecoration("Pre-Arrival Instructions")),
      const SizedBox(height: 12),
      TextFormField(controller: firstResponderController, decoration: buildInputDecoration("Emergency First Responders on Site")),
      const SizedBox(height: 12),
      const SizedBox(height: 16),
    ],
  );
}


Widget _buildFormContent(Map<String, dynamic> data) {
  return KeyedSubtree(
    key: _formRefreshKey, // 🆕 This forces widget rebuild on refresh
    child: Column(
      children: [
        buildStepHeader(),
        const Divider(height: 32),
        Expanded(child: SingleChildScrollView(child: buildStepContent())),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentStep > 0)
              TextButton(
                onPressed: () => setState(() => _currentStep -= 1),
                child: const Text("Back"),
              ),
            ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (_currentStep < visibleSteps.length - 1) {
                          setState(() => _currentStep += 1);
                          return;
                        }

                        setState(() => _isSaving = true); // Start loading

                        try {
                          final documentationPaths = await TicketDocumentationForm.getCachedMediaPaths();
                          final documentationFiles = documentationPaths.map((path) => File(path)).toList();

                          final dispatchData = {
                            'patient_name': nameController.text,
                            'phone': phoneController.text,
                            'dob': dobController.text,
                            'complaint_incident': complaintController.text,
                            'notes': notesController.text,
                            'number_of_patients': patientNumberController.text,
                            'responsiveness': responsivenessController.text,
                            'bleeding_site': bleedingController.text,
                            'hazard_site': hazardController.text,
                            'ambulatory_status': ambulatoryController.text,
                            'firstResponder': firstResponderController.text,
                            'breathing': breathingController.text,
                            'preArrival': preArrivalController.text,
                            'actionsTaken': actionsTakenController.text
                          };

                          Map<String, dynamic>? ambulanceData;
                          List<Map<String, String>>? vitalsData;

                          if (userRole == "TaRSIER Responder" || userRole == "MDRRMO") {
                            final tempData = <String, dynamic>{};

                            void addIfNotEmpty(String key, String? value) {
                              print("🔍 Checking $key = '$value'");
                              if (value != null && value.trim().isNotEmpty) {
                                print("✅ Added $key: $value");
                                tempData[key] = value;
                              } else {
                                print("🚫 Skipped $key (empty)");
                              }
                            }


                            void addListIfNotEmpty(String key, List list) {
                              if (list.isNotEmpty) {
                                tempData[key] = list;
                              }
                            }

                            addIfNotEmpty('pcr_alarm', pcrAlarmController.text);
                            addIfNotEmpty('signs_symptoms', signsSympController.text);
                            addIfNotEmpty('allergies', allergiesController.text);
                            addIfNotEmpty('current_medication', currentMediController.text);
                            addIfNotEmpty('pre_medical_condition', preMedController.text);
                            addListIfNotEmpty('selected_medical_conditions', selectedMedicalConditions.toList());
                            addListIfNotEmpty('selected_cardiac_conditions', selectedCardiacConditions.toList());
                            addListIfNotEmpty('selected_other_conditions', selectedOtherConditions.toList());
                            addIfNotEmpty('custom_other_condition', customOtherConditionController.text);
                            addIfNotEmpty('mental_status', mentalStatController.text);
                            addIfNotEmpty('eye_status', eyesStatController.text);
                            addIfNotEmpty('breath_sounds', breathSoundController.text);
                            addIfNotEmpty('skin_temp', skinTempController.text);
                            addIfNotEmpty('skin_color', skinColorController.text);
                            addIfNotEmpty('capillary_refill', skinCapillaryRefController.text);
                            addIfNotEmpty('pain_provoke', painProvokeController.text);
                            addIfNotEmpty('pain_quality', qualityController.text);
                            addIfNotEmpty('pain_severity', severityController.text);
                            addIfNotEmpty('pain_radiate', radiateController.text);
                            addIfNotEmpty('skin_moisture', skinMoistureController.text);
                            addIfNotEmpty('pain_onset_time_display', timeOnsetDisplayController.text);
                            addIfNotEmpty('vitals_quality', vitalsqualityController.text);
                            addIfNotEmpty('is_to_scene', isToSceneController.text);
                            addIfNotEmpty('location_type', locationTypeController.text);
                            addIfNotEmpty('response_type', responseTypeController.text);

                            if (timeOnset != null) {
                              tempData['pain_onset_time'] = timeOnset!.toIso8601String();
                            }

                            addListIfNotEmpty('selected_mental_states', selectedMentalStates);
                            addListIfNotEmpty('selected_symptoms', selectedSymptoms);
                            addListIfNotEmpty('selected_breath_sounds', selectedBreathSounds);
                            addListIfNotEmpty('selected_eye_states', selectedEyeStates);
                            addListIfNotEmpty('selected_medical_conditions', selectedMedicalConditions.toList());
                            addListIfNotEmpty('selected_cardiac_conditions', selectedCardiacConditions.toList());
                            addListIfNotEmpty('selected_other_conditions', selectedOtherConditions.toList());
                            addIfNotEmpty('custom_other_condition', customOtherConditionController.text);

                            final filteredVitals = vitalsEntries.map((entry) => {
                              'BP': entry['BP']?.text ?? '',
                              'PR': entry['PR']?.text ?? '',
                              'RR': entry['RR']?.text ?? '',
                              'SpO2': entry['SpO2']?.text ?? '',
                              'GCS': entry['GCS']?.text ?? '',
                              'Temp': entry['Temp']?.text ?? '',
                              'Time': entry['Time']?.text ?? '',
                              'Quality': entry['Quality']?.text ?? '',
                            }).where((v) => v.values.any((val) => val.trim().isNotEmpty)).toList();


                            if (filteredVitals.isNotEmpty) {
                              vitalsData = filteredVitals;
                            }

                            if (tempData.isNotEmpty) {
                              ambulanceData = tempData;
                            }
                          }

                          print("📝 is_to_scene: ${isToSceneController.text}");
                          print("📝 location_type: ${locationTypeController.text}");
                          print("📝 response_type: ${responseTypeController.text}");

                          print("🚑 Final ambulanceData: $ambulanceData");

                          await saveService.saveTicketData(
                            dispatchId: _cachedTicketData?['emergency']['dispatch_ID'],
                            emergencyId: _cachedTicketData?['emergencyId'],
                            dispatchData: dispatchData,
                            ambulanceData: ambulanceData,
                            documentationFiles: documentationFiles,
                            vitalsData: vitalsData,
                          );

                          await FormStorageHelper.clearAmbulanceForm();
                          clearForm();

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Ticket saved successfully")),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error saving ticket: $e")),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isSaving = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(_currentStep == visibleSteps.length - 1 ? "Save" : "Next →"),
              ),

          ],
        ),
      ],
    ),
  );
}

String? _validateVitalsEntry(Map<String, TextEditingController> entry) {
  final bp = entry['BP']?.text.trim() ?? '';
  final pr = int.tryParse(entry['PR']?.text.trim() ?? '');
  final rr = int.tryParse(entry['RR']?.text.trim() ?? '');
  final spo2 = int.tryParse(entry['SpO2']?.text.trim() ?? '');
  final gcs = int.tryParse(entry['GCS']?.text.trim() ?? '');
  final temp = double.tryParse(entry['Temp']?.text.trim() ?? '');
  final time = entry['Time']?.text.trim();

  final bpPattern = RegExp(r'^\d{2,3}/\d{2,3}$');

  if (bp.isNotEmpty && !bpPattern.hasMatch(bp)) return "Invalid BP format (e.g., 120/80)";
  if (pr != null && (pr < 30 || pr > 180)) return "Pulse Rate must be 30–180";
  if (rr != null && (rr < 10 || rr > 40)) return "Respiratory Rate must be 10–40";
  if (spo2 != null && (spo2 < 0 || spo2 > 100)) return "SpO₂ must be 0–100%";
  if (gcs != null && (gcs < 3 || gcs > 15)) return "GCS must be 3–15";
  if (temp != null && (temp < 30 || temp > 43)) return "Temperature must be 30–43°C";
  if (time == null || time.isEmpty) return "Vitals Time is required";

  return null; // ✅ All valid
}


void clearForm() {
  // Clear text controllers
  for (final controller in [
    nameController,
    firstResponderController,
    ambulatoryController,
    breathingController,
    preArrivalController,
    actionsTakenController,
    emailController,
    phoneController,
    dobController,
    addressController,
    complaintController,
    notesController,
    patientNumberController,
    responsivenessController,
    bleedingController,
    hazardController,
    pcrAlarmController,
    signsSympController,
    allergiesController,
    currentMediController,
    preMedController,
    mentalStatController,
    eyesStatController,
    breathSoundController,
    skinTempController,
    skinColorController,
    skinCapillaryRefController,
    painProvokeController,
    qualityController,
    vitalsqualityController,
    radiateController,
    severityController,
    skinMoistureController,
    timeOnsetDisplayController,
    customOtherConditionController,
    otherSymptomController,
    isToSceneController,
    locationTypeController,
    responseTypeController,
    emergencyTypeController,
    otherEmergencyTypeController,
    mvcTypeController,
  ]) {
    controller.clear();
  }

  // Clear lists and flags
  selectedMentalStates.clear();
  selectedMedicalConditions.clear();
  selectedCardiacConditions.clear();
  selectedOtherConditions.clear();
  selectedSymptoms.clear();
  selectedBreathSounds.clear();
  selectedEyeStates.clear();
  vitalsEntries.clear();
  timeOnset = null;

  // UI reset
  _cachedTicketData = null;
  _hasInitializedForm = false;
  _hasNewData = false;
  _formRefreshKey = UniqueKey();
}


Widget buildStepHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: List.generate(visibleSteps.length, (index) {
      bool isActive = _currentStep == index;
      bool isCompleted = _currentStep > index;
      return Column(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isCompleted
                ? Colors.green
                : isActive
                    ? Colors.blue
                    : Colors.grey[300],
            child: Text(
              "${index + 1}",
              style: TextStyle(
                color: isActive || isCompleted ? Colors.white : Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            visibleSteps[index],
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.blue : Colors.black54,
            ),
          ),
        ],
      );
    }),
  );
}

List<String> get visibleSteps {
  if (userRole == "TaRSIER Responder" || userRole == "MDRRMO") {
    return ['Dispatch Form', 'Ambulance Form', 'Documentation'];
  } else {
    return ['Dispatch Form', 'Documentation'];
  }
}

Widget buildStepContent() {
  if (userRole == null) return const Center(child: CircularProgressIndicator());

  final stepName = visibleSteps[_currentStep];

  switch (stepName) {
    case 'Dispatch Form':
      return buildDispatchForm();

    case 'Ambulance Form':
      return TicketAmbulanceForm(
          pcrAlarmController: pcrAlarmController,
          signsSympController: signsSympController,
          allergiesController: allergiesController,
          currentMediController: currentMediController,
          preMedController: preMedController,
          mentalStatController: mentalStatController,
          eyesStatController: eyesStatController,
          breathSoundController: breathSoundController,
          skinTempController: skinTempController,
          skinColorController: skinColorController,
          skinCapillaryRefController: skinCapillaryRefController,
          painProvokeController: painProvokeController,
          qualityController: qualityController,
          vitalsqualityController: vitalsqualityController,
          radiateController: radiateController,
          severityController: severityController,
          skinMoistureController: skinMoistureController,
          timeOnset: timeOnset,
          onTimeOnsetChanged: (value) {
            setState(() {
              timeOnset = value;
            });
          },
          lsToSceneController: isToSceneController,
          locationTypeController: locationTypeController,
          responseTypeController: responseTypeController,

          timeOnsetDisplayController: timeOnsetDisplayController,
          selectedMentalStates: selectedMentalStates,
          selectedMedicalConditions: selectedMedicalConditions,
          selectedCardiacConditions: selectedCardiacConditions,
          selectedOtherConditions: selectedOtherConditions,
          customOtherConditionController: customOtherConditionController,
          vitalsEntries: vitalsEntries,
          onAddVitals: () {
            setState(() {
              vitalsEntries.add({
                  'BP': TextEditingController(),
                  'PR': TextEditingController(),
                  'RR': TextEditingController(),
                  'SpO2': TextEditingController(),
                  'GCS': TextEditingController(),
                  'Temp': TextEditingController(),
                  'Time': TextEditingController(),
                  'Quality': TextEditingController(), // NEW
                });
            });
          },
          showSymptomsModal: (_) {},
          showPreMedicalModal: (_) {},
          showMentalModal: (_) {},
          showEyesModal: (_) {},
          showBreathModal: (_) {},
          showSkinTempModal: (_) {},
          showSkinMoistureModal: (_) {},
          showSkinColorModal: (_) {},
          showQualityModal: (_) {},
          buildInputDecoration: buildInputDecoration,
          selectedSymptoms: selectedSymptoms,
          otherSymptomController: otherSymptomController,
          selectedBreathSounds: selectedBreathSounds,
          selectedEyeStates: selectedEyeStates,
        );


    case 'Documentation':
      return const TicketDocumentationForm();

    default:
      return const SizedBox();
  }
}


bool _shouldShowForm(Map<String, dynamic> data) {
  final responderUnit = data['responder_unit'] as Map<String, dynamic>?;
  final emergency = data['emergency'] as Map<String, dynamic>?;

  final assigned = data['emergencyId'] != null;
  final status = emergency?['report_Status']?.toString().toLowerCase();

  // 🧠 Only log if value is different AND not flip-flopping on null
  final hasMeaningfulChange = assigned != _lastAssigned ||
      (status != null && status != _lastReportStatus);

  if (hasMeaningfulChange) {
    _lastAssigned = assigned;
    _lastReportStatus = status;
    print("🧩 Assignment check → assigned: $assigned, report_Status: $status");
  }
  return assigned && status != 'done';
}



@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: StreamBuilder<Map<String, dynamic>?>(
        stream: _ticketStream,
        builder: (context, snapshot) {
          print("📡 Stream snapshot received. Has data: ${snapshot.hasData}");

          if (!snapshot.hasData || snapshot.data == null) {
            print("⏳ No data yet. Showing waiting state...");
            return const Center(
              child: Text(
                "⏳ Waiting for assignment...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange),
              ),
            );
          }

          final incomingData = snapshot.data!;

          final newTicket = incomingData['ticket'];
          final oldTicket = _cachedTicketData?['ticket'];

          final ticketChanged = !equality(newTicket, oldTicket);

          if (ticketChanged) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                print("🆕 Ticket data changed — user should refresh.");
                setState(() {
                  _hasNewData = true;
                  _cachedTicketData = incomingData;
                });
              }
            });
          } else {
            print("⏸️ No meaningful change in ticket data — no refresh needed.");
          }

          final showForm = _shouldShowForm(incomingData);
          final data = _cachedTicketData;

          return Column(
            children: [
              if (_hasNewData)
                Container(
                  margin: const EdgeInsets.only(top: 19.0, right: 16.0),
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text(
                          "New data available. Please refresh.",
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () async {
                          final emergencyId = _cachedTicketData?['emergencyId'];
                          final dispatchId = _cachedTicketData?['emergency']?['dispatch_ID'];

                          print("📥 Refresh requested");
                          print("📥 emergencyId: $emergencyId");
                          print("📥 dispatchId: $dispatchId");

                          if (emergencyId != null && dispatchId != null) {
                            final db = FirebaseDatabase.instance.ref();
                            final emergencySnap = await db.child("emergencies/$emergencyId").get();
                            final ticketSnap = await db.child("tickets/$dispatchId").get();

                            print("📡 emergencySnap exists: ${emergencySnap.exists}");
                            print("📡 ticketSnap exists: ${ticketSnap.exists}");

                            if (emergencySnap.exists && ticketSnap.exists) {
                              final updatedEmergency = Map<String, dynamic>.from((emergencySnap.value as Map).map((k, v) => MapEntry(k.toString(), v)));
                              final updatedTicket = Map<String, dynamic>.from((ticketSnap.value as Map).map((k, v) => MapEntry(k.toString(), v)));

                              final combinedData = {
                                "emergency": updatedEmergency,
                                "emergencyId": emergencyId,
                                "ticket": updatedTicket,
                              };

                              final oldTicket = _cachedTicketData?['ticket'] ?? {};

                              print("🔄 Merging fresh data into state");

                              setState(() {
                                _cachedTicketData = combinedData;
                                _populateControllers(
                                  combinedData,
                                  preserveUserInput: true,
                                  previousTicket: oldTicket,
                                );
                                _hasInitializedForm = true;
                                _hasNewData = false;
                                _formRefreshKey = UniqueKey();
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Data refreshed.")),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Failed to fetch latest data.")),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 15),

              TopTabSwitcher(
                  activeTab: _tabIndex == 0 ? 'form' : 'history',
                  onTabChanged: (tab) {
                    print("🧭 Tab switched to: $tab");

                    final safeData = data ?? {};
                    print("📦 Tab switch data: $safeData");

                    if (tab == 'form' && !_shouldShowForm(safeData)) {
                      print("🚫 No active assignment. Can't access form.");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("You are not assigned to any active emergency.")),
                      );
                      return;
                    }

                    setState(() => _tabIndex = tab == 'form' ? 0 : 1);
                  },
                ),

             // const SizedBox(height: 12),

              Expanded(
                child: Builder(
                  builder: (_) {
                    final shouldShowForm = data != null && _shouldShowForm(data);
                    print("📋 Should show form: $shouldShowForm | Tab index: $_tabIndex");

                    if (_tabIndex == 0 && shouldShowForm) {
                      return _buildFormContent(data!);
                    } else {
                      return HistoryFormContent(
                        activeTab: 'history',
                        onTabChanged: (tab) {
                          print("🧾 History tab toggled to: $tab");
                          if (tab == 'form' && !_shouldShowForm(data ?? {})) {
                            print("🚫 Blocked form tab switch due to no assignment.");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("You are not assigned to any active emergency.")),
                            );
                            return;
                          }
                          setState(() => _tabIndex = tab == 'form' ? 0 : 1);
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}


}
