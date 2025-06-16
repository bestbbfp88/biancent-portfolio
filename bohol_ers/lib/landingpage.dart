import 'package:auto_route/auto_route.dart';
import 'package:bohol_emergency_response_system/routes/router.dart';
import 'package:flutter/material.dart';
import 'styles/button_styles.dart';
import 'main_navigation/offlinemode.dart';


class LogInRegister extends StatefulWidget {
  static var page;
 // Changed to StatefulWidget for button state management
  const LogInRegister({super.key});

  @override
  State<LogInRegister> createState() => _LogInRegisterState();
}

class _LogInRegisterState extends State<LogInRegister> {
  bool isLogInButtonDisabled = false;
  bool isOfflineModeButtonDisabled = false;

  void _navigateToLogin(BuildContext context) async {
    setState(() => isLogInButtonDisabled = true); // Disable the button
    await context.router.push(LoginRoute()); // ✅ Correct AutoRoute usage
    setState(() => isLogInButtonDisabled = false); // Re-enable the button after navigation
  }

  void _navigateToOfflineMode(BuildContext context) async {
    setState(() => isOfflineModeButtonDisabled = true); // Disable the button
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Nointernet()),
    );
    setState(() => isOfflineModeButtonDisabled = false); // Re-enable the button after navigation
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/bers_logo.png',
                width: MediaQuery.of(context).size.width * 0.9,
              ),
              const SizedBox(height: 20),
              const Text(
                'Bohol Emergency Response System',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7, // 70% of screen width
                child: ElevatedButton(
                  onPressed: isLogInButtonDisabled
                      ? null // Disable the button when locked
                      : () => _navigateToLogin(context),
                  style: elevatedButtonStyleStrong,
                  child: const Text('Log In'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7, // 70% of screen width
                child: ElevatedButton(
                  onPressed: isOfflineModeButtonDisabled
                      ? null // Disable the button when locked
                      : () => _navigateToOfflineMode(context),
                  style: elevatedButtonStyleLight,
                  child: const Text('Offline Mode'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
