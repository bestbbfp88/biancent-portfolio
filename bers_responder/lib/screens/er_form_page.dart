// import 'package:bers_responder/screens/history_form.dart';
// import 'package:bers_responder/services/ticket_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../widgets/top_tab_switcher.dart';

// class TicketDetailsPageCopy extends StatefulWidget {
//   const TicketDetailsPageCopy({super.key});

//   @override
//   State<TicketDetailsPageCopy> createState() => _TicketDetailsPageState();
// }

// class _TicketDetailsPageState extends State<TicketDetailsPageCopy> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _database = FirebaseDatabase.instance.ref();
//   int _tabIndex = 0;
//   int _currentStep = 0;
//   Map<String, dynamic>? _cachedTicketData;
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _complaintController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();
//   final TextEditingController _responsivenessController = TextEditingController();
//   final TextEditingController _hazardController = TextEditingController();
//   final TextEditingController _patientNumberController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _bleedingController = TextEditingController();// Ambulance Form
//   final TextEditingController _pcrAlarmController = TextEditingController();
//   String _isToScene = '';
//   String _locationType = '';
//   String _responseType = '';
//   final TextEditingController _signsSympController = TextEditingController();
//   final TextEditingController _allergiesController = TextEditingController();
//   final TextEditingController _currentMediController = TextEditingController();
//   final TextEditingController _preMedController = TextEditingController();
//   final TextEditingController _mentalStatController = TextEditingController();
//   final TextEditingController _eyesStatController = TextEditingController();
//   final TextEditingController _breathSoundController = TextEditingController();
//   final TextEditingController _skinTempController = TextEditingController();
//   final TextEditingController _skinColorController = TextEditingController();
//   final TextEditingController _skinCapillaryRefController = TextEditingController();
//   final TextEditingController _painProvokeController = TextEditingController();
//   final TextEditingController _qualityController = TextEditingController();
//   final TextEditingController _vitalsqualityController = TextEditingController();
//   final TextEditingController _radiateController = TextEditingController();
//   DateTime? _timeOnset;
//   final TextEditingController _severityController = TextEditingController();
//   String _hospitalID = ''; // Assume dropdown or lookup
//   final List<String> _symptomOptions = [
//   "Abdominal Pain", "Back Pain", "Bleeding", "Bloody Stool", "Breathing Difficulty",
//   "Cardiac Arrest", "Chest Pain", "Choking", "Diarrhea", "Dizziness", "Ear Pain",
//   "Eye Pain", "Fever/ Hyperthermia", "Headache", "Hypertension", "Hypothermia",
//   "Nausea", "Numbness", "Paralysis", "Palpitation", "Pregnancy/Childbirth",
//   "Respiratory Arrest", "Seizures/Convulsions", "Syncope", "Trauma", "Unresp./Unconscious",
//   "Vaginal Bleeding", "Vomiting", "Weakness", "Unknown", "Other", "None"
// ];

// final List<String> _medicalConditionOptions = [
//   "Abdominal Pain", "Back Pain", "Bleeding", "Bloody Stool", "Breathing Difficulty",
//   "CVA/TIA", "Diabetes", "Gastrointestinal", "Headache", "Hepatitis", "Hypotension",
//   "Seizures/Convulsions", "Tuberculosis", "Cardiac", "Others"
// ];

// final List<String> _cardiacConditions = [
//   "Angina", "Arrhythmia", "Congenital", "Congestive Heart Failure",
//   "Hypertension", "Myocardial Infarction", "Cardiac Surgery", "Seizures/Convulsions", "Palpitation"
// ];

// final List<String> _otherConditions = [
//   "Development Delay/MR", "Psychiatric", "Substance Abuse", "Tracheostomy", "Other", "None"
// ];

// final List<String> _mentalStateOptions = [
//   "Normal", "Confused", "Unconscious", "Combative", "N/A"
// ];

// final List<String> _eyeStateOptions = [
//   "PERRL",
//   "Reactive",
//   "Nonreactive",
//   "Constricted",
//   "Blind",
//   "Glaucoma",
// ];

// final List<String> _breathSoundGeneral = ["N/A", "Stridor"];
// final List<String> _breathSoundPerLung = [
//   "Clear", "Wet", "Decreased", "Wheezing", "Absent"
// ];
// final List<String> _skinTempOptions = ["Normal", "Cool/Cold", "Warm/Hot"];

// final List<String> _skinMoistureOptions = ["Normal", "Dry", "Moist", "Diaph"];
// final List<String> _skinColorOptions = ["Normal", "Cyanotic", "Pale", "Flushed", "Jaundice"];


//   String? _selectedSkinColor;
//   String? _selectedSkinMoisture;
//   String? _selectedSkinTemp;
//   Map<String, String> _selectedBreathSounds = {}; // condition: side or blan
//   Map<String, String> _selectedEyeStates = {}; // condition: eye side
//   List<String> _selectedMentalStates = [];
//   List<String> _selectedMedicalCondition = [];
//   List<String> _selectedSymptoms = [];
//   List<String> _selectedCardiacConditions = [];
//   List<String> _selectedOtherConditions = [];
//   List<Map<String, TextEditingController>> _vitalsEntries = [];

 
//   final TextEditingController _bpController = TextEditingController();
//   final TextEditingController _prController = TextEditingController();
//   final TextEditingController _rrController = TextEditingController();
//   final TextEditingController _sp02Controller = TextEditingController();
//   final TextEditingController _gcsController = TextEditingController();
//   final TextEditingController _tempController = TextEditingController();
//   final TextEditingController _otherSymptomController = TextEditingController();

//   final TextEditingController _customOtherConditionController = TextEditingController();
  
