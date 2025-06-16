import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class CallUtil {
  static const platform = MethodChannel('call_channel');

  static Future<void> makeCall(String phoneNumber) async {
    // Request phone permission
    if (await Permission.phone.request().isGranted) {
      try {
        // Invoke the platform method to make a direct call using native Android code
        await platform.invokeMethod('makeCall', {'number': phoneNumber});
      } on PlatformException catch (e) {
        print("Error: ${e.message}");
        print("Could not make the call.");
      }
    } else if (await Permission.phone.isPermanentlyDenied) {
      // Handle the case where the user has permanently denied the permission
      print('Phone permission permanently denied. Directing user to app settings.');
      await openAppSettings(); // Open the app settings
    } else {
      print('Phone permission denied.');
      // Optionally, show a dialog or snackbar explaining permission is required.
    }
  }
}
