import 'package:flutter/material.dart';
import 'services/location_service.dart'; // Import the LocationService class
import 'services/location_display.dart';

class AfterSOS extends StatefulWidget {
  const AfterSOS({super.key});

  @override
  AfterSOSState createState() => AfterSOSState();
}

class AfterSOSState extends State<AfterSOS> {
  String selectedUser = "";
  final LocationService _locationService = LocationService();
  String locationAddress = 'Fetching address...'; // Default text while fetching

  @override
  void initState() {
    super.initState();
    _fetchAddress(); // Fetch the address on initialization
  }

  // Fetch the address using LocationService
  Future<void> _fetchAddress() async {
    try {
      String address = await _locationService.getAddress();
      if (mounted) {
        // Only update state if the widget is still mounted
        setState(() {
          locationAddress = address;
        });
      }
    } catch (error) {
      if (mounted) {
        // Only update state if the widget is still mounted
        setState(() {
          locationAddress = 'Failed to get address: $error';
        });
      }
    }
  }

  @override
  void dispose() {
    // Clean up resources if necessary
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 231, 231, 231), // Apply gray background
        automaticallyImplyLeading: false, // Remove the default back button
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {}, // Placeholder tap action for the "Current Location" text
              child: const Padding(
                padding: EdgeInsets.only(top: 11.0), // Add padding below "Current Location" text
                child: Text(
                  '          Current Location', // Text above the location
                  style: TextStyle(
                    fontSize: 15, // Smaller font size for the text
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to the LocationDisplay screen when tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LocationDisplay()),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center, // Align children vertically
                children: [
                  const Icon(Icons.location_on, size: 40, color: Colors.red), // Larger location icon
                  const SizedBox(width: 8), // Space between icon and location
                  Expanded(
                    child: Text(
                      locationAddress.isEmpty ? 'Fetching address...' : locationAddress,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      overflow: TextOverflow.ellipsis, // Handle long addresses gracefully
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Custom AppBar height
        toolbarHeight: 80, // Set the height of the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
          children: [
            // Center the Question Text at the top
            Center(
              child: Text(
                'Who are you Calling for?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 40),

            // Choices - Patient User or Concerned User in a Column
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedUser = "Patient User";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: selectedUser == "Patient User" ? Colors.orange : Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                  ),
                  child: Text("Patient User"),
                ),
                SizedBox(height: 20), // Space between buttons
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedUser = "Concerned User";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: selectedUser == "Concerned User" ? Colors.orange : Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 68),
                  ),
                  child: Text("Concerned User"),
                ),
              ],
            ),
            Spacer(), // Push content up to make space for the Cancel button at the bottom

            // Cancel Button at the bottom center
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Navigate back to the previous screen
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.grey,
                ),
                child: Text('Cancel'),
              ),
            ),
            SizedBox(height: 20), // Optional: Add space at the bottom
          ],
        ),
      ),
    );
  }
}
