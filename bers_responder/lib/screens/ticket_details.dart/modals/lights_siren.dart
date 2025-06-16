import 'package:flutter/material.dart';

Future<void> showIsToSceneModal({
  required BuildContext context,
  required List<String> options,
  required String? selectedOption,
  required Function(String) onSelected,
  Future<void> Function()? onDone, // ✅ Optional async callback
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Lights and Siren to Scene", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...options.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: selectedOption,
                  onChanged: (val) async {
                    onSelected(val!);

                    if (onDone != null) {
                      await onDone(); // ✅ Trigger save or UI refresh
                    }

                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        ),
      );
    },
  );
}