//   final TextEditingController _skinMoistureController = TextEditingController();


//   String selectedLocation = "";
//   String selectedTherapist = "";

//   @override
//   void initState() {
//     super.initState();
//     _addVitalsEntry();
//   }

// void _addVitalsEntry() {
//   _vitalsEntries.add({
//     'BP': TextEditingController(),
//     'PR': TextEditingController(),
//     'RR': TextEditingController(),
//     'SpO2': TextEditingController(),
//     'GCS': TextEditingController(),
//     'Temp': TextEditingController(),
//   });
// }
//   void saveDetails() async {
//     final ticket = _cachedTicketData?['ticket'] ?? {};
//     final emergencyId = _cachedTicketData?['emergencyId'];

//     if (ticket.isEmpty || emergencyId == null) return;

//     final dispatchID = ticket['dispatch_ID'];

//     await _database.child("tickets/$dispatchID").update({
//       'patient_name': _nameController.text,
//       'complaint_incident': _complaintController.text,
//       'notes': _notesController.text,
//       'responsiveness': _responsivenessController.text,
//       'patient_birth': _dobController.text,
//       'location': _addressController.text,
//       'bleeding_site': _bleedingController.text,
//       'hazard_site': _hazardController.text
//     });

//     await _database.child("emergencies/$emergencyId").update({
//       'report_Status': 'Done',
//     });

//     setState(() {
//       _cachedTicketData = null;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("Details saved successfully!"),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }


//  bool get isAmbulanceResponder {
//     final ticket = _cachedTicketData?['ticket'] ?? {};
//     final responderType = ticket['responder_type'] ?? '';
//     return responderType == 'MDRRMO' || responderType == 'TaRSIER Responder';
//   }

//   Future<void> saveAmbulanceAndVitals(String emergencyId) async {
//     final newVitalRef = _database.child('vitals').push();
//     final vitalID = newVitalRef.key;

//     await newVitalRef.set({
//       'vital_ID': vitalID,
//       'vital_For': _nameController.text,
//       'BP': _bpController.text,
//       'PR': _prController.text,
//       'RR': _rrController.text,
//       'SP02': _sp02Controller.text,
//       'GCS': _gcsController.text,
//       'Temp': _tempController.text
//     });

//     final newAmbulanceRef = _database.child('ambulance_form').push();
//     final formAID = newAmbulanceRef.key;

//     await newAmbulanceRef.set({
//       'formA_ID': formAID,
//       'PCR_Alarm_no': int.tryParse(_pcrAlarmController.text) ?? 0,
//       'Is_to_Scene': _isToScene,
//       'location_Type': _locationType,
//       'response_Type': _responseType,
//       'signs_symp': _signsSympController.text,
//       'allergies': _allergiesController.text,
//       'current_medi': _currentMediController.text,
//       'pre_med_condition': _preMedController.text,
//       'mental_Stat': _mentalStatController.text,
//       'eyes_Stat': _eyesStatController.text,
//       'breath_Sound': _breathSoundController.text,
//       'skin_Temp': _skinTempController.text,
//       'skin_Color': _skinColorController.text,
//       'skin_Capillary_ref': _skinCapillaryRefController.text,
//       'pain_Provoke': _painProvokeController.text,
//       'quality': _qualityController.text,
//       'radiate': _radiateController.text,
//       'time_Onset': _timeOnset?.toIso8601String() ?? '',
//       'severity': _severityController.text,
//       'hospital_ID': _hospitalID,
//       'vital_ID': vitalID,
//     });

//     await _database.child("emergencies/$emergencyId").update({
//       'ambulance_form_id': formAID,
//     });
//   }
//   InputDecoration buildInputDecoration(String label) {
//     return InputDecoration(
//       labelText: label,
//       border: const OutlineInputBorder(),
//       contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//     );
//   }

