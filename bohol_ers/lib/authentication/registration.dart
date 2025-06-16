import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bohol_emergency_response_system/routes/router.dart';
import 'package:bohol_emergency_response_system/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';


@RoutePage()
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}
// Google API Key (Replace with your actual API key)
const String googleApiKey = "AIzaSyCPsfUXwsekHMBh140eb0XtxtPkj2Rwo98";

class RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Registration Form Fields
  String fName = '';
  String lName = '';
  String email = '';
  String address = '';
  String eContactName = '';
  String eContactNumber = '';
  String sex = 'Male';
  String phoneNumber = '';
  DateTime? selectedBirthdate;
  String otpCode = ''; // Stores the OTP entered by the user
  String verificationId = ''; // Stores the Firebase verification ID
  bool isOTPRequested = false; // Controls OTP field visibility

  int resendSeconds = 60; // Countdown timer
  bool canResendOTP = false; // Controls resend button state
  Timer? _resendTimer;
  String? otpError;

  final List<String> sexes = ['Male', 'Female', 'Other'];
  bool isLoading = false;
  
  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  final DatabaseService _dbService = DatabaseService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Registration')),
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
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildAddressField(),
              const SizedBox(height: 16),
              _buildDropdown('Sex', sexes, sex, (value) => sex = value!),
              const SizedBox(height: 16),
              _buildPhoneNumberInput(),
              const SizedBox(height: 16),
              if (isOTPRequested) _buildOTPField() ,
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
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size(MediaQuery.of(context).size.width * 0.6, 56),
                      ),
                      onPressed: isOTPRequested ? _verifyOTP : _onRegisterPressed,
                      child: Text(isOTPRequested ? 'Verify OTP' : 'Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ **Restored `_buildTextField()` Method**
  Widget _buildTextField(String label, IconData icon, Function(String) onChanged, String validationMessage) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black),
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

   /// ✅ **Restored `_buildDropdown()` Method**
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
  if (!_formKey.currentState!.validate()) return;

  setState(() => isLoading = true);

  try {
    final bool exists = await _checkPhoneNumberExists(phoneNumber);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is already registered. Please log in.')),
      );
      setState(() => isLoading = false);
      return;
    }

    // ✅ Start phone number verification
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
        context.router.replace(const HomeRoute());
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: ${e.message}')));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          this.verificationId = verificationId;
          isOTPRequested = true; // ✅ Show OTP field
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent successfully!')));
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  } finally {
    setState(() => isLoading = false);
  }
}


  /// ✅ **Check if phone number exists in RTDB**
  Future<bool> _checkPhoneNumberExists(String phoneNumber) async {
    try {
      final DataSnapshot snapshot = await _databaseRef
          .child('users')
          .orderByChild('user_contact')
          .equalTo(phoneNumber)
          .get()
          .timeout(const Duration(seconds: 10));

      return snapshot.exists;
    } catch (e) {
      debugPrint('❌ Error checking phone number: $e');
      return false;
    }
  }

Widget _buildPhoneNumberInput() {
  final TextEditingController _phoneController = TextEditingController();
  String? phoneError;

  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InternationalPhoneNumberInput(
            onInputChanged: (PhoneNumber number) {
              String formattedNumber = number.phoneNumber ?? '';
              
              // ✅ Ensure phone number is in E.164 format
              if (!formattedNumber.startsWith("+")) {
                formattedNumber = "+$formattedNumber";
              }

              phoneNumber = formattedNumber;
              _phoneController.text = phoneNumber;

              // ✅ Validate input length (should be exactly 12 digits, including country code)
              setState(() {
                if (phoneNumber.length < 13) {
                  phoneError = "Please enter a valid phone number";
                } else if (phoneNumber.length > 13) {
                  phoneError = "Please enter a valid phone number";
                } else {
                  phoneError = null; // ✅ Valid input
                }
              });
            },
            initialValue: PhoneNumber(isoCode: 'PH'),
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              showFlags: true,
            ),
            inputDecoration: InputDecoration(
              labelText: 'Phone Number',
              errorText: phoneError, // ✅ Shows inline error
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            ),
            keyboardType: TextInputType.phone,
            textFieldController: _phoneController,
            formatInput: false, // Prevent automatic formatting
          ),
        ],
      );
    },
  );
}

  Widget _buildDatePicker() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Birthdate',
        prefixIcon: const Icon(Icons.cake, color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: _selectDate),
      ),
      controller: TextEditingController(
        text: selectedBirthdate != null ? DateFormat('yyyy-MM-dd').format(selectedBirthdate!) : '',
      ),
      validator: (value) => selectedBirthdate == null ? 'Please select your birthdate' : null,
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedBirthdate = picked;
      });
    }
  }

