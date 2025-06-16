import 'dart:async';

import 'package:auto_route/annotations.dart';
import 'package:bohol_emergency_response_system/main_navigation/call_screen.dart';
import 'package:bohol_emergency_response_system/main_navigation/incoming_call.dart';
import 'package:bohol_emergency_response_system/services/call_service.dart';
import 'package:bohol_emergency_response_system/services/play-audio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'styles/button_styles.dart'; // Import your IconStyle class
import 'main_navigation/home_page.dart';
import 'main_navigation/contact_page.dart';
import 'main_navigation/advisory_page.dart';
import 'main_navigation/profile_page.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late StreamSubscription<DatabaseEvent> _callListener;
  final user = FirebaseAuth.instance.currentUser;
  final CallService _callService = CallService();
  audioPlayer _audioPlayer = audioPlayer();
  
  OverlayEntry? _callBannerEntry;

  final List<Widget> _pages = [
    HomePage(),
    ContactPage(),
    AdvisoryPage(),
    ProfilePage(),
  ];
  Timer? _callCheckTimer;
  @override
  void initState() {
    super.initState();
    if (user != null) {
      _listenToIncomingCalls(user!.uid);
    }
      // _callCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      //   if (_callService.isInCall && ModalRoute.of(context)?.isCurrent == true && _selectedIndex == 0) {
      //     _showOverlayCallBanner();
      //   }

      //   if (!_callService.isInCall && _callBannerEntry != null) {
      //     _removeOverlayCallBanner();
      //   }
      // });

  }

  @override
  void dispose() {
    _callListener.cancel();
     _callCheckTimer?.cancel();
    super.dispose();
  }

// void _showOverlayCallBanner() {
//   if (_callBannerEntry != null) return;

//   _callBannerEntry = OverlayEntry(
//     builder: (context) => Positioned(
//       top: MediaQuery.of(context).padding.top + 8,
//       left: 16,
//       right: 16,
//       child: AnimatedOpacity(
//         opacity: 1.0,
//         duration: Duration(milliseconds: 300),
//         child: Material(
//           elevation: 6,
//           borderRadius: BorderRadius.circular(12),
//           color: Colors.green.shade700,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("📞 You're in a call", style: TextStyle(color: Colors.white, fontSize: 16)),
//                 TextButton(
//                   onPressed: () {
//                     if (_callService.activeCallID != null) {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => CallScreen(
//                             callID: _callService.activeCallID!,
//                             isCaller: false,
//                           ),
//                         ),
//                       );
//                     }
//                     _removeOverlayCallBanner();
//                   },
//                   child: const Text("Return", style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     ),
//   );

//   Overlay.of(context).insert(_callBannerEntry!);
// }


// void _removeOverlayCallBanner() {
//   _callBannerEntry?.remove();
//   _callBannerEntry = null;
// }


void _listenToIncomingCalls(String userId) {
  final callsRef = FirebaseDatabase.instance.ref("calls");

  _callListener = callsRef.onChildAdded.listen((event) async {
    final data = event.snapshot.value as Map?;
    if (data == null) return;

    final status = data["status"];
    final callerId = data["callerId"];
    final receivers = Map<String, dynamic>.from(data["receivers"] ?? {});
    final callId = event.snapshot.key;

    if (status == "ringing" &&
        receivers.containsKey(userId) &&
        receivers[userId] == "ringing") {
      // 🔔 Start ringing
      await _audioPlayer.playRingtone();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InCallScreen(
              callerName: "Dispatcher",
              emergencyId: callId!,
              parentContext: context,
              onAccept: () async {
                
                Navigator.pop(context);

                await FirebaseDatabase.instance
                    .ref("calls/$callId/status")
                    .set("accepted");
                if (mounted) {
                  await _audioPlayer.stopRingtone();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CallScreen(
                        callID: callId ?? '',
                        isCaller: false,
                      ),
                    ),
                    
                  );
                }
              },
              onDecline: () async {
               
               
                Navigator.pop(context);
                await FirebaseDatabase.instance
                    .ref("calls/$callId/receivers/$userId")
                    .set("declined");
                await FirebaseDatabase.instance
                    .ref("calls/$callId/status")
                    .set("declined");
                    await _audioPlayer.stopRingtone();
              },
              onEndCall: () async {
               await _audioPlayer.stopRingtone();
                await _callService.endCall(context);
                if (mounted) Navigator.pop(context);
              },
            ),
          ),
        );
      }
    }
  });
}



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: const Color.fromARGB(255, 45, 55, 72),

              
              unselectedItemColor: Colors.black54,
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              elevation: 8,
              items: [
                _buildBottomNavItem('assets/icons/Home.png', 'Home', 0),
                _buildBottomNavItem('assets/icons/Contact.png', 'Contacts', 1),
                _buildBottomNavItem('assets/icons/Advisory.png', 'Advisory', 2),
                _buildBottomNavItem('assets/icons/Profile.png', 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(String iconPath, String label, int index) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        iconPath,
        width: 24,
        height: 24,
        color: _selectedIndex == index ? const Color.fromARGB(255, 45, 55, 72) : Colors.black54,
      ),
      label: label,
    );
  }
}
