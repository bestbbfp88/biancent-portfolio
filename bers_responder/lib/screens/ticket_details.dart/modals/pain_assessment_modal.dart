import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> showPainAssessmentModal({
  required BuildContext context,
  required TextEditingController painProvokeController,
  required TextEditingController qualityController,
  required TextEditingController severityController,
  required TextEditingController radiateController,
  required TextEditingController timeOnsetDisplayController,
  required DateTime? timeOnset,
  required void Function(DateTime?) onTimeOnsetChanged,
  required InputDecoration Function(String label) buildInputDecoration,
  Future<void> Function()? onDone, // ✅ Added optional onDone callback
}) async {
  String? tempRadiate = radiateController.text;

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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pain Assessment", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: painProvokeController,
                      decoration: buildInputDecoration("Pain Provoke Description"),
                    ),

                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (pickedTime != null) {
                          final now = DateTime.now();
                          final fullDateTime = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );

                          setModalState(() {
                            onTimeOnsetChanged(fullDateTime);
                            timeOnsetDisplayController.text = DateFormat('hh:mm a').format(fullDateTime);
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: buildInputDecoration("Time Onset"),
                          controller: timeOnsetDisplayController,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () {
                        final options = ["Sharp", "Dull", "Cramp", "Crushing", "Constant"];
                        showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text("Select Pain Quality"),
                                    ...options.map((q) => RadioListTile(
                                          title: Text(q),
                                          value: q,
                                          groupValue: qualityController.text,
                                          onChanged: (val) {
                                            qualityController.text = val!;
                                            Navigator.pop(context);
                                          },
                                        ))
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: qualityController,
                          decoration: buildInputDecoration("Pain Quality"),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Text("Severity (1–10)"),
                    Slider(
                      value: double.tryParse(severityController.text) ?? 1,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: severityController.text.isEmpty
                          ? "1"
                          : severityController.text,
                      onChanged: (val) {
                        setModalState(() {
                          severityController.text = val.round().toString();
                        });
                      },
                    ),

                    const SizedBox(height: 12),
                    const Text("Does the pain radiate?"),
                    CheckboxListTile(
                      title: const Text("Yes"),
                      value: tempRadiate == "Yes",
                      onChanged: (val) {
                        setModalState(() => tempRadiate = val == true ? "Yes" : "");
                      },
                    ),
                    CheckboxListTile(
                      title: const Text("No"),
                      value: tempRadiate == "No",
                      onChanged: (val) {
                        setModalState(() => tempRadiate = val == true ? "No" : "");
                      },
                    ),

                    const Divider(height: 32),

                    CheckboxListTile(
                      title: const Text("N/A (Not Applicable)"),
                      value: tempRadiate == "N/A",
                      onChanged: (val) {
                        if (val == true) {
                          setModalState(() {
                            tempRadiate = "N/A";
                            painProvokeController.clear();
                            qualityController.clear();
                            severityController.clear();
                            onTimeOnsetChanged(null);
                            timeOnsetDisplayController.clear();
                          });
                        } else {
                          setModalState(() => tempRadiate = "");
                        }
                      },
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          radiateController.text = tempRadiate ?? '';

                          if (onDone != null) {
                            await onDone(); // ✅ Call save or refresh
                          }

                          Navigator.pop(context);
                        },
                        child: const Text("Done"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