_buildAddressField() {
  final TextEditingController addressController = TextEditingController(text: address);

  return TextFormField(
    controller: addressController,
    readOnly: true,
    decoration: InputDecoration(
      labelText: "Address",
      prefixIcon: const Icon(Icons.location_on, color: Colors.black),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
    onTap: () async {
      Prediction? prediction = await PlacesAutocomplete.show(
        context: context,
        apiKey: googleApiKey,
        mode: Mode.overlay, // OR Mode.fullscreen
        language: "en",
        components: [Component(Component.country, "PH")], // Restrict to Philippines
      );

      if (prediction != null) {
        address = prediction.description!;
        addressController.text = address;
        setState(() {});
      }
    },
    validator: (value) {
      if (value == null || value.isEmpty) return "Enter your address";
      return null;
    },
  );
}



 void _startResendTimer() {
  setState(() {
    resendSeconds = 60;
    canResendOTP = false;
  });

  _resendTimer?.cancel(); // ✅ Cancel any existing timer before starting a new one

  _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (resendSeconds > 0) {
      setState(() {
        resendSeconds--;
      });
    } else {
      setState(() {
        canResendOTP = true;
      });
      timer.cancel();
    }
  });
}


Future<void> _resendOTP() async {
    _startResendTimer(); // Restart the timer
    setState(() => isLoading = true);

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
          context.router.replace(const HomeRoute());
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: ${e.message}')));
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            this.verificationId = verificationId;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP resent successfully!')));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error resending OTP: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }
  
Widget _buildOTPField() {
  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: "Enter OTP",
              prefixIcon: const Icon(Icons.lock, color: Colors.black),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              errorText: otpError, // ✅ Displays OTP error inside the input field
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                otpCode = value;
                otpError = null; // ✅ Clears error when the user types a new OTP
              });
            },
            validator: (value) {
              if (value == null || value.length != 6) {
                return "Enter a valid 6-digit OTP";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // ✅ **Resend OTP Button with Countdown**
          TextButton(
            onPressed: canResendOTP ? () {
              _resendOTP();
              setState(() {}); // ✅ Rebuild UI
            } : null,
            child: Text(
              canResendOTP ? "Resend OTP" : "Resend OTP in $resendSeconds seconds",
              style: TextStyle(
                color: canResendOTP ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        ],
      );
    },
  );
}


 Future<void> _verifyOTP() async {
    if (otpCode.length != 6) {
      setState(() {
        otpError = "Enter a valid 6-digit OTP";
      });
      return;
    }

    setState(() => isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      await _firebaseAuth.signInWithCredential(credential);
      await _dbService.saveUserData(
        firstName: fName,
        lastName: lName,
        email: email,
        birthdate: selectedBirthdate != null ? DateFormat('yyyy-MM-dd').format(selectedBirthdate!) : '',
        address: address,
        user_contact: phoneNumber,
        eContactName: eContactName,
        eContactNumber: eContactNumber,
        gender: sex,
      );

      context.router.replace(const HomeRoute());
    } catch (e) {
      setState(() {
        otpError = "Invalid OTP. Please try again."; // ✅ Show error message inside the input field
      });
    } finally {
      setState(() => isLoading = false);
    }
  }
}
