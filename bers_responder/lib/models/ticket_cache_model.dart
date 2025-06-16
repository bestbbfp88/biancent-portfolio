class TicketFormCache {
  final Map<String, String> textFields;
  final DateTime? timeOnset;
  final List<String> selectedMentalStates;
  final List<String> selectedSymptoms;
  final List<String> selectedBreathSounds;
  final List<String> selectedEyeStates;
  final List<String> selectedMedicalConditions;
  final List<String> selectedCardiacConditions;
  final List<String> selectedOtherConditions;
  final String customOtherCondition;
  final List<Map<String, String>> vitals;

  TicketFormCache({
    required this.textFields,
    required this.timeOnset,
    required this.selectedMentalStates,
    required this.selectedSymptoms,
    required this.selectedBreathSounds,
    required this.selectedEyeStates,
    required this.selectedMedicalConditions,
    required this.selectedCardiacConditions,
    required this.selectedOtherConditions,
    required this.customOtherCondition,
    required this.vitals,
  });

  Map<String, dynamic> toJson() => {
        'textFields': textFields,
        'timeOnset': timeOnset?.toIso8601String(),
        'selectedMentalStates': selectedMentalStates,
        'selectedSymptoms': selectedSymptoms,
        'selectedBreathSounds': selectedBreathSounds,
        'selectedEyeStates': selectedEyeStates,
        'selectedMedicalConditions': selectedMedicalConditions,
        'selectedCardiacConditions': selectedCardiacConditions,
        'selectedOtherConditions': selectedOtherConditions,
        'customOtherCondition': customOtherCondition,
        'vitals': vitals,
      };

  factory TicketFormCache.fromJson(Map<String, dynamic> json) => TicketFormCache(
        textFields: Map<String, String>.from(json['textFields'] ?? {}),
        timeOnset: json['timeOnset'] != null ? DateTime.parse(json['timeOnset']) : null,
        selectedMentalStates: List<String>.from(json['selectedMentalStates'] ?? []),
        selectedSymptoms: List<String>.from(json['selectedSymptoms'] ?? []),
        selectedBreathSounds: List<String>.from(json['selectedBreathSounds'] ?? []),
        selectedEyeStates: List<String>.from(json['selectedEyeStates'] ?? []),
        selectedMedicalConditions: List<String>.from(json['selectedMedicalConditions'] ?? []),
        selectedCardiacConditions: List<String>.from(json['selectedCardiacConditions'] ?? []),
        selectedOtherConditions: List<String>.from(json['selectedOtherConditions'] ?? []),
        customOtherCondition: json['customOtherCondition'] ?? "",
        vitals: List<Map<String, String>>.from(json['vitals'] ?? []),
      );
}
