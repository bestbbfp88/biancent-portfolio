import 'package:bohol_emergency_response_system/edit_navigation/edit_medical.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MedicalProfileScreen extends StatefulWidget {
  const MedicalProfileScreen({super.key});

  @override
  MedicalProfileScreenState createState() => MedicalProfileScreenState();
}

class MedicalProfileScreenState extends State<MedicalProfileScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String name = "Loading...";
  String dob = "Loading...";
  String chronicConditions = "N/A";
  String weight = "N/A";
  String height = "N/A";
  String bloodType = "N/A";
  String allergies = "N/A";
  String profileImageUrl = "";
  String currentMedications = "N/A";
  String disabilityStatus = "N/A";
  String emcName = "N/A";
  String emcNumber = "N/A";
  String gender = "Unknown";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
/// 🔹 Fetch user data and medical profile from Firebase
Future<void> _fetchUserData() async {
  try {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in.");

    // Fetch user personal details from "users/{user.uid}"
    DataSnapshot userSnapshot = await _dbRef.child("users/${user.uid}").get();
    if (!userSnapshot.exists) throw Exception("User data not found.");

    Map<String, dynamic> userData = Map<String, dynamic>.from(userSnapshot.value as Map);

    // Retrieve medical_ID from user data
    String? medicalId = userData["medical_ID"];

    Map<String, dynamic>? medicalData;
    
    if (medicalId != null && medicalId.isNotEmpty) {
      // Fetch medical record from "medical/{medical_ID}"
      DataSnapshot medicalSnapshot = await _dbRef.child("medical/$medicalId").get();

      if (medicalSnapshot.exists) {
        medicalData = Map<String, dynamic>.from(medicalSnapshot.value as Map);
      }
    }

    // Update UI state with combined data
    setState(() {
      name = "${userData["f_name"] ?? ""} ${userData["l_name"] ?? ""}".trim();
      dob = userData["birthdate"] ?? "Unknown";
      gender = userData["gender"] ?? "Unknown";
      emcName = userData["e_contact_name"] ?? "Unknown";
      emcNumber = userData["e_contact_number"] ?? "Unknown";

      // Medical profile data
      chronicConditions = medicalData?["chronic_conditions"] ?? "No";
      weight = "${medicalData?["weight"] ?? "N/A"} kg";
      height = "${medicalData?["height"] ?? "N/A"} cm";
      currentMedications = medicalData?["current_medications"] ?? "N/A";
      disabilityStatus = medicalData?["disability_status"] ?? "N/A";
      bloodType = medicalData?["blood_type"] ?? "Unknown";
      allergies = medicalData?["allergies"] ?? "None";
    });

    // Fetch and update profile image
    await _fetchProfileImage(user.uid);
  } catch (e) {
    print("❌ Error fetching user data: $e");
  } finally {
    setState(() => isLoading = false);
  }
}


  /// 🔹 Fetch Profile Picture from Firebase Storage
  Future<void> _fetchProfileImage(String uid) async {
    try {
      final ref = FirebaseStorage.instance.ref().child("profile_pictures/$uid/profile.jpg");
      final url = await ref.getDownloadURL();
      setState(() => profileImageUrl = url);
    } catch (e) {
      print("❌ Error fetching profile image: $e");
      setState(() => profileImageUrl = ""); // Use default if not found
    }
  }

  /// 🔹 Open Edit Medical Profile as a Pop-up
  Future<void> _openEditMedicalPopup() async {
    Map<String, String> medicalData = {
      "chronic_conditions": chronicConditions,
      "weight": weight.replaceAll(" kg", ""),
      "height": height.replaceAll(" cm", ""),
      "blood_type": bloodType,
      "allergies": allergies,
      "current_medications": currentMedications,
      "disability_status": disabilityStatus,
    };

    bool? updated = await showDialog<bool>(
      context: context,
      builder: (context) => EditMedicalProfile(medicalData: medicalData),
    );

    if (updated == true) {
      _fetchUserData(); // ✅ Refresh medical profile if changes were saved
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.local_hospital, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text("Medical Profile", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _openEditMedicalPopup, // ✅ Open edit as a pop-up
            child: const Text("Edit", style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 🔹 Show loading indicator
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🔹 Profile Image
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : const AssetImage("assets/images/profile.png") as ImageProvider,
                  ),
                  const SizedBox(height: 10),

                  // 🔹 Name
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),

                  // 🔹 Date of Birth
                  Text(dob, style: const TextStyle(fontSize: 16, color: Colors.grey)),

                  const SizedBox(height: 20),

                  // 🔹 Section Title
                  _buildSectionTitle("Personal Details"),

                  _buildInfoRow("Gender", gender),
                  _buildInfoRow("Chronic Condition", chronicConditions),
                  _buildInfoRow("Weight", weight),
                  _buildInfoRow("Height", height),
                  _buildInfoRow("Blood Type", bloodType),
                  _buildInfoRow("Allergies", allergies),
                  _buildInfoRow("Current Medications", currentMedications),
                  _buildInfoRow("Disability Status", disabilityStatus),
                  _buildInfoRow("Emergency Contact Name", emcName),
                  _buildInfoRow("Emergency Contact Number", emcNumber),
                ],
              ),
            ),
    );
  }

  /// 🔹 Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
    );
  }

  /// 🔹 Single Row of Medical Information
  Widget _buildInfoRow(String title, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
              Text(value, style: const TextStyle(fontSize: 16, color: Colors.black54)),
            ],
          ),
        ),
        const Divider(),
      ],
    ); 
  }
}
