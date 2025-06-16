import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _eContactNameController = TextEditingController();
  final TextEditingController _eContactNumberController = TextEditingController();

  String _gender = 'Male';
  File? _profileImage;
  String? _profileImageUrl;
  bool isLoading = false;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  /// 🔥 Fetch user data from Firebase
  Future<void> _fetchUserProfile() async {
    setState(() => isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users/${user.uid}');
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);

        _fNameController.text = userData['f_name'] ?? '';
        _lNameController.text = userData['l_name'] ?? '';
        _phoneController.text = userData['user_contact'] ?? '';
        _birthdateController.text = userData['birthdate'] ?? '';
        _addressController.text = userData['address'] ?? '';
        _eContactNameController.text = userData['e_contact_name'] ?? '';
        _eContactNumberController.text = userData['e_contact_number'] ?? '';
        _gender = userData['gender'] ?? 'Male';
        _profileImageUrl = userData['profile_picture'];
      }
    } catch (e) {
      _showSnackbar("❌ Error loading profile: $e", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 📷 Select and Upload Profile Picture
  Future<void> _pickAndUploadProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _profileImage = File(pickedFile.path);
    });

    await _uploadProfileImage(_profileImage!);
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    setState(() => isUploading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final ref = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}/profile.jpg');

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users/${user.uid}');
      await userRef.update({"profile_picture": downloadUrl});

      setState(() => _profileImageUrl = downloadUrl);
      _showSnackbar("✅ Profile picture updated successfully!");
    } catch (e) {
      _showSnackbar("❌ Error uploading image: $e", isError: true);
    } finally {
      setState(() => isUploading = false);
    }
  }

  /// 📅 Select Birthdate from Calendar
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

  /// 💾 Save updated profile details to Firebase RTDB
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users/${user.uid}');

      await userRef.update({
        'f_name': _fNameController.text,
        'l_name': _lNameController.text,
        'user_contact': _phoneController.text,
        'birthdate': _birthdateController.text,
        'address': _addressController.text,
        'gender': _gender,
        'e_contact_name': _eContactNameController.text,
        'e_contact_number': _eContactNumberController.text,
      });

      _showSnackbar("✅ Profile updated successfully!");
    } catch (e) {
      _showSnackbar("❌ Error updating profile: $e", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 🔥 Snackbar Notification
  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
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
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : (_profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : const AssetImage("assets/images/profile_placeholder.png")) as ImageProvider,
                          ),
                          if (isUploading)
                            const CircularProgressIndicator()
                          else
                            const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField("First Name", _fNameController),
                    _buildTextField("Last Name", _lNameController),
                    _buildTextField("Phone Number", _phoneController),

                    GestureDetector(
                      onTap: () => _selectBirthdate(context),
                      child: AbsorbPointer(
                        child: _buildTextField("Birthdate (YYYY-MM-DD)", _birthdateController),
                      ),
                    ),

                    _buildTextField("Address", _addressController),

                    _buildDropdown("Gender", ["Male", "Female"], _gender, (value) => setState(() => _gender = value!)),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Update Profile"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      validator: (value) => value!.isEmpty ? "Enter $label" : null,
    ),
  );

  Widget _buildDropdown(
    String label, List<String> items, String selectedValue, ValueChanged<String?> onChanged) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: DropdownButtonFormField<String>(
      value: selectedValue,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  );
}

}
