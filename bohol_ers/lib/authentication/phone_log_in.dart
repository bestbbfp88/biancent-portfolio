import 'package:auto_route/auto_route.dart';
import 'package:bohol_emergency_response_system/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

@RoutePage(name: 'LoginRoute')
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _phoneController = TextEditingController();
  bool isLoading = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  String verificationId = '';

  Future<void> _checkPhoneNumber() async {
    final phoneNumber = _phoneController.text;

    if (phoneNumber.isEmpty || phoneNumber.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number.')),
      );
      return;
    }

    final formattedPhoneNumber = "+$phoneNumber"; // Format for Firebase

    setState(() {
      isLoading = true;
    });

    try {
      // ✅ Check if phone number exists in RTDB
      final DataSnapshot snapshot = await _databaseRef
          .child('users')
          .orderByChild('user_contact')
          .equalTo(formattedPhoneNumber)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!snapshot.exists) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number not found. Please register first.')),
        );
        return;
      }

      // ✅ Proceed with OTP verification if phone number exists
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
          debugPrint('✅ Phone automatically verified: ${_firebaseAuth.currentUser?.uid}');
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Failed to verify phone number: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send OTP: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
          debugPrint('📩 OTP sent to $formattedPhoneNumber');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP sent to $formattedPhoneNumber')),
          );
          context.router.push(
            OTPVerificationRoute(
              phoneNumber: formattedPhoneNumber,
              verificationId: verificationId,
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
    } catch (e) {
      debugPrint('❌ Error checking phone number: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check phone number: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                'assets/images/bers_name.png',
                height: 100,
                width: 500,
              ),
            ),
            const SizedBox(height: 40),

            // Phone number input field
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                if (number.phoneNumber != null) {
                  _phoneController.text =
                      number.phoneNumber!.replaceAll(RegExp(r'\D'), '');
                  setState(() {});
                }
              },
              initialValue: PhoneNumber(isoCode: 'PH'),
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                showFlags: true,
              ),
              inputDecoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 12,
            ),
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                "By tapping 'Next', we'll collect your mobile number to send you an OTP (One-Time Password) for verification.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),

            ElevatedButton(
              onPressed: isLoading || _phoneController.text.length != 12
                  ? null
                  : _checkPhoneNumber,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Next', style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 20),

            // Register Now Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                TextButton(
                  onPressed: () {
                    context.router.push(RegistrationRoute());
                  },
                  child: const Text(
                    "Register now",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
