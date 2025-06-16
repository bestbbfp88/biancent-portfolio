import 'package:bohol_emergency_response_system/landingpage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/call_util.dart';
import '../services/message_util.dart';

class Nointernet extends StatelessWidget {
  const Nointernet({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // Remove the debug banner
      home: ContactListPage(),
    );
  }
}

class ContactListPage extends StatelessWidget {
  final List<Contact> contacts = [
    Contact(name: 'Tarsier 117 Test', phoneNumber: '+639938931602', imageUrl: 'assets/images/tarsier.jpg'),
    Contact(name: 'Tarsier 117', phoneNumber: '+639258300117', imageUrl: 'assets/images/tarsier.jpg'),
    Contact(name: 'Tarsier 117', phoneNumber: '+639497955530', imageUrl: 'assets/images/tarsier.jpg'),
  ];

  ContactListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 231, 231, 231),
        title: Text(
          'Contact List',
          style: TextStyle(
            fontWeight: FontWeight.bold,  // Makes the text bold
          ),
        ),
        toolbarHeight: 80, // Set the height of the AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Back button icon
          onPressed: () {
            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LogInRegister()),
                          );
          },
        ),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Image.asset(
                contact.imageUrl,  // Load from local assets
                width: 50,  // Set width of the image
                height: 50, // Set height of the image
                fit: BoxFit.cover,  // Ensures the image fits the container
              ),
              title: Text(contact.name),
              subtitle: Text(contact.phoneNumber),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.call, color: Colors.green),
                    onPressed: () async {
                      final status = await Permission.phone.status;
                      if (status.isGranted) {
                        await CallUtil.makeCall(contact.phoneNumber);
                      } else if (status.isDenied) {
                        final result = await Permission.phone.request();
                        if (result.isGranted) {
                          await CallUtil.makeCall(contact.phoneNumber);
                        } else {
                          _showPermissionDialog(
                              context, 'Phone permission is required.');
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.message, color: Colors.blue),
                    onPressed: () async {
                      final status = await Permission.sms.status;
                      if (status.isGranted) {
                        // Send a pre-filled SMS with a custom message
                        String preFilledMessage = "Hello, this is a message from Bohol Emergency Response app! Requesting for Emergency Assistance";
                        await MessageUtil.sendMessage(contact.phoneNumber, preFilledMessage);
                      } else if (status.isDenied) {
                        final result = await Permission.sms.request();
                        if (result.isGranted) {
                          String preFilledMessage = "Hello, this is a message from Bohol Emergency Response app! Requesting for Emergency Assistance";
                          await MessageUtil.sendMessage(contact.phoneNumber, preFilledMessage);
                        } else {
                          _showPermissionDialog(
                              context, 'SMS permission is required.');
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPermissionDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Permission Needed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings(); // Redirect to app settings for manual permission.
            },
            child: Text('Open Settings'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog.
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class Contact {
  final String name;
  final String phoneNumber;
  final String imageUrl; // Image URL or asset path

  Contact({required this.name, required this.phoneNumber, required this.imageUrl});
}
