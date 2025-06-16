import 'package:bers_responder/helpers/form_storage_helper.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/breath_sound_modal.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/capillary_refill_modal.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/eyes_state_modal.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/lights_siren.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/location_type.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/mental_state_modal.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/pain_assessment_modal.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/pre_medical_modal.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/quality_modal.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/response_type.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/skin_color_modal.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/skin_moisture_modal.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/skin_temp_modal.dart';
import 'package:bers_responder/screens/ticket_details.dart/modals/symptoms_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TicketAmbulanceForm extends StatefulWidget {
  final TextEditingController pcrAlarmController;
  final TextEditingController signsSympController;
  final TextEditingController allergiesController;
  final TextEditingController currentMediController;
  final TextEditingController preMedController;
  final TextEditingController mentalStatController;
  final TextEditingController eyesStatController;
  final TextEditingController breathSoundController;
  final TextEditingController skinTempController;
  final TextEditingController skinColorController;
  final TextEditingController skinCapillaryRefController;
  final TextEditingController painProvokeController;
  final TextEditingController qualityController;
  final TextEditingController vitalsqualityController;
  final TextEditingController radiateController;
  final TextEditingController severityController;
  final TextEditingController lsToSceneController;
  final TextEditingController locationTypeController;
  final TextEditingController responseTypeController;
  
  final List<String> symptomOptions = [
    "Abdominal Pain", "Back Pain", "Bleeding", "Bloody Stool", "Breathing Difficulty",
    "Cardiac Arrest", "Chest Pain", "Choking", "Diarrhea", "Dizziness", "Ear Pain",
    "Eye Pain", "Fever/ Hyperthermia", "Headache", "Hypertension", "Hypothermia",
    "Nausea", "Numbness", "Paralysis", "Palpitation", "Pregnancy/Childbirth",
    "Respiratory Arrest", "Seizures/Convulsions", "Syncope", "Trauma", "Unresp./Unconscious",
    "Vaginal Bleeding", "Vomiting", "Weakness", "Unknown", "Other", "None"
  ];

  final List<String> medicalConditionOptions = [
    "Abdominal Pain", "Back Pain", "Bleeding", "Bloody Stool", "Breathing Difficulty",
    "CVA/TIA", "Diabetes", "Gastrointestinal", "Headache", "Hepatitis", "Hypotension",
    "Seizures/Convulsions", "Tuberculosis", "Cardiac", "Others"
  ];

  final List<String> cardiacConditions = [
    "Angina", "Arrhythmia", "Congenital", "Congestive Heart Failure",
    "Hypertension", "Myocardial Infarction", "Cardiac Surgery", "Seizures/Convulsions", "Palpitation"
  ];

  final List<String> otherConditions = [
    "Development Delay/MR", "Psychiatric", "Substance Abuse", "Tracheostomy", "Other", "None"
  ];

  final List<String> mentalStateOptions = [
    "Normal", "Confused", "Unconscious", "Combative", "N/A"
  ];

  final List<String> eyeStateOptions = [
    "PERRL",
    "Reactive",
    "Nonreactive",
    "Constricted",
    "Blind",
    "Glaucoma",
  ];

  final List<String> breathSoundGeneral = ["N/A", "Stridor"];
  final List<String> breathSoundPerLung = [
    "Clear", "Wet", "Decreased", "Wheezing", "Absent"
  ];
  final List<String> skinTempOptions = ["Normal", "Cool/Cold", "Warm/Hot"];

  final List<String> skinMoistureOptions = ["Normal", "Dry", "Moist", "Diaph"];
  final List<String> skinColorOptions = ["Normal", "Cyanotic", "Pale", "Flushed", "Jaundice"];

  final List<String> responseOptions = [
  "Mutual Aid",
  "Intercept",
  "Response to the scene",
  "Scheduled Interfacility Transfer",
  "Standby",
  "Unscheduled Interfacility Transfer",
  "Other",
  "Unknown"
];

final List<String> isToSceneOptions = [
  "Non-emergent, NO Lights or Siren",
  "Emergent, Lights and Siren",
  "Initial Emergent, Downgrade to no lights or siren",
  "Initial Non-emergent, Upgrade to lights or siren"
];

