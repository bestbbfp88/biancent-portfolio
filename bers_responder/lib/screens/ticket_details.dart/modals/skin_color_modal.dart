import 'package:flutter/material.dart';

Future<void> showSkinColorModal({
  required BuildContext context,
  required List<String> skinColorOptions,
  required TextEditingController controller,
  Future<void> Function()? onDone, // ✅ Optional callback
}) async {
  String? selectedSkinColor = controller.text.isNotEmpty ? controller.text : null;

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
                  const Text("Select Skin Color", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...skinColorOptions.map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: selectedSkinColor,
                      onChanged: (value) {
                        setModalState(() {
                          selectedSkinColor = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      controller.text = selectedSkinColor ?? '';

                      if (onDone != null) {
                        await onDone(); // ✅ Trigger save or UI refresh
                      }

                      Navigator.pop(context);
                    },
                    child: const Text("Done"),
                  )
                ],
              );
            },
          ),
        ),
      );
    },
  );
}
