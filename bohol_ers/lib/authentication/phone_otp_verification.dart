import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bohol_emergency_response_system/routes/router.dart';

@RoutePage(name: 'OTPVerificationRoute')
class OTPVerification extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OTPVerification({super.key, required this.phoneNumber, required this.verificationId});

  @override
  State<OTPVerification> createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  bool isLoading = false;
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

Future<void> _verifyOTP(BuildContext context) async {
  final otp = otpControllers.map((controller) => controller.text.trim()).join();

  if (otp.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter the complete OTP.')),
    );
    return;
  }

  FocusScope.of(context).unfocus();
  setState(() => isLoading = true);
  debugPrint('🚀 Verifying OTP...');

  try {
    FirebaseAuth.instance.setLanguageCode('en');

    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(
      PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      ),
    );

    if (userCredential.user == null) {
      throw FirebaseAuthException(code: 'null-user', message: 'User ID is null.');
    }

    // ✅ Force UI Navigation Immediately After OTP Verification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint('🔹 Navigating to Home...');
        context.router.replaceAll([const HomeRoute()]);
      }
    });
  } catch (e) {
    debugPrint('❌ Error verifying OTP: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to verify OTP: $e')),
    );
  } finally {
    if (mounted) setState(() => isLoading = false);
    debugPrint('✅ Finished OTP verification.');
  }
}


  /// 🔹 OTP Input Fields (No Overflow Issues)
  Widget _buildOTPInput() {
    return FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(6, (index) {
          return Flexible(
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                controller: otpControllers[index],
                focusNode: focusNodes[index],
                maxLength: 1,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                textInputAction: index < 5 ? TextInputAction.next : TextInputAction.done,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    if (index < 5) {
                      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                    } else {
                      focusNodes[index].unfocus();
                      _verifyOTP(context);
                    }
                  } else {
                    if (index > 0) {
                      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                    }
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 🔹 ✅ **Final UI**
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildOTPInput(),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _verifyOTP(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        strokeWidth: 2,
                      )
                    : const Text('Verify OTP'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