final List<String> locationTypeOptions = [
  "Airport",
  "Clinical/Medical",
  "Educational Institutions",
  "Farm",
  "Highway/Street",
  "Home/Residence",
  "Industrial",
  "Lying-In",
  "Mine/Quarry",
  "Public Building",
  "Public outdoor",
  "Recreational/Sport",
  "Resort/Hotel",
  "Restaurant/Bar",
  "Waterway",
  "Unspecified",
  "Other",
  "N/A"
];



  
  final TextEditingController skinMoistureController;
  final DateTime? timeOnset;

  final void Function(DateTime?) onTimeOnsetChanged;
  final TextEditingController timeOnsetDisplayController;
  final List<String> selectedMentalStates;

  final Set<String> selectedMedicalConditions;
  final Set<String> selectedCardiacConditions;
  final Set<String> selectedOtherConditions;
  final TextEditingController customOtherConditionController;

  final List<String> selectedBreathSounds;
  final List<String> selectedEyeStates;


  final List<Map<String, TextEditingController>> vitalsEntries;
  final VoidCallback onAddVitals;
  final Function(BuildContext) showSymptomsModal;
  final Function(BuildContext) showPreMedicalModal;
  final Function(BuildContext) showMentalModal;
  final Function(BuildContext) showEyesModal;
  final Function(BuildContext) showBreathModal;
  final Function(BuildContext) showSkinTempModal;
  final Function(BuildContext) showSkinMoistureModal;
  final Function(BuildContext) showSkinColorModal;
  final Function(BuildContext) showQualityModal;
  final InputDecoration Function(String) buildInputDecoration;
  final List<String> selectedSymptoms;
  final TextEditingController otherSymptomController;
  final Set<String> selectedLocationTypes = {};


  TicketAmbulanceForm({super.key,
    required this.pcrAlarmController,
    required this.signsSympController,
    required this.allergiesController,
    required this.currentMediController,
    required this.preMedController,
    required this.mentalStatController,
    required this.eyesStatController,
    required this.breathSoundController,
    required this.skinTempController,
    required this.skinColorController,
    required this.skinCapillaryRefController,
    required this.painProvokeController,
    required this.qualityController,
    required this.vitalsqualityController,
    required this.radiateController,
    required this.severityController,
    required this.skinMoistureController,
    required this.timeOnset,
    required this.lsToSceneController,
    required this.locationTypeController,
    required this.responseTypeController,
    required this.onTimeOnsetChanged,
    required this.timeOnsetDisplayController,
    required this.selectedMentalStates,
    required this.selectedMedicalConditions,
    required this.selectedCardiacConditions,
    required this.selectedOtherConditions,
    required this.customOtherConditionController,
    required this.vitalsEntries,
    required this.onAddVitals,
    required this.showSymptomsModal,
    required this.showPreMedicalModal,
    required this.showMentalModal,
    required this.showEyesModal,
    required this.showBreathModal,
    required this.showSkinTempModal,
    required this.showSkinMoistureModal,
    required this.showSkinColorModal,
    required this.showQualityModal,
    required this.buildInputDecoration,
    required this.selectedSymptoms,
    required this.otherSymptomController,
    required this.selectedBreathSounds,
    required this.selectedEyeStates,

  });

  @override
  State<TicketAmbulanceForm> createState() => _TicketAmbulanceFormState();
}

class _TicketAmbulanceFormState extends State<TicketAmbulanceForm> {
 
