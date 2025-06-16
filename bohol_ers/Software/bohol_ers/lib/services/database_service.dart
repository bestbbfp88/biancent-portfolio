import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Save user data to the database
  Future<void> saveUserData({
    required String firstName,
    required String lastName,
    String? birthdate,
    required String address,
    required String email,
    required String usercontact,
    required String eContactName,
    required String eContactNumber,
    String? gender,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;


    // Check if the user is authenticated
    if (user == null) {
      print('Error: User is not authenticated.');
      throw Exception('User is not authenticated');
    }

    try {
      // Insert user data into the database
      final response = await _client.from('users').insert({
        'fName': firstName,
        'lName': lastName,
        'birthdate': birthdate,
        'user_Contact': usercontact,
        'user_Role': 'Regular User',
        'user_Status': 'Active',
        'e_contactName': eContactName,
        'e_contactNumber': eContactNumber,
        'gender': gender,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (response.error != null) {
        throw Exception('Error saving user data: ${response.error!.message}');
      }

      // If no exception is thrown, the insertion is successful.
      print('User data saved successfully!');
    } catch (e) {
      // Catch and handle any errors
      print('Error saving user data: $e');
      throw Exception('Error saving user data');
    }
  }

  /// Fetch user data by ID
  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

    } catch (e) {
      // Catch and handle any errors
      print('Error fetching user data: $e');
      throw Exception('Error fetching user data');
    }
    return null;
  }
}

