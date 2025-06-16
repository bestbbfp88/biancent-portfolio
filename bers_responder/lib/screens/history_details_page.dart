import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HistoryDetailsPage extends StatefulWidget {
  final Map<String, dynamic> emergency;
  final Map<String, dynamic> ticket;
  final String dispatchId;

  const HistoryDetailsPage({
    super.key,
    required this.emergency,
    required this.ticket,
    required this.dispatchId,
  });

  @override
  State<HistoryDetailsPage> createState() => _HistoryDetailsPageState();
}

class _HistoryDetailsPageState extends State<HistoryDetailsPage> {
  Map<String, dynamic>? ambulanceData;
  List<Map<String, dynamic>> vitalsList = [];
  bool isLoading = true;
  Map<String, dynamic>? patientInfo;

  @override
  void initState() {
    super.initState();
    fetchAmbulanceAndVitals();
  }

  Future<void> fetchAmbulanceAndVitals() async {
    
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final ref = FirebaseDatabase.instance.ref();
  final responderSnap = await ref.child("tickets/${widget.dispatchId}/responder_data/${user.uid}").get();
  final responderData = responderSnap.value as Map?;

   final inforSnap = await ref.child("tickets/${widget.dispatchId}/responder_data/${user.uid}/dispatch").get();
   final rawInfo = inforSnap.value as Map<dynamic, dynamic>?;
   patientInfo = rawInfo != null ? Map<String, dynamic>.from(rawInfo) : null;


  if (responderData != null && responderData['ambulance_id'] != null) {
    final ambSnap = await ref.child("ambulance/${responderData['ambulance_id']}").get();
    ambulanceData = Map<String, dynamic>.from(ambSnap.value as Map);

    // ✅ Fetch vitals entries from the 'entries' node
    if (ambulanceData != null && ambulanceData!['vitals_id'] != null) {
      final vitalsSnap = await ref
          .child("vitals/${ambulanceData!['vitals_id']}/entries")
          .get();

      final rawVitalsList = vitalsSnap.value;
      if (rawVitalsList is List) {
        vitalsList = rawVitalsList
            .whereType<Map>()
            .map((e) => e.map((k, v) => MapEntry(k.toString(), v.toString())))
            .toList();
      } else if (rawVitalsList is Map) {
        // Fallback: in case Firebase returns a map instead of a list (rare but possible)
        vitalsList = rawVitalsList.values
            .whereType<Map>()
            .map((e) => e.map((k, v) => MapEntry(k.toString(), v.toString())))
            .toList();
      }
    }
  }

  if (mounted) {
    setState(() => isLoading = false);
  }
}


  Widget buildField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }

  Widget buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