  late List<Map<String, TextEditingController>> _vitalsEntries;
  String? selectedSkinColor;
  String? selectedSkinMoisture;
  String? selectedSkinTemp;
  Map<String, String> selectedBreathSounds = {}; // condition: side or blan
  Map<String, String> selectedEyeStates = {}; // condition: eye side
  List<String> selectedMentalStates = [];
  List<String> mentalStateOptions = [];
  List<String> symptomOptions = [];
  List<String> selectedMedicalCondition = [];
  List<String> selectedSymptoms = [];
  List<String> selectedCardiacConditions = [];
  List<String> selectedOtherConditions = [];
  String? selectedlsToScene;
  String? selectedlocationType;
  String? selectedresponseType;
    final Set<String> _selectedLocationTypes = {};
  final TextEditingController _locationTypeController = TextEditingController();
  Map<int, Map<String, String?>> vitalsErrors = {};
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  

@override
void initState() {
  super.initState();

  _vitalsEntries = widget.vitalsEntries;

  Future.microtask(() async {
    final restored = await FormStorageHelper.loadAmbulanceForm(
      controllers: {
        'pcrAlarm': widget.pcrAlarmController,
        'signsSymp': widget.signsSympController,
        'allergies': widget.allergiesController,
        'currentMedi': widget.currentMediController,
        'preMed': widget.preMedController,
        'mentalStat': widget.mentalStatController,
        'eyesStat': widget.eyesStatController,
        'breathSound': widget.breathSoundController,
        'skinTemp': widget.skinTempController,
        'skinColor': widget.skinColorController,
        'skinCapillaryRef': widget.skinCapillaryRefController,
        'painProvoke': widget.painProvokeController,
        'quality': widget.qualityController,
        'vitalsQuality': widget.vitalsqualityController,
        'radiate': widget.radiateController,
        'severity': widget.severityController,
        'skinMoisture': widget.skinMoistureController,
      },
      selectedSymptoms: widget.selectedSymptoms,
      selectedMentalStates: selectedMentalStates,
      selectedEyeStates: selectedEyeStates,
      selectedBreathSounds: selectedBreathSounds,
      selectedMedicalConditions: widget.selectedMedicalConditions,
      selectedCardiacConditions: widget.selectedCardiacConditions,
      selectedOtherConditions: widget.selectedOtherConditions,
      customOtherConditionController: widget.customOtherConditionController,
    
      
      onTimeOnsetChanged: widget.onTimeOnsetChanged,
      vitalsEntries: _vitalsEntries,
      onVitalsUpdated: () => setState(() {}),
    );

    setState(() {
      selectedlsToScene = restored['isToScene'];
      selectedlocationType = restored['locationType'];
      selectedresponseType = restored['responseType'];
      widget.lsToSceneController.text = selectedlsToScene ?? '';
      widget.locationTypeController.text = selectedlocationType ?? '';
      widget.responseTypeController.text = selectedresponseType ?? '';

      // 👇 Add this line to update the internal controller as well
      _locationTypeController.text = selectedlocationType ?? '';
    });

  });
}

 @override
void dispose() {
  FormStorageHelper.saveAmbulanceForm(
    controllers: {
      'pcrAlarm': widget.pcrAlarmController,
      'signsSymp': widget.signsSympController,
      'allergies': widget.allergiesController,
      'currentMedi': widget.currentMediController,
      'preMed': widget.preMedController,
      'mentalStat': widget.mentalStatController,
      'eyesStat': widget.eyesStatController,
      'breathSound': widget.breathSoundController,
      'skinTemp': widget.skinTempController,
      'skinColor': widget.skinColorController,
      'skinCapillaryRef': widget.skinCapillaryRefController,
      'painProvoke': widget.painProvokeController,
      'quality': widget.qualityController,
      'vitalsQuality': widget.vitalsqualityController,
      'radiate': widget.radiateController,
      'severity': widget.severityController,
      'skinMoisture': widget.skinMoistureController,
      'isToScene':widget.lsToSceneController,
      'locationType': widget.locationTypeController,
      'responseType': widget.responseTypeController,
    },
    selectedSymptoms: widget.selectedSymptoms,
    selectedMentalStates: selectedMentalStates,
    selectedEyeStates: selectedEyeStates,
    selectedBreathSounds: selectedBreathSounds,
    selectedMedicalConditions: widget.selectedMedicalConditions,
    selectedCardiacConditions: widget.selectedCardiacConditions,
    selectedOtherConditions: widget.selectedOtherConditions,
    customOtherConditionController: widget.customOtherConditionController,
    timeOnset: widget.timeOnset,
    vitalsEntries: _vitalsEntries,
  );
  super.dispose();
}

Future<void> saveFormState() async {
  await FormStorageHelper.saveAmbulanceForm(
    controllers: {
      'pcrAlarm': widget.pcrAlarmController,
      'signsSymp': widget.signsSympController,
      'allergies': widget.allergiesController,
      'currentMedi': widget.currentMediController,
      'preMed': widget.preMedController,
      'mentalStat': widget.mentalStatController,
      'eyesStat': widget.eyesStatController,
      'breathSound': widget.breathSoundController,
      'skinTemp': widget.skinTempController,
      'skinColor': widget.skinColorController,
      'skinCapillaryRef': widget.skinCapillaryRefController,
      'painProvoke': widget.painProvokeController,
      'quality': widget.qualityController,
      'radiate': widget.radiateController,
      'severity': widget.severityController,
      'skinMoisture': widget.skinMoistureController,
      'isToScene': widget.lsToSceneController,
      'locationType': widget.locationTypeController,
      'responseType': widget.responseTypeController,
    },
    selectedSymptoms: widget.selectedSymptoms,
    selectedMentalStates: selectedMentalStates,
    selectedEyeStates: selectedEyeStates,
    selectedBreathSounds: selectedBreathSounds,
    selectedMedicalConditions: widget.selectedMedicalConditions,
    selectedCardiacConditions: widget.selectedCardiacConditions,
    selectedOtherConditions: widget.selectedOtherConditions,
    customOtherConditionController: widget.customOtherConditionController,
    timeOnset: widget.timeOnset,
    vitalsEntries: _vitalsEntries,
  );
}



void _addVitalsEntry() {
  setState(() {
    _vitalsEntries.add({
      'BP': TextEditingController(),
      'PR': TextEditingController(),
      'RR': TextEditingController(),
      'SpO2': TextEditingController(),
      'GCS': TextEditingController(),
      'Temp': TextEditingController(),
      'Quality': TextEditingController(), // NEW
      'Time': TextEditingController(),    // NEW
    });
  });
}

void scrollToVitalsIndex(int index) {
  final offset = index * 500.0; // Approximate vertical offset
  _scrollController.animateTo(
    offset,
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeInOut,
  );
}


