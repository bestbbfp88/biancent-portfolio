import 'package:flutter/material.dart';

Future<void> showSkinTempModal({
  required BuildContext context,
  required List<String> skinTempOptions,
  required TextEditingController controller,
  Future<void> Function()? onDone, // ✅ Optional callback
}) async {
  String? selectedValue = controller.text.isNotEmpty ? controller.text : null;

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
                  const Text("Select Skin Temperature", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...skinTempOptions.map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: selectedValue,
                      onChanged: (value) {
                        setModalState(() {
                          selectedValue = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      controller.text = selectedValue ?? '';

                      if (onDone != null) {
                        await onDone(); // ✅ Run save logic if provided
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
