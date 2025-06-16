import 'package:flutter/material.dart';

Future<void> showLocationTypeCheckboxModal({
  required BuildContext context,
  required List<String> locationOptions,
  required Set<String> selectedLocations,
  required TextEditingController controller,
  Future<void> Function()? onDone, // ✅ Optional callback
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Location Types", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Two-column grid view
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 4,
                    children: locationOptions.map((option) {
                      return CheckboxListTile(
                        title: Text(option, style: const TextStyle(fontSize: 14)),
                        value: selectedLocations.contains(option),
                        onChanged: (selected) {
                          setModalState(() {
                            if (selected == true) {
                              selectedLocations.add(option);
                              if (option == "N/A") {
                                selectedLocations.clear();
                                selectedLocations.add("N/A");
                              } else {
                                selectedLocations.remove("N/A");
                              }
                            } else {
                              selectedLocations.remove(option);
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
                      controller.text = selectedLocations.join(', ');

                      if (onDone != null) {
                        await onDone(); // ✅ save or update UI
                      }

                      Navigator.pop(context);
                    },
                    child: const Text("Done"),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