//   Widget buildStepHeader() {
//     List<String> steps = ["Dispatch Form", "Ambulance Form", "Documentation", ""];
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: List.generate(3, (index) {
//         bool isActive = _currentStep == index;
//         bool isCompleted = _currentStep > index;
//         return Column(
//           children: [
//             CircleAvatar(
//               radius: 12,
//               backgroundColor: isCompleted
//                   ? Colors.green
//                   : isActive
//                       ? Colors.blue
//                       : Colors.grey[300],
//               child: Text(
//                 "${index + 1}",
//                 style: TextStyle(
//                   color: isActive || isCompleted ? Colors.white : Colors.black54,
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               steps[index],
//               style: TextStyle(
//                 fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                 color: isActive ? Colors.blue : Colors.black54,
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }

//   Widget buildStepContent() {
//     switch (_currentStep) {
//       case 0:
//         return buildDispatchForm();
//       case 1:
//         return buildAmbulanceAndVitalsForm();
//       case 2:  
//       default:
//         return const SizedBox();
//     }
//   }

//   Widget buildDispatchForm() {
//     return Column(
//       children: [
//         TextFormField(controller: _nameController, decoration: buildInputDecoration("First name")),
//         const SizedBox(height: 12),
//         TextFormField(controller: _emailController, enabled: false, decoration: buildInputDecoration("Email")),
//         const SizedBox(height: 12),
//         TextFormField(controller: _phoneController, enabled: false, decoration: buildInputDecoration("Phone")),
//         const SizedBox(height: 12),
//         TextFormField(
//           controller: _dobController,
//           readOnly: true,
//           onTap: () async {
//             DateTime? pickedDate = await showDatePicker(
//               context: context,
//               initialDate: DateTime.now(),
//               firstDate: DateTime(1900),
//               lastDate: DateTime.now(),
//             );
//             if (pickedDate != null) {
//               _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
//             }
//           },
//           decoration: buildInputDecoration("Date of Birth"),
//         ),
//          const SizedBox(height: 12),
//         TextFormField(controller: _addressController, enabled: false, decoration: buildInputDecoration("Address")),
//          const SizedBox(height: 12),
//         TextFormField(controller: _complaintController, decoration: buildInputDecoration("Complaint")),
//         const SizedBox(height: 12),
//         TextFormField(controller: _notesController, decoration: buildInputDecoration("Notes")),
//         const SizedBox(height: 12),
//         TextFormField(controller: _patientNumberController, decoration: buildInputDecoration("Number of Patients")),
//         const SizedBox(height: 12),
//         TextFormField(controller: _responsivenessController, decoration: buildInputDecoration("Responsiveness")),
//          const SizedBox(height: 12),
//         TextFormField(controller: _bleedingController, decoration: buildInputDecoration("Bleeding Site")),
//         const SizedBox(height: 12),
//         TextFormField(controller: _hazardController, decoration: buildInputDecoration("Hazard Site")),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   Widget buildComplaintForm() {
//     return Column(
//       children: [
        
//       ],
//     );
//   }

 

//   Widget _buildFormContent(Map<String, dynamic> data) {
//     final ticket = data['ticket'];
//     final emergency = data['emergency'];

//     _nameController.text = ticket['patient_name'] ?? '';
//     _complaintController.text = ticket['complaint_incident'] ?? '';
//     _emailController.text = ticket['email'] ?? '';
//     _notesController.text = ticket['notes'] ?? '';
//     _phoneController.text = ticket['reporter_contact'] ?? '';
//     _responsivenessController.text = ticket['responsiveness'] ?? '';
//     _patientNumberController.text = ticket['number_of_patients'] ?? '';
//     _dobController.text = ticket['patient_birth'] ?? '';
//     _bleedingController.text = ticket['bleeding_site'] ?? '';
//     _hazardController.text = ticket['hazard_site'] ?? '';
//     _addressController.text = emergency['location'] ?? '';

//     return Column(
//       children: [
//         buildStepHeader(),
//         const Divider(height: 32),
//         Expanded(child: SingleChildScrollView(child: buildStepContent())),
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             if (_currentStep > 0)
//               TextButton(
//                 onPressed: () => setState(() => _currentStep -= 1),
//                 child: const Text("Back"),
//               ),
//             ElevatedButton(
//               onPressed: () {
//                 if (_currentStep < 2) {
//                   setState(() => _currentStep += 1);
//                 } else {
//                   saveDetails();
//                 }
//               },
//               child: Text(_currentStep == 2 ? "Save" : "Next →"),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// void _showSymptomsModal(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (context) {
//       return SafeArea(
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 16,
//             right: 16,
//             top: 16,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//           ),
//           child: StatefulBuilder(
//             builder: (context, setModalState) {
//               return SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text("Select Symptoms", style: TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 12),
//                     GridView.count(
//                       crossAxisCount: 2,
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       childAspectRatio: 4,
//                       children: _symptomOptions.map((symptom) {
//                         return CheckboxListTile(
//                           title: Text(symptom, style: const TextStyle(fontSize: 14)),
//                           value: _selectedSymptoms.contains(symptom),
//                           onChanged: (selected) {
//                             setModalState(() {
//                               if (selected == true) {
//                                 _selectedSymptoms.add(symptom);
//                               } else {
//                                 _selectedSymptoms.remove(symptom);
//                               }
//                             });
//                           },
//                           controlAffinity: ListTileControlAffinity.leading,
//                           contentPadding: EdgeInsets.zero,
//                         );
//                       }).toList(),
//                     ),
//                     if (_selectedSymptoms.contains('Other')) ...[
//                       const SizedBox(height: 12),
//                       TextFormField(
//                         controller: _otherSymptomController,
//                         decoration: buildInputDecoration("Specify Other"),
//                       ),
//                     ],
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {}); // update preview in dropdown field
//                         Navigator.pop(context);
//                       },
//                       child: const Text("Done"),
//                     )
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       );
//     },
//   );
// }

// void _showpreMedicalConditionModal(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (context) {
//       return SafeArea(
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 16,
//             right: 16,
//             top: 16,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//           ),
//           child: StatefulBuilder(
//             builder: (context, setModalState) {
//               return SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text("Select Existing Condition - Medical", style: TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 12),

//                     GridView.count(
//                       crossAxisCount: 2,
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       childAspectRatio: 4,
//                       children: _medicalConditionOptions.map((condition) {
//                         return CheckboxListTile(
//                           title: Text(condition, style: const TextStyle(fontSize: 14)),
//                           value: _selectedMedicalCondition.contains(condition),
//                           onChanged: (selected) {
//                             setModalState(() {
//                               if (selected == true) {
//                                 _selectedMedicalCondition.add(condition);
//                               } else {
//                                 _selectedMedicalCondition.remove(condition);
//                                 if (condition == "Cardiac") _selectedCardiacConditions.clear();
//                                 if (condition == "Others") {
//                                   _selectedOtherConditions.clear();
//                                   _customOtherConditionController.clear();
//                                 }
//                               }
//                             });
//                           },
//                           controlAffinity: ListTileControlAffinity.leading,
//                           contentPadding: EdgeInsets.zero,
//                         );
//                       }).toList(),
//                     ),

//                     const SizedBox(height: 12),

