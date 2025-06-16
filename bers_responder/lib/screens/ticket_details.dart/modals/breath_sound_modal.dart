import 'package:flutter/material.dart';

Future<void> showBreathSoundModal({
  required BuildContext context,
  required Map<String, String> selectedBreathSounds,
  required TextEditingController controller,
  required Future<void> Function()? onDone, // ✅ added
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
                  children: [
                    const Text("Select Breath Sound", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    // General Breath Sounds
                    ...["N/A", "Stridor"].map((option) {
                      return CheckboxListTile(
                        title: Text(option),
                        value: selectedBreathSounds.containsKey(option),
                        onChanged: (selected) {
                          setModalState(() {
                            if (selected == true) {
                              selectedBreathSounds[option] = "";
                              if (option == "N/A") {
                                selectedBreathSounds.removeWhere((key, _) => key != "N/A");
                              } else {
                                selectedBreathSounds.remove("N/A");
                              }
                            } else {
                              selectedBreathSounds.remove(option);
                            }
                          });
                        },
                      );
                    }),

                    const SizedBox(height: 12),

                    // Per-lung Breath Sounds
                    ...["Clear", "Wet", "Decreased", "Wheezing", "Absent"].map((sound) {
                      final isSelected = selectedBreathSounds.containsKey(sound);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            title: Text(sound),
                            value: isSelected,
                            onChanged: (selected) {
                              setModalState(() {
                                if (selected == true) {
                                  selectedBreathSounds[sound] = "Left";
                                  selectedBreathSounds.remove("N/A");
                                } else {
                                  selectedBreathSounds.remove(sound);
                                }
                              });
                            },
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 32.0),
                              child: Wrap(
                                spacing: 10,
                                children: ["Left", "Right", "Both"].map((side) {
                                  return ChoiceChip(
                                    label: Text(side),
                                    selected: selectedBreathSounds[sound] == side,
                                    onSelected: (_) {
                                      setModalState(() {
                                        selectedBreathSounds[sound] = side;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      );
                    }),

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final summary = selectedBreathSounds.entries.map((e) {
                          return e.value.isNotEmpty ? "${e.key} (${e.value})" : e.key;
                        }).join(', ');
                        controller.text = summary;

                        if (onDone != null) {
                          await onDone(); // ✅ trigger save
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
