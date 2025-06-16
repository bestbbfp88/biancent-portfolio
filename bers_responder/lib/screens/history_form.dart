import 'package:bers_responder/screens/history_details_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/top_tab_switcher.dart';
import 'package:intl/intl.dart';


class HistoryFormContent extends StatefulWidget {
  final String activeTab;
  final void Function(String)? onTabChanged;

  const HistoryFormContent({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  State<HistoryFormContent> createState() => _HistoryFormContentState();
}

class _HistoryFormContentState extends State<HistoryFormContent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> combinedData = [];


  List<Map<String, dynamic>> historyData = [];
  bool isLoading = true;
  bool _isMounted = true;


  @override
  void initState() {
    super.initState();
    fetchHistoryData();
  }

  @override
void dispose() {
  _isMounted = false;
  super.dispose();
}

Future<void> fetchHistoryData() async {
  final user = _auth.currentUser;
  if (user == null) return;

  final emergenciesSnapshot = await _database.child('emergencies').once();
  final emergenciesMap = emergenciesSnapshot.snapshot.value as Map<dynamic, dynamic>?;

  if (emergenciesMap == null) {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    return;
  }

  List<Map<String, dynamic>> tempCombinedData = [];

  for (var entry in emergenciesMap.entries) {
    final emergencyData = Map<String, dynamic>.from(entry.value);

    final responderRaw = emergencyData['responder_ID'] ?? "";
    final responderList = responderRaw.toString().split(',').map((id) => id.trim()).toList();

    if (responderList.contains(user.uid) && emergencyData['report_Status'] == "Done") {
      final dispatchID = emergencyData['dispatch_ID'];

      if (dispatchID != null) {
        final ticketSnapshot = await _database.child('tickets/$dispatchID').once();
        final ticketData = ticketSnapshot.snapshot.value;

        tempCombinedData.add({
          'emergency': emergencyData,
          'ticket': ticketData != null
              ? Map<String, dynamic>.from(ticketData as Map)
              : {},
        });
      }
    }
  }

  // ✅ Now sort by date_time (descending)
  final format = DateFormat("MMMM d, yyyy 'at' hh:mm a");
  tempCombinedData.sort((a, b) {
    final aDateStr = a['ticket']['date_time'] ?? '';
    final bDateStr = b['ticket']['date_time'] ?? '';
    try {
      final aDate = format.parse(aDateStr);
      final bDate = format.parse(bDateStr);
      return bDate.compareTo(aDate);
    } catch (_) {
      return 0;
    }
  });

  if (mounted) {
    setState(() {
      historyData = tempCombinedData;
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : historyData.isEmpty
                  ? const Center(child: Text('No history found.'))
                  : ListView.builder(
                      itemCount: historyData.length,
                      itemBuilder: (context, index) {
                        final data = historyData[index];
                        final emergency = data['emergency'] as Map<String, dynamic>;
                        final ticket = data['ticket'] as Map<String, dynamic>;

                        return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HistoryDetailsPage(
                                      emergency: data['emergency'],
                                      ticket: data['ticket'],
                                      dispatchId: data['emergency']['dispatch_ID'],
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Location: ${data['emergency']['location'] ?? 'N/A'}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                    Text('Type: ${data['ticket']['date_time'] ?? 'N/A'}',
                                        style: const TextStyle(fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text('Type: ${data['ticket']['emergencyType'] ?? 'N/A'}',
                                        style: const TextStyle(fontSize: 13)),
                                    Text('Status: ${data['emergency']['report_Status'] ?? 'N/A'}',
                                        style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                    
                                  ],
                                ),
                              ),
                            ),
                          );



                      },
                    ),
        ),
      ],
    );
  }
}
