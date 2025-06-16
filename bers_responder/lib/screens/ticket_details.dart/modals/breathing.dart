import 'package:flutter/material.dart';

Future<void> showBreathingModal({
  required BuildContext context,
  required TextEditingController controller,
}) async {
  final options = ['Breathing', 'Difficulty in Breathing', 'Not Breathing'];
  String? selected = controller.text.isNotEmpty ? controller.text : null;

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
                  const Text("Select Breathing Status", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...options.map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: selected,
                      onChanged: (value) {
                        setModalState(() {
                          selected = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      controller.text = selected ?? '';
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
