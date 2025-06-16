import 'package:flutter/material.dart';

Future<void> showResponseTypeModal({
  required BuildContext context,
  required List<String> responseOptions,
  required String? selectedResponseType,
  required ValueChanged<String> onSelected,
  Future<void> Function()? onDone, // ✅ Optional async callback
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      String? tempSelected = selectedResponseType;

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
                  const Text("Select Response Type", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...responseOptions.map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: tempSelected,
                      onChanged: (value) {
                        setModalState(() => tempSelected = value);
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (tempSelected != null) {
                        onSelected(tempSelected!);
                        if (onDone != null) {
                          await onDone(); // ✅ Save or refresh
                        }
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
