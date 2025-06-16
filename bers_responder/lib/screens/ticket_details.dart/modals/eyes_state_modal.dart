import 'package:flutter/material.dart';

Future<void> showEyesStateModal({
  required BuildContext context,
  required Map<String, String> selectedEyeStates,
  required TextEditingController controller,
  Future<void> Function()? onDone, // ✅ Add this callback
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Select Eyes State", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    ...["PERRL", "Reactive", "Nonreactive", "Constricted", "Blind", "Glaucoma"].map((option) {
                      final isSelected = selectedEyeStates.containsKey(option);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            title: Text(option),
                            value: isSelected,
                            onChanged: (selected) {
                              setModalState(() {
                                if (selected == true) {
                                  selectedEyeStates[option] = option == "PERRL" ? "" : "Right";
                                } else {
                                  selectedEyeStates.remove(option);
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (isSelected && option != "PERRL")
                            Padding(
                              padding: const EdgeInsets.only(left: 32.0),
                              child: Wrap(
                                spacing: 10,
                                children: ["Right", "Left", "Both"].map((side) {
                                  return ChoiceChip(
                                    label: Text(side),
                                    selected: selectedEyeStates[option] == side,
                                    onSelected: (_) {
                                      setModalState(() {
                                        selectedEyeStates[option] = side;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final eyesDescription = selectedEyeStates.entries.map((entry) {
                          return entry.value.isNotEmpty ? "${entry.key} (${entry.value})" : entry.key;
                        }).join(', ');

                        controller.text = eyesDescription;

                        if (onDone != null) {
                          await onDone(); // ✅ Save after update
                        }

                        Navigator.pop(context);
                      },
                      child: const Text("Done"),
                    ),
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
