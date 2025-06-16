import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:bers_responder/screens/edit_profile.dart';
import 'package:bers_responder/screens/personnel_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _profileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No profile data found"));
          }

          return _buildProfileContent(snapshot.data!);
        },
      ),
    );
  }

  /// 🔄 Real-time Profile Stream (user, unit, personnel)
  Stream<Map<String, dynamic>?> _profileStream() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      yield null;
      return;
    }

    final userRef = FirebaseDatabase.instance.ref("users/${user.uid}");
    final unitRef = FirebaseDatabase.instance.ref("responder_unit");
    final personnelRef = FirebaseDatabase.instance.ref("responder_personnel");

    await for (final userEvent in userRef.onValue) {
      if (!userEvent.snapshot.exists) {
        yield null;
        continue;
      }

      final profileData = Map<String, dynamic>.from(userEvent.snapshot.value as Map);

      // 🧠 Fetch unit info
      final unitEvent = await unitRef.orderByChild("ER_ID").equalTo(user.uid).once();
      if (unitEvent.snapshot.exists) {
        final unit = (unitEvent.snapshot.value as Map).values.first as Map;
        profileData["unit"] = Map<String, dynamic>.from(unit);

        // 🧠 Fetch personnel info if unit_ID available
        final unitID = unit["unit_ID"];
        if (unitID != null) {
          final personnelEvent = await personnelRef.orderByChild("unit_ID").equalTo(unitID).once();
          if (personnelEvent.snapshot.exists) {
            final personnel = (personnelEvent.snapshot.value as Map).values.first as Map;
            profileData["personnel"] = Map<String, dynamic>.from(personnel);
          }
        }
      }

      yield profileData;
    }
  }

  /// 🔹 Build Profile Content UI
  Widget _buildProfileContent(Map<String, dynamic> userData) {
    String fullName = "${userData["f_name"] ?? "N/A"} ${userData["l_name"] ?? ""}".trim();
    String email = userData["email"] ?? "N/A";
    String userRole = userData["user_role"] ?? "N/A";

    var unit = userData["unit"] ?? {};
    String unitName = unit["unit_Name"] ?? "Unassigned";
    String unitAssign = unit["unit_Assign"] ?? "Unknown";
    String unitStatus = unit["unit_Status"] ?? "Unknown";

    var personnel = userData["personnel"] ?? {};
    String personnelName = "${personnel["erp_fname"] ?? "N/A"} ${personnel["erp_lname"] ?? ""}".trim();
    String personnelContact = personnel["erp_Contact"] ?? "N/A";
    String personnelStatus = personnel["erp_Status"] ?? "N/A";

    return SingleChildScrollView(
      child: Column(
        children: [
          // 🔘 Profile Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(userRole, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 2),

          // 🔘 Unit Info
          _listTile(Icons.business, "Unit Name", unitName),
          _listTile(Icons.assignment, "Unit Assignment", unitAssign),
          _listTile(Icons.warning, "Unit Status", unitStatus),

          const Divider(height: 2),

          // 🔘 Navigation
          _listTileNav(context, "Edit Profile", destination: const EditProfileScreen()),
          _listTileNav(context, "Personnel", destination: const PersonnelPage()),
        ],
      ),
    );
  }

  /// 🔹 Basic Info Tile
  Widget _listTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.redAccent),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey)),
    );
  }

  /// 🔹 Nav List Tile
  Widget _listTileNav(BuildContext context, String title, {String? trailing, VoidCallback? onTap, Widget? destination}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: trailing != null
          ? Text(trailing, style: const TextStyle(fontSize: 16, color: Colors.grey))
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        } else if (onTap != null) {
          onTap();
        }
      },
    );
  }
}
