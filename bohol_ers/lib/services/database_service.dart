import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// 🔹 Save user data to Firebase Realtime Database (RTDB)
  Future<void> saveUserData({
    required String firstName,
    required String lastName,
    String? birthdate,
    required String address,
    required String email,
    required String user_contact,
    required String eContactName,
    required String eContactNumber,
    String? gender,
  }) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      print('Error: User is not authenticated.');
      throw Exception('User is not authenticated');
    }

    try {
      // ✅ Reference to the user's document in RTDB
      final userRef = _dbRef.child('users').child(user.uid);

      // ✅ Save user data
      await userRef.set({
        'f_name': firstName,
        'l_name': lastName,
        'birthdate': birthdate ?? '',
        'user_contact': user_contact,
        'user_role': 'Regular User',
        'user_status': 'Active',
        'e_contact_name': eContactName,
        'e_contact_number': eContactNumber,
        'gender': gender ?? 'Not Specified',
        'address': address,
        'email': email,
        'created_at': ServerValue.timestamp, 
      });

      print('User data saved successfully to RTDB!');
    } catch (e) {
      print('Error saving user data to RTDB: $e');
      throw Exception('Error saving user data');
    }
  }

  /// 🔹 Fetch user data by userId from Firebase RTDB
  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      // ✅ Reference to the user's data in RTDB
      final userSnapshot = await _dbRef.child('users').child(userId).get();

      if (userSnapshot.exists && userSnapshot.value != null) {
        // ✅ Convert the RTDB snapshot value into a Map
        return Map<String, dynamic>.from(userSnapshot.value as Map);
      } else {
        print('User data not found in RTDB.');
        return null;
      }
    } catch (e) {
      print('Error fetching user data from RTDB: $e');
      throw Exception('Error fetching user data');
    }
  }
}
