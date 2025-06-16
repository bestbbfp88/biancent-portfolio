import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // ✅ Import for date formatting

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _eContactNameController = TextEditingController();
  final TextEditingController _eContactNumberController = TextEditingController();

  String _gender = 'Male';
  File? _profileImage;
  String? _profileImageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  /// 🔹 Fetch user data from Firebase
  Future<void> _fetchUserProfile() async {
    setState(() => isLoading = true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users/${user.uid}');
    DataSnapshot snapshot = await userRef.get();

    if (snapshot.exists) {
      Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);

      _fNameController.text = userData['f_name'] ?? '';
      _lNameController.text = userData['l_name'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _birthdateController.text = userData['birthdate'] ?? '';
      _addressController.text = userData['address'] ?? '';
      _eContactNameController.text = userData['e_contact_name'] ?? '';
      _eContactNumberController.text = userData['e_contact_number'] ?? '';
      _gender = userData['gender'] ?? 'Male';
      _profileImageUrl = userData['profile_picture']; // Get profile pic URL
    }

    setState(() => isLoading = false);
  }

  /// 🔹 Select and Upload Profile Picture
  Future<void> _pickAndUploadProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _profileImage = File(pickedFile.path);
    });

    await _uploadProfileImage(_profileImage!);
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // ✅ Reference to storage location
      final ref = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}/profile.jpg');

      // ✅ Upload file
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});

      // ✅ Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // ✅ Save URL to Firebase Database
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users/${user.uid}');
      await userRef.update({"profile_picture": downloadUrl});

      setState(() {
        _profileImageUrl = downloadUrl;
      });
    } catch (e) {
      print("❌ Error uploading image: $e");
    }
  }

  /// 🔹 Select Birthdate from Calendar
  Future<void> _selectBirthdate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  /// 🔹 Save updated profile details to Firebase RTDB
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users/${user.uid}');

    await userRef.update({
      'f_name': _fNameController.text,
      'l_name': _lNameController.text,
      'email': _emailController.text,
      'birthdate': _birthdateController.text,
      'address': _addressController.text,
      'gender': _gender,
      'e_contact_name': _eContactNameController.text,
      'e_contact_number': _eContactNumberController.text,
    });

    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile"), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Image
                    GestureDetector(
                      onTap: _pickAndUploadProfileImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (_profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : const AssetImage("assets/images/profile_placeholder.png")) as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Change Picture", style: TextStyle(color: Colors.grey)),

                    const SizedBox(height: 20),

                    _buildTextField("First Name", _fNameController),
                    _buildTextField("Last Name", _lNameController),
                    _buildTextField("Email", _emailController),

                    // Birthdate Selector
                    GestureDetector(
                      onTap: () => _selectBirthdate(context),
                      child: AbsorbPointer(
                        child: _buildTextField("Birthdate (YYYY-MM-DD)", _birthdateController),
                      ),
                    ),

                    _buildTextField("Address", _addressController),
                    _buildTextField("Emergency Contact Name", _eContactNameController),
                    _buildTextField("Emergency Contact Number", _eContactNumberController),

                    // Gender Dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: DropdownButtonFormField<String>(
                        value: _gender,
                        items: const [
                          DropdownMenuItem(value: "Male", child: Text("Male")),
                          DropdownMenuItem(value: "Female", child: Text("Female")),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _gender = value);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Gender",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Update"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value == null || value.isEmpty ? "Please enter $label" : null,
      ),
    );
  }
}
