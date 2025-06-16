import 'package:flutter/material.dart';

Future<void> showSkinMoistureModal({
  required BuildContext context,
  required List<String> skinMoistureOptions,
  required TextEditingController controller,
  Future<void> Function()? onDone, // ✅ Optional callback
}) async {
  String? selectedSkinMoisture = controller.text.isNotEmpty ? controller.text : null;

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
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Skin Moisture", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...skinMoistureOptions.map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: selectedSkinMoisture,
                      onChanged: (value) {
                        setModalState(() {
                          selectedSkinMoisture = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      controller.text = selectedSkinMoisture ?? '';

                      if (onDone != null) {
                        await onDone(); // ✅ Trigger save or UI update
                      }

                      Navigator.pop(context);
                    },
                    child: const Text("Done"),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}
