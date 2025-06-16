import 'package:flutter/material.dart';
import 'styles/button_styles.dart';
import 'offlinemode.dart';
import 'registration.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegistrationPage()),
                          );
                        },
                            style: elevatedButtonStyleStrong,
                            child: const Text('Register'),
                      ),
                    ),
                     const SizedBox(height: 20),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7, // 70% of screen width
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Nointernet()),
                          );
                        },
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
