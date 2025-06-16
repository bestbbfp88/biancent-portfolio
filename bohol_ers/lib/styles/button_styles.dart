import 'package:flutter/material.dart';

const Color customColor = Color(0xFFFF956B);

final ButtonStyle elevatedButtonStyleStrong = ElevatedButton.styleFrom(
  backgroundColor: customColor,
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(31),
  ),
);

final ButtonStyle elevatedButtonStyleLight = ElevatedButton.styleFrom(
  backgroundColor: const Color.fromARGB(227, 214, 214, 214),
  foregroundColor: const Color.fromARGB(255, 0, 0, 0),
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(31),
  ),
);

final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
  foregroundColor: customColor,
  side: BorderSide(color: customColor, width: 2),
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
);

class IconStyle {
  static BottomNavigationBarItem customIcon({
    required String iconAsset, // Path to your custom icon asset
    Color color = Colors.black, // Default icon color
    double size = 25.0, // Default icon size
     Color labelColor = Colors.black, // Default label text color
    required String label, // Use 'text' instead of 'label'
   
  }) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        iconAsset,
        width: size,
        height: size,
        color: color,
      ),
      label: label, // Use the string label directly here
    );
  }
}



