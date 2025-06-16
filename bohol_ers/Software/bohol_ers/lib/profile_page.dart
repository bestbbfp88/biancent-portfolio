/*import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>?> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = fetchUserProfile();
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final supabase = Supabase.instance.client;

    // Replace with the table and user identifier used in your database
    final response = await supabase
        .from('users') // Replace 'users' with your table name
        .select()
        .eq('id', supabase.auth.currentUser?.id) // Match the current user ID
        .single();

    if (response.error != null) {
      throw Exception('Failed to fetch profile: ${response.error!.message}');
    }

    return response.data as Map<String, dynamic>?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${user['name']}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Email: ${user['email']}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Phone: ${user['phone']}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Address: ${user['address']}', style: const TextStyle(fontSize: 16)),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('No user data available'),
            );
          }
        },
      ),
    );
  }
}
*/