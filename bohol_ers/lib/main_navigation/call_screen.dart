import 'dart:async';
import 'package:bohol_emergency_response_system/services/play-audio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/call_service.dart';
import 'package:bohol_emergency_response_system/services/make_call.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallScreen extends StatefulWidget {
  final String callID;
  final bool isCaller;

  const CallScreen({
    Key? key,
    required this.callID,
    required this.isCaller,
  }) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final _callService = CallService();
  
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer(); // ✅

  late WebRTCCallerService _makeCall; // Initialize later

   RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  audioPlayer _audioPlayer = audioPlayer();
    
  bool _isMuted = false;
  bool _isSpeakerOn = false;

  late final String _userId;
  String _callStatus = "Initializing...";
  StreamSubscription<DatabaseEvent>? _statusSubscription;

  Timer? _callTimer;
  int _elapsedSeconds = 0;

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }


  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    _initializeRendererAndCall();
  }

  Future<void> _initializeRendererAndCall() async {
    //await _remoteRenderer.initialize(); 
    _makeCall = WebRTCCallerService(); // ✅ Proper initialization

    if (widget.isCaller) {
      _startCallTimer();
      _initiateCall(); // Start call logic
    } else {
      _listenForCallStatus(); // Wait for status to update to "accepted"
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _callService.disposeCallResources();
    _remoteRenderer.dispose(); // ✅ Dispose properly
    super.dispose();
  }


Future<void> _initiateCall() async {
  setState(() => _callStatus = "Calling...");

  final List<String> filteredReceiverIds = await getReceivers(widget.callID);

  await _makeCall.startCall(context, filteredReceiverIds, widget.callID);

  _listenForCallStatus();
}

  void _listenForCallStatus() {
    final statusRef =
        dbRef.child("calls/${widget.callID}/status");

    _statusSubscription = statusRef.onValue.listen((event) async {
      if (!event.snapshot.exists) return;

      final status = event.snapshot.value.toString();
      print("📡 Call status updated: $status");

      if (mounted) {
        setState(() => _callStatus = _mapStatusText(status));
      }

      if (status == "accepted" && !widget.isCaller) {
        // Receiver accepted, join the call
        if (mounted) {
          setState(() => _callStatus = "In Call");
        }
        _startCallTimer();
        print("Timer");  
      }

      if (["cancelled", "missed", "declined", "ended"].contains(status)) {
        await _audioPlayer.stopRingtone();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    });
  }

  String _mapStatusText(String status) {
    switch (status) {
      case "ringing":
        return widget.isCaller ? "Ringing..." : "Incoming Call...";
      case "accepted":
        return "In Call";
      case "cancelled":
        return "Call Cancelled";
      case "declined":
        return "Call Declined";
      case "missed":
        return "Call Missed";
      case "ended":
        return "Call Ended";
      default:
        return "Connecting...";
    }
  }

void _startCallTimer() {
  _callTimer?.cancel(); // prevent duplicates
  _elapsedSeconds = 0;
  _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
    if (mounted) {
      setState(() {
        _elapsedSeconds++;
      });
    }
  });
}

Future<void> _endCall() async {
  final dbRef = FirebaseDatabase.instance.ref();
  final callRef = dbRef.child("calls/${widget.callID}");
  final userId = FirebaseAuth.instance.currentUser?.uid ?? "";

  try {
    print("📴 Ending call for: $userId");

    // Update receiver statuses
    final receiversSnapshot = await callRef.child("receivers").get();
    if (receiversSnapshot.exists) {
      final updates = <String, dynamic>{};
      final receivers = Map<String, dynamic>.from(receiversSnapshot.value as Map);

      for (final entry in receivers.entries) {
        updates["receivers/${entry.key}"] = "ended";
      }

      await callRef.update(updates);
      print("✅ All receiver statuses updated to 'ended'");
    }

    // Update call status and connection details
    await callRef.update({
      "status": "ended",
      "timestamp": ServerValue.timestamp,
    });

    await callRef.child("connection").update({
      "status": "ended",
      "endedAt": ServerValue.timestamp,
    });

    try {
        print("🧹 Disposing call resources...");

        // Dispose local stream
        if (_localStream != null) {
          _localStream!.getTracks().forEach((track) => track.stop());
          await _localStream!.dispose();
          print("🎤 Local stream stopped and disposed.");
          _localStream = null;
        }

        // Dispose remote stream
        if (_remoteStream != null) {
          _remoteStream!.getTracks().forEach((track) => track.stop());
          await _remoteStream!.dispose();
          print("🔈 Remote stream stopped and disposed.");
          _remoteStream = null;
        }

        // Close and dispose PeerConnection
        await _peerConnection?.close();
        await _peerConnection?.dispose();
        print("🔌 PeerConnection closed and disposed.");
        _peerConnection = null;

        // Safely dispose renderer
        if (_remoteRenderer.textureId != null) {
          _remoteRenderer.srcObject = null;
          await _remoteRenderer.dispose();
          print("🖥️ Remote renderer disposed.");
        } else {
          print("⚠️ Skipped remoteRenderer.dispose(): Renderer not initialized.");
        }
      } catch (e) {
        print("❌ Error during disposeCallResources: $e");
      }


    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    print("📴 Call and all resources cleaned up.");
  } catch (e) {
    print("❌ Error during call termination: $e");
  }
}


Widget _buildCallButton(IconData icon, String label, VoidCallback onTap) {
  return Column(
    children: [
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(color: Colors.white)),
    ],
  );
}

Future<void> toggleSpeaker() async {
  final newState = !_isSpeakerOn;

  // Optional: force audio mode before changing route
  await Helper.setSpeakerphoneOn(newState);

  setState(() => _isSpeakerOn = newState);
  print(_isSpeakerOn ? "🔊 Speaker enabled" : "🎧 Earpiece enabled");
}

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),
              Column(
                children: [
                  const Text(
                    "Dispatcher", // 🔁 You can replace this with dynamic contact
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                      _callStatus == "In Call"
                          ? _formatDuration(_elapsedSeconds)
                          : _callStatus,
                      style: const TextStyle(color: Colors.grey, fontSize: 18),
                      
                    ),
                    if (widget.isCaller && _callStatus == "Ringing...")
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                        child: Text(
                          "📢 Notifying all responders. Please wait...",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.amberAccent.shade200, fontSize: 16),
                        ),
                      ),

                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCallButton(
                              _callService.isMuted ? Icons.mic_off : Icons.mic,
                              _callService.isMuted ? "Unmute" : "Mute",
                              () async {
                                await _callService.toggleMute();
                                setState(() {}); // just to refresh the button icon
                              },
                            ),

                          _buildCallButton(
                            _isSpeakerOn ? Icons.volume_up : Icons.hearing,
                            _isSpeakerOn ? "Speaker" : "Earpiece",
                            toggleSpeaker,
                          ),

                      ],
                    ),

                  const SizedBox(height: 30),
                 
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: GestureDetector(
                  onTap: _endCall,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

}