  @override
Widget build(BuildContext context) {
  return Form(
    key: _formKey,
    child: SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            const Text("Response", style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            const SizedBox(height: 12),

            GestureDetector(
                onTap: () {
                  showIsToSceneModal(
                    context: context,
                    options: widget.isToSceneOptions, // ✅ Use constant
                    selectedOption: selectedlsToScene,
                    onSelected: (val) {
                      setState(() {
                        selectedlsToScene = val;
                      });
                    },
                    onDone: () async {
                      widget.lsToSceneController.text = selectedlsToScene ?? ''; // 🟢 Update the controller
                      await saveFormState();
                    }
                  );
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(text: selectedlsToScene),
                    decoration: widget.buildInputDecoration("Lights and Siren to Scene"),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => showLocationTypeCheckboxModal(
                  context: context,
                  locationOptions: widget.locationTypeOptions, // ✅ Use constant
                  selectedLocations: _selectedLocationTypes,
                  controller: _locationTypeController,
                  onDone: () async {
                    setState(() {
                      selectedlocationType = _selectedLocationTypes.join(', ');
                      widget.locationTypeController.text = selectedlocationType ?? '';
                      _locationTypeController.text = selectedlocationType ?? '';
                    });
                    await saveFormState();
                  },

                ),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _locationTypeController,
                    decoration: widget.buildInputDecoration("Location Type"),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => showResponseTypeModal(
                  context: context,
                  responseOptions: widget.responseOptions, // ✅ Use constant
                  selectedResponseType: selectedresponseType,
                  onSelected: (value) {
                    setState(() {
                      selectedresponseType = value;
                    });
                  },
                  onDone: () async {
                    widget.responseTypeController.text = selectedresponseType ?? '';
                    await saveFormState();
                  }

                ),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(text: selectedresponseType),
                    decoration: widget.buildInputDecoration("Response Type"),
                  ),
                ),
              ),


            
            const SizedBox(height: 12),
            const Text("History", style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            const SizedBox(height: 12),

            GestureDetector(
                onTap: () => showSymptomsModal(
                  context: context,
                  symptomOptions: widget.symptomOptions,
                  selectedSymptoms: widget.selectedSymptoms,
                  otherSymptomController: widget.otherSymptomController,
                  buildInputDecoration: widget.buildInputDecoration,
                  onDone: () async {
                    setState(() {});
                    await saveFormState(); // ✅ Save form data after modal closes
                  },
                ),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: widget.selectedSymptoms.join(', ') +
                          (widget.selectedSymptoms.contains('Other') &&
                                  widget.otherSymptomController.text.isNotEmpty
                              ? ' (${widget.otherSymptomController.text})'
                              : ''),
                    ),
                    decoration: widget.buildInputDecoration("Select Signs & Symptoms"),
                  ),
                ),
              ),



            const SizedBox(height: 12),
            TextFormField(
              controller: widget.allergiesController,
              decoration: widget.buildInputDecoration("Allergies"),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.currentMediController,
              decoration: widget.buildInputDecoration("Current Medication"),
            ),

            const SizedBox(height: 12),

