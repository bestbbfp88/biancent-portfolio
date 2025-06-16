import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'splash_screen.dart';
import 'contact_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized
 
 await Supabase.initialize(
    url: 'https://znjxgxdolzgewhwwrwsi.supabase.co', // Replace with your Supabase Project URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpuanhneGRvbHpnZXdod3dyd3NpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxNTg2MDcsImV4cCI6MjA1MTczNDYwN30.aIF4CSpZRIbjORHmfJN_BO2kDQv_hHgHNfRXKNq6Txc', // Replace with your Supabase anon key
  );

final supabase = Supabase.instance.client;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bohol Emergency Response System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // Disable the debug banner
      home: const SplashScreen(), // Directly use SplashScreen here
      routes: {
        '/home': (context) => const HomeScreen(), // Home screen route
        '/splash': (context) => const SplashScreen(), // Splash screen route
        '/noInternet': (context) => const ContactPage(), // No-internet fallback route
      },
    );
  }
}
