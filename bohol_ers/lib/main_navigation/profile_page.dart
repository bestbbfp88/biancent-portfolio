import 'dart:convert';
import 'package:bohol_emergency_response_system/edit_navigation/editprofile.dart';
import 'package:bohol_emergency_response_system/emergency_request/emergency_history.dart';
import 'package:bohol_emergency_response_system/main_navigation/callScreenHistory.dart';
import 'package:bohol_emergency_response_system/main_navigation/legalScreen.dart';
import 'package:bohol_emergency_response_system/main_navigation/medical_profile.dart';
import 'package:bohol_emergency_response_system/main_navigation/permissions_Screen.dart';
import 'package:bohol_emergency_response_system/routes/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>?> _userProfileFuture;
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _loadUserProfile();
  }

  /// 🔹 Load Cached User Profile or Fetch from Firebase
  Future<Map<String, dynamic>?> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cachedProfile = prefs.getString('cached_user_profile');

    if (cachedProfile != null) {
      debugPrint('✅ Loading user profile from cache.');
      return jsonDecode(cachedProfile);
    } else {
      debugPrint('🌐 Fetching user profile from Firebase...');
      return await _fetchUserProfile();
    }
  }

  /// 🔹 Fetch User Profile from Firebase RTDB
  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    try {
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
      final DataSnapshot snapshot = await dbRef.child('users').child(currentUser.uid).get();

      if (!mounted) return null;
      if (snapshot.exists && snapshot.value != null) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);

        // ✅ Save profile data locally for offline use
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('cached_user_profile', jsonEncode(userData));

        return userData;
      } else {
        debugPrint('❌ User data not found in Firebase RTDB.');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching user profile: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: isLoggingOut
                ? const CircularProgressIndicator()
                : const Icon(Icons.logout, color: Color.fromARGB(255, 111, 111, 111)),
            onPressed: isLoggingOut ? null : () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data available'));
          }

          final user = snapshot.data!;
          return _buildProfileContent(user);
        },
      ),
    );
  }

  /// 🔹 Build Profile Content
  Widget _buildProfileContent(Map<String, dynamic> user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ✅ Profile Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user['profile_picture'] ?? "https://via.placeholder.com/150"),
                ),
                const SizedBox(height: 8),
                Text('${user['f_name']} ${user['l_name']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(user['address'], style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(user['user_contact'], style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const Divider(height: 2),

          // ✅ Settings Section
          _listTile( context, "View Emergency History", destination: const EmergencyHistoryScreen(), ),

          _listTile( context, "Medical ID", destination: const MedicalProfileScreen(), ),

          _listTile( context, "Edit Profile", destination: const EditProfileScreen(),  ),

          const Divider(height: 2),

         _listTile(
            context,
            "Call History",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CallHistoryScreen(), // replace with actual widget
                ),
              );
            },
          ),


          _listTile(
            context,
            "Legal",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LegalScreen(), // replace with actual widget
                ),
              );
            },
          ),

          _listTile(
            context,
            "Permissions",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PermissionsScreen()),
              );
            },
          ),


          const Divider(height: 2),
        ],
      ),
    );
  }


Widget _listTile(
  BuildContext context,  // ✅ Add context for navigation
  String title, {
    String? trailing,
    VoidCallback? onTap,
    Widget? destination, }) {
      return ListTile(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: trailing != null
            ? Text(trailing, style: const TextStyle(fontSize: 16, color: Colors.grey))
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (destination != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          } else if (onTap != null) {
            onTap();
          }
        },
      );
}

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 🔹 Logout Function
  Future<void> _logout(BuildContext context) async {
    if (isLoggingOut) return;
    setState(() => isLoggingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('cached_user_profile'); // Clear cached data
      if (mounted) context.router.replaceAll([const LoginRoute()]);
    } catch (e) {
      debugPrint('❌ Error during logout: $e');
    } finally {
      if (mounted) setState(() => isLoggingOut = false);
    }
  }
}
