import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/call_util.dart';
import '../services/message_util.dart';

@RoutePage()
class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final DatabaseReference _contactsRef = FirebaseDatabase.instance.ref('emergency_contacts');
  late Query _activeContactsQuery;

  @override
  void initState() {
    super.initState();
    // Query Firebase RTDB for active contacts
    _activeContactsQuery = _contactsRef.orderByChild('number_status').equalTo('Active');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔹 Header with Shadow
          Container(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contacts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 🔹 Contact List from Firebase
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _activeContactsQuery.onValue,  // Using Query instead of DatabaseReference
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text('No active contacts found.'));
                }

                final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<Widget> contactWidgets = [];

                // Loop through each contact
                data.forEach((key, value) {
                  final contact = value as Map<dynamic, dynamic>;
                  final name = contact['number_name'] ?? 'No name';
                  final number = contact['number'] ?? 'No number';

                  // Add each contact to the list
                  contactWidgets.add(_buildContactItem(
                    name: name,
                    phoneNumber: number,
                    context: context,
                  ));
                  contactWidgets.add(const SizedBox(height: 20));
                });

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  children: contactWidgets,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Builds Contact List Items
  Widget _buildContactItem({
    required String name,
    required String phoneNumber,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  phoneNumber,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          // 🔹 Call & Message Buttons
          IconButton(
            icon: const Icon(Icons.call, color: Colors.green),
            onPressed: () => _handleCall(context, phoneNumber),
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.blue),
            onPressed: () => _handleMessage(context, phoneNumber),
          ),
        ],
      ),
    );
  }

  /// 🔹 Handles Phone Call with Permission
  Future<void> _handleCall(BuildContext context, String phoneNumber) async {
    final status = await Permission.phone.status;
    if (status.isGranted) {
      await CallUtil.makeCall(phoneNumber);
    } else {
      final result = await Permission.phone.request();
      if (result.isGranted) {
        await CallUtil.makeCall(phoneNumber);
      } else {
        _showPermissionDialog(context, 'Phone permission is required.');
      }
    }
  }

  /// 🔹 Handles Sending SMS with Permission
  Future<void> _handleMessage(BuildContext context, String phoneNumber) async {
    final status = await Permission.sms.status;
    if (status.isGranted) {
      String preFilledMessage = "Hello, this is a message from Bohol Emergency Response app! Requesting for Emergency Assistance";
      await MessageUtil.sendMessage(phoneNumber, preFilledMessage);
    } else {
      final result = await Permission.sms.request();
      if (result.isGranted) {
        String preFilledMessage = "Hello, this is a message from Bohol Emergency Response app! Requesting for Emergency Assistance";
        await MessageUtil.sendMessage(phoneNumber, preFilledMessage);
      } else {
        _showPermissionDialog(context, 'SMS permission is required.');
      }
    }
  }

  /// 🔹 Shows a Permission Dialog when needed
  void _showPermissionDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Needed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
