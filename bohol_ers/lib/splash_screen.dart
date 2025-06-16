// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:bohol_emergency_response_system/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

@RoutePage()

class SplashScreen extends StatelessWidget {
  static var page;

  const SplashScreen({super.key});

  Future<void> _checkConnectivityAndLoginStatus(BuildContext context) async {
    try {
      // Simulate loading the logo (for example, you could show a delay here if needed)
      await Future.delayed(const Duration(seconds: 2)); // Simulating logo load delay

      final connectivityResult = await Connectivity().checkConnectivity(); // Check connectivity
      print('Connection: $connectivityResult');

      if (connectivityResult.contains(ConnectivityResult.none)) {
        context.router.replace(const ContactRoute());
      } else {
        // Listen for Firebase Auth state changes
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user == null) {
            context.router.replace(const LoginRoute());
          } else {
            context.router.replace(const HomeRoute());
          }
        });
      }
    } catch (e) {
      // In case of an error, navigate to the contact page
       context.router.replace(const ContactRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkConnectivityAndLoginStatus(context); // Trigger the connectivity check and login status check after logo load

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