//                     // Cardiac Sub-Options
//                     if (_selectedMedicalCondition.contains("Cardiac")) ...[
//                       const Text("Cardiac Conditions", style: TextStyle(fontWeight: FontWeight.w600)),
//                       GridView.count(
//                         crossAxisCount: 2,
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         childAspectRatio: 4,
//                         children: _cardiacConditions.map((cardiac) {
//                           return CheckboxListTile(
//                             title: Text(cardiac, style: const TextStyle(fontSize: 14)),
//                             value: _selectedCardiacConditions.contains(cardiac),
//                             onChanged: (selected) {
//                               setModalState(() {
//                                 if (selected == true) {
//                                   _selectedCardiacConditions.add(cardiac);
//                                 } else {
//                                   _selectedCardiacConditions.remove(cardiac);
//                                 }
//                               });
//                             },
//                             controlAffinity: ListTileControlAffinity.leading,
//                             contentPadding: EdgeInsets.zero,
//                           );
//                         }).toList(),
//                       ),
//                     ],

//                     // Others Sub-Options
//                     if (_selectedMedicalCondition.contains("Others")) ...[
//                       const Text("Other Medical Conditions", style: TextStyle(fontWeight: FontWeight.w600)),
//                       GridView.count(
//                         crossAxisCount: 2,
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         childAspectRatio: 4,
//                         children: _otherConditions.map((item) {
//                           return CheckboxListTile(
//                             title: Text(item, style: const TextStyle(fontSize: 14)),
//                             value: _selectedOtherConditions.contains(item),
//                             onChanged: (selected) {
//                               setModalState(() {
//                                 if (selected == true) {
//                                   _selectedOtherConditions.add(item);
//                                 } else {
//                                   _selectedOtherConditions.remove(item);
//                                   if (item == "Other") {
//                                     _customOtherConditionController.clear();
//                                   }
//                                 }
//                               });
//                             },
//                             controlAffinity: ListTileControlAffinity.leading,
//                             contentPadding: EdgeInsets.zero,
//                           );
//                         }).toList(),
//                       ),
//                       if (_selectedOtherConditions.contains("Other"))
//                         TextFormField(
//                           controller: _customOtherConditionController,
//                           decoration: buildInputDecoration("Specify Other"),
//                         ),
//                     ],

//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {}); // to update display
//                         Navigator.pop(context);
//                       },
//                       child: const Text("Done"),
//                     )
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       );
//     },
//   );
// }

// void _showMentalStateModal(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (context) {
//       return SafeArea(
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 16,
//             right: 16,
//             top: 16,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//           ),
//           child: StatefulBuilder(
//             builder: (context, setModalState) {
//               return SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text("Select Mental State", style: TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 12),
//                     GridView.count(
//                       crossAxisCount: 2,
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       childAspectRatio: 4,
//                       children: _mentalStateOptions.map((state) {
//                         return CheckboxListTile(
//                           title: Text(state, style: const TextStyle(fontSize: 14)),
//                           value: _selectedMentalStates.contains(state),
//                           onChanged: (selected) {
//                             setModalState(() {
//                               if (selected == true) {
//                                 _selectedMentalStates.add(state);
//                               } else {
//                                 _selectedMentalStates.remove(state);
//                               }
//                             });
//                           },
//                           controlAffinity: ListTileControlAffinity.leading,
//                           contentPadding: EdgeInsets.zero,
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           _mentalStatController.text = _selectedMentalStates.join(', ');
//                         });
//                         Navigator.pop(context);
//                       },
//                       child: const Text("Done"),
//                     )
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       );
//     },
//   );
// }

// void _showEyesStateModal(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (context) {
//       return SafeArea(
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 16,
//             right: 16,
//             top: 16,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//           ),
//           child: StatefulBuilder(
//             builder: (context, setModalState) {
//               return SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text("Select Eyes State", style: TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 12),
//                     ..._eyeStateOptions.map((option) {
//                       final isSelected = _selectedEyeStates.containsKey(option);
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           CheckboxListTile(
//                             title: Text(option),
//                             value: isSelected,
//                             onChanged: (selected) {
//                               setModalState(() {
//                                 if (selected == true) {
//                                   _selectedEyeStates[option] = option == "PERRL" ? "" : "Right";
//                                 } else {
//                                   _selectedEyeStates.remove(option);
//                                 }
//                               });
//                             },
//                             controlAffinity: ListTileControlAffinity.leading,
//                             contentPadding: EdgeInsets.zero,
//                           ),
//                           if (isSelected && option != "PERRL")
//                             Padding(
//                               padding: const EdgeInsets.only(left: 32.0),
//                               child: Wrap(
//                                 spacing: 10,
//                                 children: ["Right", "Left", "Both"].map((side) {
//                                   return ChoiceChip(
//                                     label: Text(side),
//                                     selected: _selectedEyeStates[option] == side,
//                                     onSelected: (_) {
//                                       setModalState(() {
//                                         _selectedEyeStates[option] = side;
//                                       });
//                                     },
//                                   );
//                                 }).toList(),
//                               ),
//                             ),
//                           const SizedBox(height: 8),
//                         ],
//                       );
//                     }).toList(),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         final eyesDescription = _selectedEyeStates.entries.map((entry) {
//                           return entry.value.isNotEmpty ? "${entry.key} (${entry.value})" : entry.key;
//                         }).join(', ');

//                         setState(() {
//                           _eyesStatController.text = eyesDescription;
//                         });
//                         Navigator.pop(context);
//                       },
//                       child: const Text("Done"),
//                     )
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       );
//     },
//   );
// }

// void _showBreathSoundModal(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (context) {
//       return SafeArea(
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 16,
//             right: 16,
//             top: 16,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//           ),
//           child: StatefulBuilder(
//             builder: (context, setModalState) {
//               return SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text("Select Breath Sound", style: TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 12),

