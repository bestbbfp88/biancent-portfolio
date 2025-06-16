import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';

class AuthPage extends StatefulWidget {
  final String fName;
  final String lName;
  final String email;
  final String birthdate;
  final String address;
  final String eContactName;
  final String eContactNumber;
  final String sex;

  const AuthPage({
    super.key,
    required this.fName,
    required this.lName,
    required this.email,
    required this.birthdate,
    required this.address,
    required this.eContactName,
    required this.eContactNumber,
    required this.sex,
  });

  @override
  AuthPageState createState() => AuthPageState();
}


class AuthPageState extends State<AuthPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  String phoneNumber = '';
  String otp = '';
  bool isOTPSent = false;
  bool isLoading = false;

  final PhoneNumber initialPhoneNumber = PhoneNumber(isoCode: 'PH');

  // Initialize Supabase client
  final SupabaseClient _supabaseClient = SupabaseClient(
    'https://znjxgxdolzgewhwwrwsi.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpuanhneGRvbHpnZXdod3dyd3NpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxNTg2MDcsImV4cCI6MjA1MTczNDYwN30.aIF4CSpZRIbjORHmfJN_BO2kDQv_hHgHNfRXKNq6Txc',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Authentication'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            isOTPSent ? _buildOTPInput(context) : _buildPhoneNumberInput(),
            if (isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  // Modify this method to handle phone number validation before sending OTP
  Widget _buildPhoneNumberInput() {
    return Column(
      children: [
        InternationalPhoneNumberInput(
          onInputChanged: (PhoneNumber number) {
            setState(() {
              phoneNumber = number.phoneNumber ?? '';
            });
          },
          initialValue: initialPhoneNumber,
          inputDecoration: InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: const Icon(Icons.phone, color: Colors.black),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.black,
          ),
          onPressed: () async {
            if (phoneNumber.isEmpty || !phoneNumber.startsWith('+')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid phone number.')),
              );
              return;
            }
            setState(() => isLoading = true);

            // Check if the phone number exists in the database before sending OTP
            await checkPhoneNumberAndSendOTP(phoneNumber);

            // If the number is already registered, do not proceed further
            if (!isOTPSent) {
              setState(() {
                isLoading = false;
              });
              return;
            }

            setState(() {
              isLoading = false;
              isOTPSent = true;
            });
          },
          child: const Text('Send OTP'),
        ),
      ],
    );
  }

  // New method to check if the phone number exists and send OTP if it's not registered
  Future<void> checkPhoneNumberAndSendOTP(String phoneNumber) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select('user_contact') // Only select the phone number column
          .eq('user_contact', phoneNumber) // Match the phone number
          .limit(1) // Limit to 1 result, as we only need to check existence
          .maybeSingle(); // Use single to get one result (or null if no match)

      // If the phone number exists, show an error and allow retry
      if (response != null && response['user_contact'] == phoneNumber) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This phone number is already registered.')),
        );

        // Reset the phone number field to allow retry
        _phoneNumberController.clear();
        setState(() {
          phoneNumber = ''; // Reset the state variable
          isOTPSent = false; // Ensure OTP is not sent
        });

        print('Phone number already exists, returning early.');
        return; // Return early to stop further execution
      }else{
      // Proceed to send OTP if the phone number doesn't exist
      await _supabaseClient.auth.signInWithOtp(phone: phoneNumber);
      print('OTP sent successfully to $phoneNumber');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent successfully to $phoneNumber')),
      );

      // Mark OTP sent
      setState(() {
        isOTPSent = true;
      });
    }} catch (e) {
      print('Error sending OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP. Please try again.')),
      );
      // Reset OTP sent flag to allow retry
      setState(() {
        isOTPSent = false;
      });
    }
  }

  Widget _buildOTPInput(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Enter OTP',
            prefixIcon: const Icon(Icons.lock, color: Colors.black),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (value) => otp = value,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.black,
          ),
          onPressed: () async {
            setState(() => isLoading = true);
            final String? uid = await verifyOTP(otp);

            setState(() => isLoading = false);

            if (uid != null) {
              // If additional data was passed from the RegistrationPage, save it to the database
              await saveUserData(uid);
            
              // Navigate to HomeScreen after successful OTP verification
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            } else {
              // Show error dialog for invalid OTP
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Invalid OTP'),
                  content: const Text('The OTP you entered is incorrect.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
          child: const Text('Verify OTP'),
        ),
      ],
    );
  }

  Future<String?> verifyOTP(String otp) async {
    try {
      final response = await _supabaseClient.auth.verifyOTP(
        phone: phoneNumber,
        token: otp,
        type: OtpType.sms,
      );

      print('OTP verified successfully');
      final userId = response.session?.user.id;
      print('User ID: $userId');
      return userId;
    } catch (e) {
      print('Error verifying OTP: $e');
      return null;
    }
  }

  Future<void> saveUserData(String uid) async {
    try {
      await _supabaseClient.from('users').insert({
        'user_id': uid,
        'user_contact': phoneNumber,
        'f_name': widget.fName,
        'l_name': widget.lName,
        'email': widget.email,
        'birthdate': widget.birthdate,
        'address': widget.address,
        'e_contact_name': widget.eContactName,
        'e_contact_number': widget.eContactNumber,
        'sex': widget.sex,
        'user_role': 'Regular User',
        'user_status': 'Active',
      });
      print('User data saved successfully.');
    } catch (e) {
      print('Error saving user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save user data: $e')),
      );
    }
  }
}
