import 'package:flutter/material.dart';

Future<void> showSymptomsModal({
  required BuildContext context,
  required List<String> symptomOptions,
  required List<String> selectedSymptoms,
  required TextEditingController otherSymptomController,
  required InputDecoration Function(String label) buildInputDecoration,
  Future<void> Function()? onDone, // ✅ Changed from VoidCallback to Future
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Select Symptoms", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 4,
                      children: symptomOptions.map((symptom) {
                        return CheckboxListTile(
                          title: Text(symptom, style: const TextStyle(fontSize: 14)),
                          value: selectedSymptoms.contains(symptom),
                          onChanged: (selected) {
                            setModalState(() {
                              if (selected == true) {
                                selectedSymptoms.add(symptom);
                              } else {
                                selectedSymptoms.remove(symptom);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                    if (selectedSymptoms.contains('Other')) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: otherSymptomController,
                        decoration: buildInputDecoration("Specify Other"),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (onDone != null) {
                          await onDone(); // ✅ Save or update UI
                        }
                        Navigator.pop(context);
                      },
                      child: const Text("Done"),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
