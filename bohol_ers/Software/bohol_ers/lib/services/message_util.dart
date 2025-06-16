import 'package:url_launcher/url_launcher.dart';

class MessageUtil {
  static Future<void> sendMessage(String phoneNumber, String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message}, // Pass the message here
    );

    // Check if the SMS URI can be launched
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      // If the first attempt failed, try the fallback method
      print('Could not launch $smsUri');
      if (await canLaunchUrl(Uri.parse('sms:$phoneNumber'))) {
        await launchUrl(Uri.parse('sms:$phoneNumber'));
      } else {
        print('Could not launch SMS app for $phoneNumber');
      }
    }
  }
}
