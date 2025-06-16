import 'package:flutter/material.dart';
import 'services/location_service.dart'; // Import the LocationService class
import 'services/location_display.dart';
import 'after_sos.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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
      
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          locationAddress = address;
        });
      }
    } catch (error) {
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          locationAddress = 'Failed to get address: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 231, 231, 231), // Apply gray background
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to AfterSOS screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AfterSOS()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.7), // Glow color (red)
                      blurRadius: 50, // Blur radius of the glow
                      spreadRadius: 10, // Spread radius of the glow
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(100), // Border radius for InkWell ripple
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AfterSOS()),
                    );
                  },
                  child: Image.asset(
                    'assets/images/sos_button.png', // Path to your image file
                    width: 200, // Adjust the width as needed
                    height: 200, // Adjust the height as needed
                    fit: BoxFit.contain, // Adjust how the image is displayed
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Are you in emergency?',
              style: TextStyle(
                fontWeight: FontWeight.bold, // Makes the text bold
                fontSize: 20, // Increases the font size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
