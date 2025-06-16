// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import '../services/call_service.dart';

// class AnsweredCallScreen extends StatefulWidget {
//   final VoidCallback onEndCall;

//   const AnsweredCallScreen({Key? key, required this.onEndCall}) : super(key: key);

//   @override
//   State<AnsweredCallScreen> createState() => _AnsweredCallScreenState();
// }

// class _AnsweredCallScreenState extends State<AnsweredCallScreen> {
//   final CallService _callService = CallService();

//   @override
//   void initState() {
//     super.initState();
//     _callService.initRenderer(); // Make sure it's initialized
//   }

//   @override
//   void dispose() {
//     _callService.remoteRenderer.srcObject = null; // Clean up binding
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black87,
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // 🔊 This widget plays remote audio
//             SizedBox(
//               height: 0,
//               width: 0,
//               child: RTCVideoView(
//                 _callService.remoteRenderer,
//                 objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
//               ),
//             ),

//             const Icon(Icons.call, size: 80, color: Colors.greenAccent),
//             const SizedBox(height: 20),
//             const Text(
//               "Connected",
//               style: TextStyle(color: Colors.white70, fontSize: 20),
//             ),
//             const SizedBox(height: 40),
//             ElevatedButton.icon(
//               onPressed: widget.onEndCall,
//               icon: const Icon(Icons.call_end),
//               label: const Text("End Call"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
