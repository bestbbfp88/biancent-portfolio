import 'package:flutter/material.dart';

Future<void> showMentalStateModal({
  required BuildContext context,
  required List<String> selectedMentalStates,
  required List<String> mentalStateOptions,
  required TextEditingController controller,
  Future<void> Function()? onDone, // ✅ Optional callback
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
                    const Text("Select Mental State", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 4,
                      children: mentalStateOptions.map((state) {
                        return CheckboxListTile(
                          title: Text(state, style: const TextStyle(fontSize: 14)),
                          value: selectedMentalStates.contains(state),
                          onChanged: (selected) {
                            setModalState(() {
                              if (selected == true) {
                                selectedMentalStates.add(state);
                              } else {
                                selectedMentalStates.remove(state);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        controller.text = selectedMentalStates.join(', ');

                        if (onDone != null) {
                          await onDone(); // ✅ Save or refresh
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
