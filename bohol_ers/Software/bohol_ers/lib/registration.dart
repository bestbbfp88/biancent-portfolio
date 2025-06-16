import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'auth.dart'; // Import the OTP verification page

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Registration Form Fields
  String fName = '';
  String lName = '';
  String email = '';
  String birthdate = '';
  String address = '';
  String eContactName = '';
  String eContactNumber = '';
  String sex = 'Male';

  final List<String> sexes = ['Male', 'Female', 'Other'];
  bool isLoading = false; // For loading indicator

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final session = Supabase.instance.client.auth.currentSession?.user.id;
    if (session != null) {
      print('Session is active: $session');
    } else {
      print('No active session.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Registration'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('First Name', Icons.person, (value) => fName = value, 'Enter your first name'),
              const SizedBox(height: 16),
              _buildTextField('Last Name', Icons.person, (value) => lName = value, 'Enter your last name'),
              const SizedBox(height: 16),
              _buildTextField('Email', Icons.email, (value) => email = value, 'Enter a valid email address'),
              const SizedBox(height: 16),
              _buildTextField('Birthdate (YYYY-MM-DD)', Icons.cake, (value) => birthdate = value, 'Enter your birthdate'),
              const SizedBox(height: 16),
              _buildTextField('Address', Icons.home, (value) => address = value, 'Enter your address'),
              const SizedBox(height: 16),
              _buildDropdown('Sex', sexes, sex, (value) => sex = value!),
              const SizedBox(height: 16),
              _buildTextField(
                'Emergency Contact Name',
                Icons.contact_page,
                (value) => eContactName = value,
                'Enter emergency contact name',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Emergency Contact Number',
                Icons.phone_in_talk,
                (value) => eContactNumber = value,
                'Enter emergency contact number',
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator() // Loading indicator
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size(
                          MediaQuery.of(context).size.width * 0.6,
                          56,
                        ),
                      ),
                      onPressed: _onRegisterPressed,
                      child: const Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, Function(String) onChanged, String validationMessage) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 0, 0, 0)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown(String label, List<String> options, String value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: options.map((option) {
        return DropdownMenuItem<String>(value: option, child: Text(option));
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }

  Future<void> _onRegisterPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      // Navigate to OTP Verification Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthPage(
            fName: fName,
            lName: lName,
            email: email,
            birthdate: birthdate,
            address: address,
            eContactName: eContactName,
            eContactNumber: eContactNumber,
            sex: sex,
          ),
        ),
      );
    } catch (e) {
      print('Error during registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to proceed: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
