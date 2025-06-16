import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final DatabaseReference _callsRef = FirebaseDatabase.instance.ref("calls");

  List<Map<String, dynamic>> _userCalls = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCallHistory();
  }

  Future<void> _fetchCallHistory() async {
    try {
      final snapshot = await _callsRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map;
        final List<Map<String, dynamic>> filteredCalls = [];

        data.forEach((key, value) {
            final call = Map<String, dynamic>.from(value);
            final String callerId = call['callerId'] ?? '';
            final Map<dynamic, dynamic>? receivers = call['receivers'];

            final isCaller = callerId == user!.uid;
            final isReceiver = receivers != null && receivers.containsKey(user!.uid);

            if (isCaller || isReceiver) {
              filteredCalls.add({
                'callId': key,
                'status': call['status'] ?? 'unknown',
                'timestamp': call['timestamp'] ?? null,
                'callerId': callerId,
                'isCaller': isCaller,
                'userStatus': isReceiver ? (receivers?[user!.uid] ?? 'receiver') : 'caller',
              });
            }
          });


        filteredCalls.sort((a, b) {
          final aTime = a['timestamp'] ?? 0;
          final bTime = b['timestamp'] ?? 0;
          return (bTime as int).compareTo(aTime as int); // newest first
        });

        setState(() {
          _userCalls = filteredCalls;
          _loading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching call history: $e");
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is int) {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final formatter = DateFormat('MMM d, yyyy • hh:mm a');
      return formatter.format(date);
    }
    return 'Unknown time';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Call History")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _userCalls.isEmpty
              ? const Center(child: Text("No call history found."))
              : ListView.builder(
                  itemCount: _userCalls.length,
                  itemBuilder: (context, index) {
                    final call = _userCalls[index];
                    final bool isCaller = call['isCaller'];
                    final String role = isCaller ? "You (Caller)" : "You (Receiver)";
                    final String status = call['status'];
                    final String userStatus = call['userStatus'];

                    return ListTile(
                      leading: Icon(
                        status == "missed"
                            ? Icons.call_missed
                            : status == "declined"
                                ? Icons.call_end
                                : Icons.call,
                        color: status == "missed"
                            ? Colors.red
                            : status == "declined"
                                ? Colors.orange
                                : Colors.green,
                      ),
                      title: Text("Call ID: ${call['callId']}"),
                      subtitle: Text(
                        "$role • Status: $status (${userStatus.toString()})\n${_formatTimestamp(call['timestamp'])}",
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
    );
  }
}
