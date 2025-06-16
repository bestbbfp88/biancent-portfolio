import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'contact_page.dart';
import 'log_in_register.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _checkConnectivity(BuildContext context) async {
    try {
      // Simulate loading the logo (for example, you could show a delay here if needed)
      await Future.delayed(const Duration(seconds: 2)); // Simulating logo load delay
      
      final connectivityResult = await Connectivity().checkConnectivity(); // Check connectivity

      if (connectivityResult.contains(ConnectivityResult.none)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ContactPage()),
        );
      } else {
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    } catch (e) {
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ContactPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkConnectivity(context); // Trigger the connectivity check after logo load

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the logo
            Image.asset(
              'assets/images/bers_logo.png', // Ensure this path is correct and the asset is added in pubspec.yaml
              width: MediaQuery.of(context).size.width * 0.9, // Make logo size responsive
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            // Loading indicator
            const CircularProgressIndicator(
              color: Colors.blue, // Match the app's primary theme color
            ),
          ],
        ),
      ),
    );
  }
}
