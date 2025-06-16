import 'package:flutter/material.dart';

Future<void> showPreMedicalConditionModal({
  required BuildContext context,
  required Set<String> selectedMedicalConditions,
  required Set<String> selectedCardiacConditions,
  required Set<String> selectedOtherConditions,
  required TextEditingController customOtherConditionController,
  required InputDecoration Function(String) buildInputDecoration,
  required List<String> medicalConditionOptions,
  required List<String> cardiacConditions,
  required List<String> otherConditions,
  Future<void> Function()? onDone, // ✅ Make this async
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Existing Condition - Medical", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 4,
                      children: medicalConditionOptions.map((condition) {
                        return CheckboxListTile(
                          title: Text(condition, style: const TextStyle(fontSize: 14)),
                          value: selectedMedicalConditions.contains(condition),
                          onChanged: (selected) {
                            setModalState(() {
                              if (selected == true) {
                                selectedMedicalConditions.add(condition);
                              } else {
                                selectedMedicalConditions.remove(condition);
                                if (condition == "Cardiac") selectedCardiacConditions.clear();
                                if (condition == "Others") {
                                  selectedOtherConditions.clear();
                                  customOtherConditionController.clear();
                                }
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    if (selectedMedicalConditions.contains("Cardiac")) ...[
                      const Text("Cardiac Conditions", style: TextStyle(fontWeight: FontWeight.w600)),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 4,
                        children: cardiacConditions.map((cardiac) {
                          return CheckboxListTile(
                            title: Text(cardiac, style: const TextStyle(fontSize: 14)),
                            value: selectedCardiacConditions.contains(cardiac),
                            onChanged: (selected) {
                              setModalState(() {
                                if (selected == true) {
                                  selectedCardiacConditions.add(cardiac);
                                } else {
                                  selectedCardiacConditions.remove(cardiac);
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
                    ],

                    if (selectedMedicalConditions.contains("Others")) ...[
                      const Text("Other Medical Conditions", style: TextStyle(fontWeight: FontWeight.w600)),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 4,
                        children: otherConditions.map((item) {
                          return CheckboxListTile(
                            title: Text(item, style: const TextStyle(fontSize: 14)),
                            value: selectedOtherConditions.contains(item),
                            onChanged: (selected) {
                              setModalState(() {
                                if (selected == true) {
                                  selectedOtherConditions.add(item);
                                } else {
                                  selectedOtherConditions.remove(item);
                                  if (item == "Other") {
                                    customOtherConditionController.clear();
                                  }
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
                      if (selectedOtherConditions.contains("Other"))
                        TextFormField(
                          controller: customOtherConditionController,
                          decoration: buildInputDecoration("Specify Other"),
                        ),
                    ],

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (onDone != null) {
                          await onDone(); // ✅ Support async logic like saveFormState()
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
