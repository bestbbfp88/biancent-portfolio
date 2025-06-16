import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TicketDispatchForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController dobController;
  final TextEditingController addressController;
  final TextEditingController complaintController;
  final TextEditingController notesController;
  final TextEditingController patientNumberController;
  final TextEditingController responsivenessController;
  final TextEditingController bleedingController;
  final TextEditingController hazardController;
  final TextEditingController emergencyTypeController;
  final TextEditingController otherEmergencyTypeController;
  final TextEditingController mvcTypeController;
  final TextEditingController ambulatoryController;
  final TextEditingController breathingController;
  final TextEditingController firstResponderController;
  final TextEditingController actionsTakenController;
  final TextEditingController preArrivalController;

  final InputDecoration Function(String) buildInputDecoration;

  const TicketDispatchForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.dobController,
    required this.addressController,
    required this.complaintController,
    required this.notesController,
    required this.patientNumberController,
    required this.responsivenessController,
    required this.bleedingController,
    required this.hazardController,
    required this.emergencyTypeController,
    required this.otherEmergencyTypeController,
    required this.mvcTypeController,
    required this.buildInputDecoration,
    required this.ambulatoryController,
    required this.firstResponderController,
    required this.breathingController,
    required this.actionsTakenController,
    required this.preArrivalController
  });

@override
Widget build(BuildContext context) {
  final emergencyTypes = ['Medical', 'Trauma', 'Fire', 'Police', 'MVC', 'Other'];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(controller: nameController, decoration: buildInputDecoration("First name")),
      const SizedBox(height: 12),
      TextFormField(controller: emailController, enabled: false, decoration: buildInputDecoration("Email")),
      const SizedBox(height: 12),
      TextFormField(controller: phoneController, enabled: false, decoration: buildInputDecoration("Phone")),
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

      /// ✅ Emergency Type Dropdown
      DropdownButtonFormField<String>(
        value: emergencyTypes.contains(emergencyTypeController.text) ? emergencyTypeController.text : null,
        items: emergencyTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
        onChanged: (value) {
          emergencyTypeController.text = value!;
        },
        decoration: buildInputDecoration("Emergency Type"),
      ),
      const SizedBox(height: 12),

      /// 🔍 If "Other" selected
      if (emergencyTypeController.text == "Other")
        TextFormField(
          controller: otherEmergencyTypeController,
          decoration: buildInputDecoration("Other Emergency Type"),
        ),

      /// 🔍 If "MVC" selected
      if (emergencyTypeController.text == "MVC")
        TextFormField(
          controller: mvcTypeController,
          decoration: buildInputDecoration("MVC Type (e.g. For Extraction)"),
        ),

      const SizedBox(height: 12),
      TextFormField(controller: complaintController, decoration: buildInputDecoration("Complaint")),
      const SizedBox(height: 12),
      TextFormField(controller: notesController, decoration: buildInputDecoration("Notes")),
      const SizedBox(height: 12),
      TextFormField(controller: patientNumberController, decoration: buildInputDecoration("Number of Patients")),
      const SizedBox(height: 12),
      TextFormField(controller: responsivenessController, decoration: buildInputDecoration("Responsiveness")),
      const SizedBox(height: 12),
      TextFormField(controller: ambulatoryController, decoration: buildInputDecoration("Ambulatory Status")),
      const SizedBox(height: 12),  
      TextFormField(controller: breathingController, decoration: buildInputDecoration("Breathing")),
      const SizedBox(height: 12), 
      TextFormField(controller: bleedingController, decoration: buildInputDecoration("Bleeding Site")),
      const SizedBox(height: 12),
      TextFormField(controller: firstResponderController, decoration: buildInputDecoration("Emergency First Responders on Site")),
      const SizedBox(height: 12),
      TextFormField(controller: preArrivalController, decoration: buildInputDecoration("Pre-Arrival Instruction")),
      const SizedBox(height: 12),
      TextFormField(controller: actionsTakenController, decoration: buildInputDecoration("Actions Taken")),
      const SizedBox(height: 12),
      TextFormField(controller: hazardController, decoration: buildInputDecoration("Hazard on Scene")),
      const SizedBox(height: 16),
    ],
  );
}
}