          GestureDetector(
              onTap: () => showPreMedicalConditionModal(
                context: context,
                selectedMedicalConditions: widget.selectedMedicalConditions,
                selectedCardiacConditions: widget.selectedCardiacConditions,
                selectedOtherConditions: widget.selectedOtherConditions,
                customOtherConditionController: widget.customOtherConditionController,
                buildInputDecoration: widget.buildInputDecoration,
                medicalConditionOptions: widget.medicalConditionOptions,
                cardiacConditions: widget.cardiacConditions,
                otherConditions: widget.otherConditions,
                onDone: () async {
                  setState(() {});
                  await saveFormState(); // ✅ Save it after closing the modal
                },
              ),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(
                    text: [
                      ...widget.selectedMedicalConditions,
                      if (widget.selectedCardiacConditions.isNotEmpty)
                        "Cardiac(${widget.selectedCardiacConditions.join(', ')})",
                      if (widget.selectedOtherConditions.isNotEmpty)
                        "Others(${widget.selectedOtherConditions.join(', ')}"
                        "${widget.selectedOtherConditions.contains("Other") &&
                                widget.customOtherConditionController.text.isNotEmpty
                            ? ": ${widget.customOtherConditionController.text}"
                            : ""})",
                    ].where((item) => item.isNotEmpty).join(', '),
                  ),
                  decoration: widget.buildInputDecoration("Pre-Existing Condition - Medical"),
                ),
              ),
            ),




            const SizedBox(height: 12),const Text("Assessment", style: TextStyle( fontWeight: FontWeight.bold, fontSize: 20,),),

            const Divider(height: 32),

            const SizedBox(height: 12),
            
            GestureDetector(
                onTap: () async {
                  await showMentalStateModal(
                    context: context,
                    selectedMentalStates: selectedMentalStates,
                    mentalStateOptions: widget.mentalStateOptions,
                    controller: widget.mentalStatController,
                    onDone: () async {
                      setState(() {});
                      await saveFormState(); // ✅ save to shared preferences
                    },
                  );
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: widget.mentalStatController,
                    decoration: widget.buildInputDecoration("Mental Status / Behavior"),
                  ),
                ),
              ),




            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => showEyesStateModal(
                context: context,
                selectedEyeStates: selectedEyeStates,
                controller: widget.eyesStatController,
                onDone: () async {
                  setState(() {});
                  await saveFormState(); // ✅ persist data
                },
              ),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: widget.eyesStatController,
                  decoration: widget.buildInputDecoration("Eyes State"),
                ),
              ),
            ),

            const SizedBox(height: 12),
            GestureDetector(
                onTap: () => showBreathSoundModal(
                  context: context,
                  selectedBreathSounds: selectedBreathSounds,
                  controller: widget.breathSoundController,
                  onDone: () async {
                    setState(() {});       // Refresh the UI if needed
                    await saveFormState(); // Save to SharedPreferences
                  },
                ),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: widget.breathSoundController,
                    decoration: widget.buildInputDecoration("Breath Sound"),
                  ),
                ),
              ),

            const SizedBox(height: 12),
            const Text("Skin", style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            const SizedBox(height: 12),

           GestureDetector(
                onTap: () => showSkinTempModal(
                  context: context,
                  skinTempOptions: widget.skinTempOptions,
                  controller: widget.skinTempController,
                  onDone: () async {
                    setState(() {});
                    await saveFormState(); // ✅ Save to shared preferences or DB
                  },
                ),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: widget.skinTempController,
                    decoration: widget.buildInputDecoration("Skin Temperature"),
                  ),
                ),
              ),



            const SizedBox(height: 12),
           GestureDetector(
              onTap: () => showSkinMoistureModal(
                context: context,
                skinMoistureOptions: widget.skinMoistureOptions,
                controller: widget.skinMoistureController,
                onDone: () async {
                  setState(() {});
                  await saveFormState(); // ✅ Save selected skin moisture
                },
              ),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: widget.skinMoistureController,
                  decoration: widget.buildInputDecoration("Skin Moisture"),
                ),
              ),
            ),


            const SizedBox(height: 12),
            GestureDetector(
                onTap: () => showSkinColorModal(
                  context: context,
                  skinColorOptions: widget.skinColorOptions,
                  controller: widget.skinColorController,
                  onDone: () async {
                    setState(() {});
                    await saveFormState(); // ✅ Save form to shared preferences
                  },
                ),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: widget.skinColorController,
                    decoration: widget.buildInputDecoration("Skin Color"),
                  ),
                ),
              ),


            const SizedBox(height: 12),
           GestureDetector(
              onTap: () => showCapillaryRefillModal(
                context: context,
                controller: widget.skinCapillaryRefController,
                onDone: () async {
                  setState(() {});
                  await saveFormState(); // ✅ persist the selection
                },
              ),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: widget.skinCapillaryRefController,
                  decoration: widget.buildInputDecoration("Capillary Refill"),
                ),
              ),
            ),


            const SizedBox(height: 12),
            const Text("Pain Assessment", style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            const SizedBox(height: 12),

            GestureDetector(
                onTap: () => showPainAssessmentModal(
                  context: context,
                  painProvokeController: widget.painProvokeController,
                  qualityController: widget.qualityController,
                  severityController: widget.severityController,
                  radiateController: widget.radiateController,
                  timeOnsetDisplayController: widget.timeOnsetDisplayController,
                  timeOnset: widget.timeOnset,
                  onTimeOnsetChanged: widget.onTimeOnsetChanged,
                  buildInputDecoration: widget.buildInputDecoration,
                  onDone: () async {
                    setState(() {});
                    await saveFormState(); // ✅ Save to SharedPreferences
                  },
                ),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: widget.radiateController.text == "N/A"
                          ? "N/A"
                          : [
                              if (widget.painProvokeController.text.isNotEmpty)
                                "Provoke: ${widget.painProvokeController.text}",
                              if (widget.timeOnset != null)
                                "Onset: ${DateFormat('yyyy-MM-dd').format(widget.timeOnset!)}",
                              if (widget.qualityController.text.isNotEmpty)
                                "Quality: ${widget.qualityController.text}",
                              if (widget.severityController.text.isNotEmpty)
                                "Severity: ${widget.severityController.text}/10",
                              if (widget.radiateController.text.isNotEmpty)
                                "Radiate: ${widget.radiateController.text}",
                            ].join(" | "),
                    ),
                    decoration: widget.buildInputDecoration("Pain Assessment"),
                  ),
                ),
              ),


            const Divider(height: 32),
            const Text("Vitals", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

      Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _vitalsEntries.length,
      itemBuilder: (context, index) {
        final entry = _vitalsEntries[index];
        final errors = vitalsErrors[index] ?? {};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Vitals Entry ${index + 1}", style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                if (_vitalsEntries.length > 1)
                  IconButton(
                    onPressed: () {
                      setState(() => _vitalsEntries.removeAt(index));
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: entry['BP'],
              decoration: widget.buildInputDecoration("Blood Pressure (mmHg)").copyWith(
                errorText: errors['BP'],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: entry['PR'],
              decoration: widget.buildInputDecoration("Pulse Rate (bpm)").copyWith(
                errorText: errors['PR'],
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => showQualityModal(
                context: context,
                controller: entry['Quality']!,
                onDone: () async {
                  setState(() {});
                  await saveFormState();
                },
              ),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: entry['Quality'],
                  decoration: widget.buildInputDecoration("Pulse Quality"),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: entry['RR'],
              decoration: widget.buildInputDecoration("Respiratory Rate (breaths/min)").copyWith(
                errorText: errors['RR'],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: entry['SpO2'],
              decoration: widget.buildInputDecoration("Oxygen Saturation (SpO₂ %)").copyWith(
                errorText: errors['SpO2'],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: entry['GCS'],
              decoration: widget.buildInputDecoration("Glasgow Coma Scale (GCS)").copyWith(
                errorText: errors['GCS'],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: entry['Temp'],
              decoration: widget.buildInputDecoration("Temperature (°C)").copyWith(
                errorText: errors['Temp'],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: entry['Time'],
              readOnly: true,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  final formatted = picked.format(context);
                  entry['Time']?.text = formatted;
                  await saveFormState();
                }
              },
              decoration: widget.buildInputDecoration("Time of Vitals").copyWith(
                errorText: errors['Time'],
              ),
            ),
            const Divider(height: 32),
          ],
        );
      },
    ),

    /// 🟨 Add Vitals Entry Button
    Center(
      child: ElevatedButton.icon(
        onPressed: () {
          _addVitalsEntry();
          saveFormState();
          scrollToVitalsIndex(_vitalsEntries.length - 1);
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Vitals Entry"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    ),
  ],
)

        ],
      ),
    ),
  );
}

}
