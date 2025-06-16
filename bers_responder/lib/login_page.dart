import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'main_screen.dart';

class LoginPage extends StatefulWidget {
  final String? errorMessage; // Accept error message from outside (e.g., AuthWrapper)

  const LoginPage({super.key, this.errorMessage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _errorMessage = widget.errorMessage; // Set from widget constructor
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

      final email = emailController.text.trim();
        final password = passwordController.text.trim();

        if (email.isEmpty || password.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter both email and password.';
            _isLoading = false;
          });
          return;
        }

    try {
      // Step 1: Sign in the user
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Step 2: Check user role
      String uid = userCredential.user!.uid;
      final ref = FirebaseDatabase.instance.ref("users/$uid");
      final snapshot = await ref.once();
      final data = snapshot.snapshot.value as Map?;

      if (data == null || data['user_role'] != 'Emergency Responder') {
        // ❌ Invalid role — sign out and show error
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          setState(() {
            _errorMessage = 'Access denied: Not an Emergency Responder.';
          });
        }
      }else{
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
      }

      // ✅ If role is valid, do nothing — AuthWrapper will take care of routing

    } on FirebaseAuthException catch (e) {
  setState(() {
    if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
      _errorMessage = 'Incorrect password. Please try again.';
    } else if (e.code == 'user-not-found') {
      _errorMessage = 'No account found for this email.';
    } else if (e.code == 'invalid-email') {
      _errorMessage = 'The email address is not valid.';
    } else {
      _errorMessage = e.message ?? 'Authentication failed.';
    }
  });
}catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred.';
      });
    }

    setState(() => _isLoading = false);
  }

Future<void> _resetPassword() async {
  final email = emailController.text.trim();
  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter your email to reset password.")),
    );
    return;
  }

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password reset link sent to your email.")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.toString()}")),
    );
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const Center(
              child: Icon(Icons.location_on_sharp, size: 100, color: Colors.redAccent),
            ),
            const Center(
              child: Text("RESPONDER",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            ),
            const SizedBox(height: 40),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email Address")),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resetPassword,
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(color: Color.fromARGB(255, 18, 7, 74)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isLoading ? const CircularProgressIndicator() : const Text("LOGIN"),
            ),
            const SizedBox(height: 50), // Extra bottom padding for keyboard
          ],
        ),
      ),
    ),
  );
}

}