//                     // General Options
//                     ..._breathSoundGeneral.map((option) {
//                       return CheckboxListTile(
//                         title: Text(option),
//                         value: _selectedBreathSounds.containsKey(option),
//                         onChanged: (selected) {
//                           setModalState(() {
//                             if (selected == true) {
//                               _selectedBreathSounds[option] = "";
//                               if (option == "N/A") {
//                                 // Clear others if N/A is selected
//                                 _selectedBreathSounds
//                                   ..removeWhere((key, _) => key != "N/A");
//                               } else {
//                                 _selectedBreathSounds.remove("N/A");
//                               }
//                             } else {
//                               _selectedBreathSounds.remove(option);
//                             }
//                           });
//                         },
//                         controlAffinity: ListTileControlAffinity.leading,
//                         contentPadding: EdgeInsets.zero,
//                       );
//                     }),

//                     const SizedBox(height: 12),

//                     // Lung-specific options
//                     ..._breathSoundPerLung.map((sound) {
//                       final isSelected = _selectedBreathSounds.containsKey(sound);
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           CheckboxListTile(
//                             title: Text(sound),
//                             value: isSelected,
//                             onChanged: (selected) {
//                               setModalState(() {
//                                 if (selected == true) {
//                                   _selectedBreathSounds[sound] = "Left";
//                                   _selectedBreathSounds.remove("N/A");
//                                 } else {
//                                   _selectedBreathSounds.remove(sound);
//                                 }
//                               });
//                             },
//                             controlAffinity: ListTileControlAffinity.leading,
//                             contentPadding: EdgeInsets.zero,
//                           ),
//                           if (isSelected)
//                             Padding(
//                               padding: const EdgeInsets.only(left: 32.0),
//                               child: Wrap(
//                                 spacing: 10,
//                                 children: ["Left", "Right", "Both"].map((side) {
//                                   return ChoiceChip(
//                                     label: Text(side),
//                                     selected: _selectedBreathSounds[sound] == side,
//                                     onSelected: (_) {
//                                       setModalState(() {
//                                         _selectedBreathSounds[sound] = side;
//                                       });
//                                     },
//                                   );
//                                 }).toList(),
//                               ),
//                             ),
//                           const SizedBox(height: 8),
//                         ],
//                       );
//                     }),

//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         final summary = _selectedBreathSounds.entries.map((e) {
//                           return e.value.isNotEmpty ? "${e.key} (${e.value})" : e.key;
//                         }).join(', ');

//                         setState(() {
//                           _breathSoundController.text = summary;
//                         });

//                         Navigator.pop(context);
//                       },
//                       child: const Text("Done"),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       );
//     },
//   );
// }

// void _showSkinTempModal(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (context) {
//       return SafeArea(
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 16,
//             right: 16,
//             top: 16,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//           ),
//           child: StatefulBuilder(
//             builder: (context, setModalState) {
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("Select Skin Temperature", style: TextStyle(fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 12),
//                   ..._skinTempOptions.map((option) {
//                     return RadioListTile<String>(
//                       title: Text(option),
//                       value: option,
//                       groupValue: _selectedSkinTemp,
//                       onChanged: (value) {
//                         setModalState(() {
//                           _selectedSkinTemp = value;
//                         });
//                       },
//                       contentPadding: EdgeInsets.zero,
//                     );
//                   }).toList(),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _skinTempController.text = _selectedSkinTemp ?? '';
//                       });
//                       Navigator.pop(context);
//                     },
//                     child: const Text("Done"),
//                   )
//                 ],
//               );
//             },
//           ),
//         ),
//       );
//     },
//   );
// }

// void _showSkinMoistureModal(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (context) {
//       return SafeArea(
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 16,
//             right: 16,
//             top: 16,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//           ),
//           child: StatefulBuilder(
//             builder: (context, setModalState) {
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("Select Skin Moisture", style: TextStyle(fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 12),
//                   ..._skinMoistureOptions.map((option) {
//                     return RadioListTile<String>(
//                       title: Text(option),
//                       value: option,
//                       groupValue: _selectedSkinMoisture,
//                       onChanged: (value) {
//                         setModalState(() {
//                           _selectedSkinMoisture = value;
//                         });
//                       },
//                       contentPadding: EdgeInsets.zero,
//                     );
//                   }).toList(),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _skinMoistureController.text = _selectedSkinMoisture ?? '';
//                       });
//                       Navigator.pop(context);
//                     },
//                     child: const Text("Done"),
//                   )
//                 ],
//               );
//             },
//           ),
//         ),
//       );
//     },
//   );
// }

// void _showSkinColorModal(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (context) {
//       return SafeArea(
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 16,
//             right: 16,
//             top: 16,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//           ),
//           child: StatefulBuilder(
//             builder: (context, setModalState) {
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("Select Skin Color", style: TextStyle(fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 12),
//                   ..._skinColorOptions.map((option) {
//                     return RadioListTile<String>(
//                       title: Text(option),
//                       value: option,
//                       groupValue: _selectedSkinColor,
//                       onChanged: (value) {
//                         setModalState(() {
//                           _selectedSkinColor = value;
//                         });
//                       },
//                       contentPadding: EdgeInsets.zero,
//                     );
//                   }).toList(),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _skinColorController.text = _selectedSkinColor ?? '';
//                       });
//                       Navigator.pop(context);
//                     },
//                     child: const Text("Done"),
//                   )
//                 ],
//               );
//             },
//           ),
//         ),
//       );
//     },
//   );
// }

// void _showCapillaryRefillModal(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (context) {
//       return SafeArea(
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 16,
//             right: 16,
//             top: 16,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//           ),
//           child: StatefulBuilder(
//             builder: (context, setModalState) {
//               String? selectedOption = _skinCapillaryRefController.text.isNotEmpty
//                   ? _skinCapillaryRefController.text
//                   : null;

//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("Select Capillary Refill", style: TextStyle(fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 12),
//                   RadioListTile<String>(
//                     title: const Text("Normal"),
//                     value: "Normal",
//                     groupValue: selectedOption,
//                     onChanged: (value) {
//                       setModalState(() => selectedOption = value);
//                     },
//                   ),
//                   RadioListTile<String>(
//                     title: const Text("Delayed"),
//                     value: "Delayed",
//                     groupValue: selectedOption,
//                     onChanged: (value) {
//                       setModalState(() => selectedOption = value);
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _skinCapillaryRefController.text = selectedOption ?? '';
//                       });
//                       Navigator.pop(context);
//                     },
//                     child: const Text("Done"),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       );
//     },
//   );
// }

// void _showPainAssessmentModal(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (_) {
//       String? tempRadiate = _radiateController.text;

//       return StatefulBuilder(
//         builder: (context, setModalState) {
//           return SafeArea(
//             child: Padding(
//               padding: EdgeInsets.only(
//                 left: 16,
//                 right: 16,
//                 top: 16,
//                 bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text("Pain Assessment", style: TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 16),

//                     TextFormField(
//                       controller: _painProvokeController,
//                       decoration: buildInputDecoration("Pain Provoke Description"),
//                     ),

//                     const SizedBox(height: 12),

//                     GestureDetector(
//                       onTap: () async {
//                         final picked = await showDatePicker(
//                           context: context,
//                           initialDate: _timeOnset ?? DateTime.now(),
//                           firstDate: DateTime(2000),
//                           lastDate: DateTime.now(),
//                         );
//                         if (picked != null) {
//                           setModalState(() => _timeOnset = picked);
//                         }
//                       },
//                       child: AbsorbPointer(
//                         child: TextFormField(
//                           decoration: buildInputDecoration("Time Onset"),
//                           controller: TextEditingController(
//                             text: _timeOnset == null
//                             ? ''
//                             : DateFormat('hh:mm a').format(_timeOnset!),

//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 12),

//                     GestureDetector(
//                       onTap: () {
//                         final options = ["Sharp", "Dull", "Cramp", "Crushing", "Constant"];
//                         showModalBottomSheet(
//                           context: context,
//                           builder: (_) {
//                             return SafeArea(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     const Text("Select Pain Quality"),
//                                     ...options.map((q) => RadioListTile(
//                                           title: Text(q),
//                                           value: q,
//                                           groupValue: _qualityController.text,
//                                           onChanged: (val) {
//                                             setState(() => _qualityController.text = val!);
//                                             Navigator.pop(context);
//                                           },
//                                         ))
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       },
//                       child: AbsorbPointer(
//                         child: TextFormField(
//                           controller: _qualityController,
//                           decoration: buildInputDecoration("Pain Quality"),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 12),

//                     const Text("Severity (1–10)"),
//                     Slider(
//                       value: double.tryParse(_severityController.text) ?? 1,
//                       min: 1,
//                       max: 10,
//                       divisions: 9,
//                       label: _severityController.text.isEmpty
//                           ? "1"
//                           : _severityController.text,
//                       onChanged: (val) {
//                         setModalState(() {
//                           _severityController.text = val.round().toString();
//                         });
//                       },
//                     ),

//                     const SizedBox(height: 12),

//                     const Text("Does the pain radiate?"),
//                     CheckboxListTile(
//                       title: const Text("Yes"),
//                       value: tempRadiate == "Yes",
//                       onChanged: (val) {
//                         setModalState(() => tempRadiate = val == true ? "Yes" : "");
//                       },
//                     ),
//                     CheckboxListTile(
//                       title: const Text("No"),
//                       value: tempRadiate == "No",
//                       onChanged: (val) {
//                         setModalState(() => tempRadiate = val == true ? "No" : "");
//                       },
//                     ),

//                     const Divider(height: 32),

//                     CheckboxListTile(
//                       title: const Text("N/A (Not Applicable)"),
//                       value: tempRadiate == "N/A",
//                       onChanged: (val) {
//                         if (val == true) {
//                           setModalState(() {
//                             tempRadiate = "N/A";
//                             _painProvokeController.clear();
//                             _qualityController.clear();
//                             _severityController.clear();
//                             _timeOnset = null;
//                           });
//                         } else {
//                           setModalState(() => tempRadiate = "");
//                         }
//                       },
//                     ),

//                     const SizedBox(height: 16),
//                     Center(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           setState(() {
//                             _radiateController.text = tempRadiate ?? '';
//                           });
//                           Navigator.pop(context);
//                         },
//                         child: const Text("Done"),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     },
//   );
// }

// void _showQualityModal(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (context) {
//       String? selectedQuality = _qualityController.text.isNotEmpty ? _qualityController.text : null;

//       return SafeArea(
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 16,
//             right: 16,
//             top: 16,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//           ),
//           child: StatefulBuilder(
//             builder: (context, setModalState) {
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("Select Quality", style: TextStyle(fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 12),
//                   RadioListTile<String>(
//                     title: const Text("Regular"),
//                     value: "Regular",
//                     groupValue: selectedQuality,
//                     onChanged: (val) {
//                       setModalState(() => selectedQuality = val);
//                     },
//                   ),
//                   RadioListTile<String>(
//                     title: const Text("Irregular"),
//                     value: "Irregular",
//                     groupValue: selectedQuality,
//                     onChanged: (val) {
//                       setModalState(() => selectedQuality = val);
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _qualityController.text = selectedQuality ?? '';
//                       });
//                       Navigator.pop(context);
//                     },
//                     child: const Text("Done"),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       );
//     },
//   );
// }


// Widget buildAmbulanceAndVitalsForm() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       const Text("Response", style: TextStyle(fontWeight: FontWeight.bold)),
//       const Divider(height: 32),
//       const SizedBox(height: 12),
//       DropdownButtonFormField<String>(
//         value: _isToScene.isEmpty ? null : _isToScene,
//         isExpanded: true,
//         items: [
//           "Non-emergent, NO Lights or Siren",
//           "Emergent, Lights and Siren",
//           "Initial Emergent, Downgrade to no lights or siren",
//           "Initial Non-emergent, Upgrade to lights or siren"
//         ].map((val) => DropdownMenuItem(
//           value: val,
//           child: Text(val, overflow: TextOverflow.ellipsis),
//         )).toList(),
//         onChanged: (value) => setState(() => _isToScene = value!),
//         decoration: buildInputDecoration("Lights and Siren to Scene"),
//       ),

//       const SizedBox(height: 12),
//       DropdownButtonFormField<String>(
//         value: _locationType.isEmpty ? null : _locationType,
//         items: [
//           "Airport", "Clinical/Medical", "Educational Institutions", "Farm", "Highway/Street", "Home/Residence",
//           "Industrial", "Lying-In", "Mine/Quarry", "Public Building", "Public outdoor", "Recreational/Sport",
//           "Resort/Hotel", "Restaurant/Bar", "Waterway", "Unspecified", "Other", "N/A"
//         ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//         onChanged: (value) => setState(() => _locationType = value!),
//         decoration: buildInputDecoration("Location Type"),
//       ),
//       const SizedBox(height: 12),
//       DropdownButtonFormField<String>(
//         value: _responseType.isEmpty ? null : _responseType,
//         items: [
//           "Mutual Aid", "Intercept", "Response to the scene", "Scheduled Interfacility Transfer",
//           "Standby", "Unscheduled Interfacility Transfer", "Other", "Unknown"
//         ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//         onChanged: (value) => setState(() => _responseType = value!),
//         decoration: buildInputDecoration("Response Type"),
//       ),
      
//       const SizedBox(height: 12),
//       const Text("History", style: TextStyle(fontWeight: FontWeight.bold)),
//       const Divider(height: 32),
//       const SizedBox(height: 12),
//       GestureDetector(
//           onTap: () => _showSymptomsModal(context),
//           child: AbsorbPointer(
//             child: TextFormField(
//               decoration: buildInputDecoration("Select Signs & Symptoms"),
//               controller: TextEditingController(
//                 text: _selectedSymptoms.join(', ') +
//                       (_selectedSymptoms.contains('Other') && _otherSymptomController.text.isNotEmpty
//                         ? ' (${_otherSymptomController.text})'
//                         : ''),
//               ),
//             ),
//           ),
//         ),
//       const SizedBox(height: 12),
//       TextFormField(controller: _allergiesController, decoration: buildInputDecoration("Allergies")),
//       const SizedBox(height: 12),
//       TextFormField(controller: _currentMediController, decoration: buildInputDecoration("Current Medication")),
//       const SizedBox(height: 12),
//      GestureDetector(
//             onTap: () => _showpreMedicalConditionModal(context),
//             child: AbsorbPointer(
//               child: TextFormField(
//                 decoration: buildInputDecoration("Select Pre-Existing Condition - Medical"),
//                 controller: TextEditingController(
//                   text: [
//                     ..._selectedMedicalCondition,
//                     if (_selectedCardiacConditions.isNotEmpty) "Cardiac(${_selectedCardiacConditions.join(', ')})",
//                     if (_selectedOtherConditions.isNotEmpty)
//                       "Others(${_selectedOtherConditions.join(', ')}${_selectedOtherConditions.contains("Other") && _customOtherConditionController.text.isNotEmpty
//                             ? ": ${_customOtherConditionController.text}"
//                             : ""})",
//                   ].where((item) => item.isNotEmpty).join(', ')
//                 ),
//               ),
//             ),
//           ),
//       const SizedBox(height: 12),const Text("Assessment", style: TextStyle( fontWeight: FontWeight.bold, fontSize: 20,),),

//       const Divider(height: 32),

//       const SizedBox(height: 12),
//             GestureDetector(
//         onTap: () => _showMentalStateModal(context),
//         child: AbsorbPointer(
//           child: TextFormField(
//             controller: _mentalStatController,
//             decoration: buildInputDecoration("Mental Status / Behavior"),
//           ),
//         ),
//       ),

//       const SizedBox(height: 12),
//       GestureDetector(
//         onTap: () => _showEyesStateModal(context),
//         child: AbsorbPointer(
//           child: TextFormField(
//             controller: _eyesStatController,
//             decoration: buildInputDecoration("Eyes State"),
//           ),
//         ),
//       ),

//       const SizedBox(height: 12),
//       GestureDetector(
//         onTap: () => _showBreathSoundModal(context),
//         child: AbsorbPointer(
//           child: TextFormField(
//             controller: _breathSoundController,
//             decoration: buildInputDecoration("Breath Sound"),
//           ),
//         ),
//       ),
//       const SizedBox(height: 12),
//       const Text("Skin", style: TextStyle(fontWeight: FontWeight.bold)),
//       const Divider(height: 32),
//       const SizedBox(height: 12),
//       GestureDetector(
//         onTap: () => _showSkinTempModal(context),
//         child: AbsorbPointer(
//           child: TextFormField(
//             controller: _skinTempController,
//             decoration: buildInputDecoration("Skin Temperature"),
//           ),
//         ),
//       ),

//       const SizedBox(height: 12),
//       GestureDetector(
//         onTap: () => _showSkinMoistureModal(context),
//         child: AbsorbPointer(
//           child: TextFormField(
//             controller: _skinMoistureController,
//             decoration: buildInputDecoration("Skin Moisture"),
//           ),
//         ),
//       ),
//       const SizedBox(height: 12),
//       GestureDetector(
//         onTap: () => _showSkinColorModal(context),
//         child: AbsorbPointer(
//           child: TextFormField(
//             controller: _skinColorController,
//             decoration: buildInputDecoration("Skin Color"),
//           ),
//         ),
//       ),

//       const SizedBox(height: 12),
//       GestureDetector(
//           onTap: () => _showCapillaryRefillModal(context),
//           child: AbsorbPointer(
//             child: TextFormField(
//               controller: _skinCapillaryRefController,
//               decoration: buildInputDecoration("Capillary Refill"),
//             ),
//           ),
//         ),

//       const SizedBox(height: 12),
//      const Text("Pain Assessment", style: TextStyle(fontWeight: FontWeight.bold)),
//       const Divider(height: 32),
//       const SizedBox(height: 12),
//      GestureDetector(
//         onTap: () => _showPainAssessmentModal(context),
//         child: AbsorbPointer(
//           child: TextFormField(
//             controller: TextEditingController(
//               text: _radiateController.text == "N/A"
//                   ? "N/A"
//                   : [
//                       if (_painProvokeController.text.isNotEmpty) "Provoke: ${_painProvokeController.text}",
//                       if (_timeOnset != null) "Onset: ${DateFormat('yyyy-MM-dd').format(_timeOnset!)}",
//                       if (_qualityController.text.isNotEmpty) "Quality: ${_qualityController.text}",
//                       if (_severityController.text.isNotEmpty) "Severity: ${_severityController.text}/10",
//                       if (_radiateController.text.isNotEmpty) "Radiate: ${_radiateController.text}",
//                     ].join(" | "),
//             ),
//             decoration: buildInputDecoration("Pain Assessment"),
//           ),
//         ),
//       ),

//       const Divider(height: 32),
//       const Text("Vitals", style: TextStyle(fontWeight: FontWeight.bold)),
//       const SizedBox(height: 12),

//       ListView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: _vitalsEntries.length,
//         itemBuilder: (context, index) {
//           final entry = _vitalsEntries[index];
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text("Vitals Entry ${index + 1}", style: const TextStyle(fontWeight: FontWeight.w600)),
//                   const Spacer(),
//                   if (_vitalsEntries.length > 1)
//                     IconButton(
//                       onPressed: () {
//                         setState(() => _vitalsEntries.removeAt(index));
//                       },
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               TextFormField(controller: entry['BP'], decoration: buildInputDecoration("Blood Pressure")),
//               const SizedBox(height: 8),
//               TextFormField(controller: entry['PR'], decoration: buildInputDecoration("Pulse Rate")),
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: () => _showQualityModal(context),
//                 child: AbsorbPointer(
//                   child: TextFormField(
//                     controller: _vitalsqualityController,
//                     decoration: buildInputDecoration("Quality"),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 8),
//               TextFormField(controller: entry['RR'], decoration: buildInputDecoration("Repiratory Rate / RR")),
//               const SizedBox(height: 8),
//               TextFormField(controller: entry['SpO2'], decoration: buildInputDecoration("Oxygen Saturation / SPO2")),
//               const SizedBox(height: 8),
//               TextFormField(controller: entry['GCS'], decoration: buildInputDecoration("GCS")),
//               const SizedBox(height: 8),
//               TextFormField(controller: entry['Temp'], decoration: buildInputDecoration("Temperature")),
//               const Divider(height: 32),
//             ],
//           );
//         },
//       ),

//       ElevatedButton.icon(
//         onPressed: () {
//           setState(() {
//             _addVitalsEntry();
//           });
//         },
//         icon: const Icon(Icons.add),
//         label: const Text("Add New Vitals Entry"),
//       ),

//     ],
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: _cachedTicketData == null
//             ? StreamBuilder<Map<String, dynamic>?>(
//                 stream: listenToTicketDataForResponder(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting && _cachedTicketData == null) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   if (snapshot.hasData) {
//                     _cachedTicketData = snapshot.data;
//                   }

//                   final data = _cachedTicketData;
//                   final isFormTab = _tabIndex == 0;

//                   return Column(
//                     children: [
//                       TopTabSwitcher(
//                         activeTab: isFormTab ? 'form' : 'history',
//                         onTabChanged: (tab) {
//                           setState(() {
//                             _tabIndex = tab == 'form' ? 0 : 1;
//                           });
//                         },
//                       ),
//                       const SizedBox(height: 12),
//                       Expanded(
//                         child: isFormTab && data != null
//                             ? _buildFormContent(data)
//                             : HistoryFormContent(
//                                 activeTab: 'history',
//                                 onTabChanged: (tab) {
//                                   setState(() => _tabIndex = tab == 'form' ? 0 : 1);
//                                 },
//                               ),
//                       ),
//                     ],
//                   );
//                 },
//               )
//             : Column(
//                 children: [
//                   TopTabSwitcher(
//                     activeTab: _tabIndex == 0 ? 'form' : 'history',
//                     onTabChanged: (tab) {
//                       setState(() => _tabIndex = tab == 'form' ? 0 : 1);
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   Expanded(
//                     child: _tabIndex == 0 && _cachedTicketData != null
//                         ? _buildFormContent(_cachedTicketData!)
//                         : HistoryFormContent(
//                             activeTab: 'history',
//                             onTabChanged: (tab) {
//                               setState(() => _tabIndex = tab == 'form' ? 0 : 1);
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
