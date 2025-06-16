import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class EditMedicalProfile extends StatefulWidget {
  final Map<String, String> medicalData;

  const EditMedicalProfile({super.key, required this.medicalData});

  @override
  _EditMedicalProfileState createState() => _EditMedicalProfileState();
}

class _EditMedicalProfileState extends State<EditMedicalProfile> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TextEditingController chronicConditionController;
  late TextEditingController weightController;
  late TextEditingController heightController;
  late TextEditingController allergiesController;
  late TextEditingController currentMedicationsController;

  String selectedBloodType = "Unknown";
  String selectedDisabilityStatus = "None";

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    chronicConditionController = TextEditingController(text: widget.medicalData["chronic_conditions"]);
    weightController = TextEditingController(text: widget.medicalData["weight"]);
    heightController = TextEditingController(text: widget.medicalData["height"]);
    allergiesController = TextEditingController(text: widget.medicalData["allergies"]);
    currentMedicationsController = TextEditingController(text: widget.medicalData["current_medications"]);

    // ✅ Use value from database if available, otherwise default
    selectedBloodType = widget.medicalData["blood_type"]?.isNotEmpty == true ? widget.medicalData["blood_type"]! : "Unknown";
    selectedDisabilityStatus = widget.medicalData["disability_status"]?.isNotEmpty == true ? widget.medicalData["disability_status"]! : "None";
  }

  @override
  void dispose() {
    chronicConditionController.dispose();
    weightController.dispose();
    heightController.dispose();
    allergiesController.dispose();
    currentMedicationsController.dispose();
    super.dispose();
  }

  /// 🔹 Save changes to Firebase
Future<void> _saveMedicalProfile() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => isSaving = true);

  try {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Generate a new medical record ID
    String newMedicalId = _dbRef.child("medical").push().key!;

    // Save medical profile under "medical/{medical_ID}"
    await _dbRef.child("medical/$newMedicalId").set({
      "chronic_conditions": chronicConditionController.text.trim(),
      "weight": weightController.text.trim(),
      "height": heightController.text.trim(),
      "blood_type": selectedBloodType,
      "allergies": allergiesController.text.trim(),
      "current_medications": currentMedicationsController.text.trim(),
      "disability_status": selectedDisabilityStatus,
    });

    // Update "users/{user.uid}" to store medical_ID
    await _dbRef.child("users/${user.uid}").update({
      "medical_ID": newMedicalId,
    });

    if (context.mounted) {
      Navigator.pop(context, true); // ✅ Closes dialog & refreshes profile
    }
  } catch (e) {
    print("❌ Error saving medical profile: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to save medical profile. Please try again.")),
    );
  } finally {
    setState(() => isSaving = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView( // ✅ Makes the dialog scrollable
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Close Button (X)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => Navigator.pop(context), // Close the popup
                ),
              ),

              const Text("Edit Medical Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField("Chronic Condition", chronicConditionController),
                    _buildTextField("Weight (kg)", weightController),
                    _buildTextField("Height (cm)", heightController),

                    // 🔹 Blood Type Dropdown (Preselected)
                    _buildDropdownField(
                      "Blood Type",
                      selectedBloodType,
                      [
                        "Unknown", "A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"
                      ],
                      (value) => setState(() => selectedBloodType = value),
                    ),

                    _buildTextField("Allergies", allergiesController),
                    _buildTextField("Current Medications", currentMedicationsController),

                    // 🔹 Disability Status Dropdown (Preselected)
                    _buildDropdownField(
                      "Disability Status",
                      selectedDisabilityStatus,
                      [
                        "None", "Visual Impairment", "Hearing Impairment",
                        "Mobility Impairment", "Cognitive Impairment", "Other"
                      ],
                      (value) => setState(() => selectedDisabilityStatus = value),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: isSaving ? null : _saveMedicalProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Save"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Text Field Builder
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value == null || value.isEmpty ? "Enter $label" : null,
      ),
    );
  }

  /// 🔹 Dropdown Field Builder (Preselected values)
  Widget _buildDropdownField(String label, String selectedValue, List<String> options, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: options.contains(selectedValue) ? selectedValue : options.first, // ✅ Ensure valid selection
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: options.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}