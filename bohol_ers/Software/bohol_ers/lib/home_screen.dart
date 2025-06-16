import 'package:flutter/material.dart';
import 'styles/button_styles.dart'; // Import your IconStyle class
import 'home_page.dart';
import 'contact_page.dart';
import 'advisory_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of pages corresponding to each BottomNavigationBar item
  final List<Widget> _pages = [
    HomePage(),
    ContactPage(),
    AdvisoryPage(),
   // ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Selected index
        onTap: _onItemTapped, // Handle taps
        selectedItemColor: const Color.fromARGB(255, 0, 0, 0), // Change color for selected item
        unselectedItemColor: Colors.black, // Change color for unselected items
        items: [
          IconStyle.customIcon(
            iconAsset: 'assets/icons/Home.png',
            label: 'Home',
          ),
          IconStyle.customIcon(
            iconAsset: 'assets/icons/Contact.png',
            label: 'Contact',
          ),
          IconStyle.customIcon(
            iconAsset: 'assets/icons/Advisory.png',
            label: 'Advisory',
          ),
          IconStyle.customIcon(
            iconAsset: 'assets/icons/Profile.png',
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
