import 'package:flutter/material.dart';

Future<void> showCapillaryRefillModal({
  required BuildContext context,
  required TextEditingController controller,
  Future<void> Function()? onDone, // ✅ optional async callback
}) async {
  String? selectedOption = controller.text.isNotEmpty ? controller.text : null;

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
                  const Text("Select Capillary Refill", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  RadioListTile<String>(
                    title: const Text("Normal"),
                    value: "Normal",
                    groupValue: selectedOption,
                    onChanged: (value) => setModalState(() => selectedOption = value),
                  ),
                  RadioListTile<String>(
                    title: const Text("Delayed"),
                    value: "Delayed",
                    groupValue: selectedOption,
                    onChanged: (value) => setModalState(() => selectedOption = value),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      controller.text = selectedOption ?? '';

                      if (onDone != null) {
                        await onDone(); // ✅ trigger save
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
