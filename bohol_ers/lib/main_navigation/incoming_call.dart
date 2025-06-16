import 'dart:async';
import 'package:bohol_emergency_response_system/services/play-audio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:bohol_emergency_response_system/services/call_service.dart';

class InCallScreen extends StatefulWidget {
  final String callerName;
  final String emergencyId;
  final BuildContext parentContext;
  final Future<void> Function() onAccept;
  final Future<void> Function() onDecline;
  final Future<void> Function() onEndCall;

  const InCallScreen({
    Key? key,
    required this.callerName,
    required this.emergencyId,
    required this.parentContext,
    required this.onAccept,
    required this.onDecline,
    required this.onEndCall,
  }) : super(key: key);

  @override
  State<InCallScreen> createState() => _InCallScreenState();
}

class _InCallScreenState extends State<InCallScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final _callService = CallService();
  final _audioPlayer = audioPlayer();

  StreamSubscription<DatabaseEvent>? _statusSubscription;

  String _statusText = "INCOMING CALL...";
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _listenForCallStatus();
  }

 void _listenForCallStatus() {
  final statusRef = _dbRef.child("calls/${widget.emergencyId}/status");

  _statusSubscription = statusRef.onValue.listen((event) async {
    if (!event.snapshot.exists) return;

    final status = event.snapshot.value.toString();
    print("📡 Incoming CallScreen status: $status");

    if (["cancelled", "missed", "declined", "ended"].contains(status)) {
      await _audioPlayer.stopRingtone();

      setState(() {
        _statusText = "Call ${_capitalize(status)}";
      });

      // 🔁 Show status for 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _opacity = 0.0; // 🔄 Start fade out
        });
      }

      // 🔚 Exit screen after fade
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
    }
  });
}


  String _capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent.shade100,
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _opacity,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    widget.callerName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _statusText,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 50, color: Colors.blueAccent),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRoundIcon(
                        Icons.call_end,
                        () async {

                          if(mounted){
                          setState(() {
                            _statusText = "Call Declined";
                          });
                          }
                          await Future.delayed(const Duration(seconds: 1));
                          await _callService.rejectCall(widget.parentContext);
                          if (mounted) {
                            setState(() {
                              _opacity = 0.0; // ✅ Start fade out
                            });
                          }

                          await Future.delayed(const Duration(milliseconds: 500)); // ⏳ Wait for animation
                          
                          if (mounted && Navigator.canPop(context)) {
                            Navigator.pop(context); // ✅ Exit screen
                          }
                          

                        },
                        backgroundColor: Colors.red,

                        
                      ),


                  _buildRoundIcon(
                    Icons.call,
                    () async {
                      await _callService.acceptCall(
                          widget.emergencyId, widget.parentContext);
                    },
                    backgroundColor: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundIcon(IconData icon, VoidCallback onTap,
      {Color backgroundColor = Colors.white}) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: backgroundColor,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}
