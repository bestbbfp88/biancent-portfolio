import 'package:flutter/material.dart';

Future<void> showQualityModal({
  required BuildContext context,
  required TextEditingController controller,
  Future<void> Function()? onDone, // ✅ Optional callback
}) async {
  String? selectedQuality = controller.text.isNotEmpty ? controller.text : null;

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
                  const Text("Select Quality", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  RadioListTile<String>(
                    title: const Text("Regular"),
                    value: "Regular",
                    groupValue: selectedQuality,
                    onChanged: (val) => setModalState(() => selectedQuality = val),
                  ),
                  RadioListTile<String>(
                    title: const Text("Irregular"),
                    value: "Irregular",
                    groupValue: selectedQuality,
                    onChanged: (val) => setModalState(() => selectedQuality = val),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      controller.text = selectedQuality ?? '';

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