void exportToPdf() async {
  final pdf = pw.Document();
  final user = FirebaseAuth.instance.currentUser;
  final now = DateTime.now();
  final dateStr =
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

  // 🧾 Fetch full name
  String generatedBy = "Unknown";
  if (user != null) {
    final userSnap = await FirebaseDatabase.instance.ref("users/${user.uid}").get();
    final userData = userSnap.value as Map?;
    if (userData != null) {
      final fName = userData['f_name']?.toString() ?? '';
      final lName = userData['l_name']?.toString() ?? '';
      generatedBy = "$fName $lName".trim();
    }
  }

  // 📋 Format helper
  pw.Table buildTable(Map<String, String?> data) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(4),
      },
      children: data.entries.map((e) {
        return pw.TableRow(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(e.key, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(e.value ?? 'N/A'),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<pw.Widget> section(String title, Map<String, String?> data) {
    return [
      pw.SizedBox(height: 10),
      pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 4),
      buildTable(data),
    ];
  }

  // Emergency Info
  final emergencyInfo = {
    "Location": widget.emergency['location']?.toString(),
    "Status": widget.emergency['report_Status']?.toString(),
  };

  // Ticket Info
  final ticketInfo = {
    "Emergency Type": widget.ticket['emergencyType']?.toString(),
    "Other Emergency Type": widget.ticket['otherEmergencyType']?.toString(),
    "MVC Type": widget.ticket['mvcType']?.toString(),
    "Patient Name": patientInfo?['patient_name']?.toString(),
    "DOB": patientInfo?['dob']?.toString(),
    "Contact": patientInfo?['phone']?.toString(),
    "Complaint": patientInfo?['complaint_incident']?.toString(),
    "Notes": patientInfo?['notes']?.toString(),
    "Responsiveness": patientInfo?['responsiveness']?.toString(),
    "Bleeding Site": patientInfo?['bleeding_site']?.toString(),
    "Hazard Site": patientInfo?['hazard_site']?.toString(),
  };

  // Ambulance Info
  final ambulanceInfo = <String, String?>{};
  if (ambulanceData != null && ambulanceData!.isNotEmpty) {
    final List<String> preMedicalDetails = [];

    // Add main pre-medical condition text if any
    final preMedical = ambulanceData!['pre_medical_condition']?.toString();
    if (preMedical != null && preMedical.isNotEmpty) {
      preMedicalDetails.add(preMedical);
    }

    // Add Medical Conditions
    final medical = ambulanceData!['selected_medical_conditions'] as List<dynamic>?;
    if (medical != null && medical.isNotEmpty) {
      preMedicalDetails.add("Medical: ${medical.join(', ')}");
    }

    // Add Cardiac Conditions
    final cardiac = ambulanceData!['selected_cardiac_conditions'] as List<dynamic>?;
    if (cardiac != null && cardiac.isNotEmpty) {
      preMedicalDetails.add("Cardiac: ${cardiac.join(', ')}");
    }

    // Add Other Conditions
    final other = ambulanceData!['selected_other_conditions'] as List<dynamic>?;
    final customOther = ambulanceData!['custom_other_condition']?.toString();
    if (other != null && other.isNotEmpty) {
      String otherText = other.join(', ');
      if (other.contains("Other") && customOther != null && customOther.isNotEmpty) {
        otherText += ": $customOther";
      }
      preMedicalDetails.add("Others: $otherText");
    }

    ambulanceInfo.addAll({
      "PCR Alarm": ambulanceData!['pcr_alarm']?.toString(),
      "Allergies": ambulanceData!['allergies']?.toString(),
      "Current Medication": ambulanceData!['current_medication']?.toString(),

      // 🟨 Grouped pre-medical condition
      "Pre-Medical Condition": preMedicalDetails.join(" | "),

      // ✅ Other sections
      "Symptoms": (ambulanceData!['selected_symptoms'] as List<dynamic>?)?.join(', '),
      "Provoke": ambulanceData!['pain_provoke']?.toString(),
      "Quality": ambulanceData!['pain_quality']?.toString(),
      "Severity": ambulanceData!['pain_severity']?.toString(),
      "Radiate": ambulanceData!['pain_radiate']?.toString(),
      "Pain Time Onset": ambulanceData!['pain_onset_time_display']?.toString(),
      "Mental Status": ambulanceData!['mental_status']?.toString(),
      "Eye Status": ambulanceData!['eye_status']?.toString(),
      "Breath Sounds": ambulanceData!['breath_sounds']?.toString(),
      "Skin Temp": ambulanceData!['skin_temp']?.toString(),
      "Skin Color": ambulanceData!['skin_color']?.toString(),
      "Moisture": ambulanceData!['skin_moisture']?.toString(),
      "Capillary Refill": ambulanceData!['capillary_refill']?.toString(),
      "Lights and Siren to Scene": ambulanceData!['is_to_scene']?.toString(),
      "Location Type": ambulanceData!['location_type']?.toString(),
      "Response Type": ambulanceData!['response_type']?.toString(),
    });
  }


  // Vitals Info
  List<pw.Widget> vitalsWidgets = [];
  if (ambulanceData != null && ambulanceData!['vitals_id'] != null) {
    final ref = FirebaseDatabase.instance.ref();
    final vitalsSnap = await ref.child("vitals/${ambulanceData!['vitals_id']}/entries").get();
    final rawVitals = vitalsSnap.value;

    if (rawVitals is List) {
      final vitalsList = rawVitals
          .whereType<Map>()
          .map((entry) => entry.map((k, v) => MapEntry(k.toString(), v?.toString())))
          .toList();

      vitalsWidgets = vitalsList.expand((vital) {
        return section("Vitals", vital);
      }).toList();
    }
  }

  // Generate PDF
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Text("Emergency Assessment Report", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text("Generated by: $generatedBy"),
        pw.Text("Generated on: $dateStr"),
        ...section("Emergency Info", emergencyInfo),
        ...section("Ticket Info", ticketInfo),
        if (ambulanceInfo.isNotEmpty) ...section("Ambulance Info", ambulanceInfo),
        if (vitalsWidgets.isNotEmpty) ...vitalsWidgets,
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}

  @override
  Widget build(BuildContext context) {
    final emergency = widget.emergency;
    final ticket = widget.ticket;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency History Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: exportToPdf,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSection("Emergency Info", [
                    buildField("Location", emergency['location']),
                    buildField("Status", emergency['report_Status']),
                  ]),
                  buildSection("Ticket Info", [
                    buildField("Emergency Type", ticket['emergencyType']),
                    buildField("Other Emergency Type", ticket['otherEmergencyType']),
                    buildField("MVC Type", ticket['mvcType']),
                    buildField("Patient Name", patientInfo?['patient_name']),
                    buildField("DOB", patientInfo?['dob']),
                    buildField("Contact", patientInfo?['phone']),
                    buildField("Complaint", patientInfo?['complaint_incident']),
                    buildField("Notes", patientInfo?['notes']),
                    buildField("Responsiveness", patientInfo?['responsiveness']),
                    buildField("Bleeding Site", patientInfo?['bleeding_site']),
                    buildField("Hazard Site", patientInfo?['hazard_site']),
                  ]),
                  if (ambulanceData != null) ...[
                  buildSection("Ambulance Info", [
                    buildField("PCR Alarm", ambulanceData?['pcr_alarm']),
                    buildField("Allergies", ambulanceData?['allergies']),
                    buildField("Current Medication", ambulanceData?['current_medication']),
                  ]),

                  buildSection("Pre-Medical Condition", [
                    buildField("Medical Conditions", (ambulanceData?['selected_medical_conditions'] as List<dynamic>?)?.join(', ')),
                    buildField("Cardiac Conditions", (ambulanceData?['selected_cardiac_conditions'] as List<dynamic>?)?.join(', ')),
                    buildField("Other Conditions", (ambulanceData?['selected_other_conditions'] as List<dynamic>?)?.join(', ')),
                    buildField("Custom Other", ambulanceData?['custom_other_condition']),
                  ]),

                  buildSection("Symptoms", [
                    buildField("Signs & Symptoms", (ambulanceData?['selected_symptoms'] as List<dynamic>?)?.join(', ')),
                  ]),

                  buildSection("Pain Assessment", [
                    buildField("Provoke", ambulanceData?['pain_provoke']),
                    buildField("Quality", ambulanceData?['pain_quality']),
                    buildField("Severity", ambulanceData?['pain_severity']),
                    buildField("Radiate", ambulanceData?['pain_radiate']),
                    buildField("Pain Time Onset", ambulanceData?['pain_onset_time_display']),
                  ]),

                  buildSection("Mental Status", [
                    buildField("Mental", ambulanceData?['mental_status']),
                    buildField("Eye", ambulanceData?['eye_status']),
                  ]),

                  buildSection("Breathing & Skin", [
                    buildField("Breath Sounds", ambulanceData?['breath_sounds']),
                    buildField("Skin Temp", ambulanceData?['skin_temp']),
                    buildField("Skin Color", ambulanceData?['skin_color']),
                    buildField("Moisture", ambulanceData?['skin_moisture']),
                    buildField("Capillary Refill", ambulanceData?['capillary_refill']),
                  ]),

                  buildSection("Response Info", [
                    buildField("Lights and Siren to Scene", ambulanceData?['is_to_scene']),
                    buildField("Location Type", ambulanceData?['location_type']),
                    buildField("Response Type", ambulanceData?['response_type']),
                  ]),
                ],

                  if (vitalsList.isNotEmpty)
                    buildSection("Vitals", vitalsList.map((v) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildField("BP", v['BP']),
                              buildField("PR", v['PR']),
                              buildField("RR", v['RR']),
                              buildField("SpO2", v['SpO2']),
                              buildField("GCS", v['GCS']),
                              buildField("Temp", v['Temp']),
                            ],
                          ),
                        ),
                      );
                    }).toList()),
                ],
              ),
            ),
    );
  }
}
