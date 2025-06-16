import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'background_service.dart';
import 'login_page.dart';
import 'main_screen.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await initializeService();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );


  
    await Hive.initFlutter(); // Initialize Hive

  await FMTCObjectBoxBackend().initialise();
  await FMTCStore('mapStore').manage.create();


  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  Widget _screen = const LoginPage();

  @override
  void initState() {
    super.initState();
    _checkAuthAndRole();
  }

  Future<void> _checkAuthAndRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final ref = FirebaseDatabase.instance.ref("users/${user.uid}");
      final snapshot = await ref.once();
      final data = snapshot.snapshot.value as Map?;

      if (data != null && data['user_role'] == 'Emergency Responder') {
        _screen = const MainScreen();
      } else {
        await FirebaseAuth.instance.signOut(); // logout unauthorized users
        _screen = const LoginPage(errorMessage: 'Access denied: Not an Emergency Responder.');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _screen;
  }
}


