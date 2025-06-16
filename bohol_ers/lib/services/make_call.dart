import 'dart:async';

import 'package:bohol_emergency_response_system/main_navigation/call_screen.dart';
import 'package:bohol_emergency_response_system/services/call_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class WebRTCCallerService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCPeerConnection? _peerConnection;
  bool _navigatedToCallScreen = false;
  bool _callStarted = false;
  final callService = CallService();
  Timer? _callTimeoutTimer;
  RTCVideoRenderer _dummyRenderer = RTCVideoRenderer();


  Future<void> startCall(BuildContext context, List<String> receiverIds, String callId) async {

    if (_callStarted) {
        print("⚠️ Call already started. Skipping duplicate.");
        return;
      }
      _callStarted = true;

    final String callerId = FirebaseAuth.instance.currentUser?.uid ?? "";

    print("📞 Starting call with ID: $callId");

    await _disposeCallResources();

    await _dbRef.child("calls/$callId").set({
      "callerId": callerId,
      "receivers": {for (var id in receiverIds) id: "ringing"},
      "status": "ringing",
      "timestamp": ServerValue.timestamp,
    });

    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {
          'urls': 'turn:relay.metered.ca:80',
          'username': 'openai',
          'credential': 'openai',
        }
      ]
    };

    final mediaConstraints = {
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    print("🎙️ Local stream captured.");

    callService.setLocalStream(_localStream!);

    _peerConnection = await createPeerConnection(config);
    print("🔧 PeerConnection created and renderer initialized.");

    for (var track in _localStream!.getTracks()) {
      _peerConnection!.addTrack(track, _localStream!);
      print("📤 Added local track: ${track.kind}");
    }

    

   _peerConnection!.onTrack = (event) async {
      print("📡 [onTrack] Caller received remote track: ${event.track.kind}");

      _remoteStream ??= await createLocalMediaStream('remote');
      _remoteStream!.addTrack(event.track);

      if (event.track.kind == 'audio') {
      event.track.enabled = true;
      Helper.setSpeakerphoneOn(true);
      await _attachToRenderer(_remoteStream!);
    }

    };

    _peerConnection!.onAddTrack = (stream, track) async {
      print("📡 [onAddTrack] Caller received remote track: ${track.kind}");

      _remoteStream ??= await createLocalMediaStream('remote');
      _remoteStream!.addTrack(track);

      if (track.kind == 'audio') {
        track.enabled = true;
        Helper.setSpeakerphoneOn(true);

        try {
            if (_dummyRenderer.textureId != null) {
              await _dummyRenderer.dispose();
            }

            _dummyRenderer = RTCVideoRenderer();
            await _dummyRenderer.initialize();

            if (_remoteStream != null) {
              _dummyRenderer.srcObject = _remoteStream;
              print("🎧 Remote stream attached to dummyRenderer");
            }
          } catch (e) {
            print("❌ Failed to attach stream to dummyRenderer: $e");
          }

        print("🎧 Remote audio via onAddTrack attached to dummyRenderer");
      }
    };


    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      print("📨 Sending ICE candidate (caller)...");
      _dbRef.child("calls/$callId/candidates/$callerId").push().set({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    for (var receiverId in receiverIds) {
      _dbRef.child("calls/$callId/candidates/$receiverId").onChildAdded.listen((event) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final candidate = RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
        print("📩 Received ICE candidate from receiver.");
        _peerConnection!.addCandidate(candidate);
      });
    }

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    await _dbRef.child("calls/$callId/offer").set({
      'type': offer.type,
      'sdp': offer.sdp,
    });
    print("📧 Offer sent to Firebase.");

    _dbRef.child("calls/$callId/answer").onValue.listen((event) async {
      if (event.snapshot.exists) {
        print("📥 Answer received from Firebase");

        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        if (_peerConnection?.signalingState == RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
          final answer = RTCSessionDescription(data['sdp'], data['type']);
          await _peerConnection!.setRemoteDescription(answer);
          print("✅ Caller set remote description (answer)");
        } else {
          print("⚠️ Signaling state not valid for setting remote description");
        }
      } else {
        print("❌ No answer yet in Firebase");
      }
    });


   _callTimeoutTimer = Timer(const Duration(seconds: 30), () async {
      final callSnapshot = await _dbRef.child("calls/$callId").get();
      final callData = callSnapshot.value as Map<dynamic, dynamic>;

      final currentStatus = callData["status"];
      if (currentStatus == "ringing") {
        print("⏱️ Call timed out. Marking as missed.");

        // ✅ Update main call status
        await _dbRef.child("calls/$callId/status").set("missed");

        // ✅ Update all ringing receivers to "missed"
        if (callData["receivers"] != null) {
          final Map receivers = Map.from(callData["receivers"]);
          final updates = <String, dynamic>{};
          receivers.forEach((key, value) {
            if (value == "ringing") {
              updates["calls/$callId/receivers/$key"] = "missed";
            }
          });
          if (updates.isNotEmpty) {
            await _dbRef.update(updates);
          }
        }

        await _disposeCallResources();
      }
    });

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) async {
      print("🔗 Connection state changed: $state");

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        print("✅ WebRTC connection established (caller side).");

       if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
           print("✅ WebRTC connection established (caller side).");
            _callTimeoutTimer?.cancel(); // 🛑 Stop the timeout
            await _dbRef.child("calls/$callId/connection").set({
              "status": "connected",
              "connectedAt": ServerValue.timestamp,
            });
          }


        _dbRef.child("calls/$callId/connection").set({
          "status": "connected",
          "connectedAt": ServerValue.timestamp,
        });
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        print("❌ WebRTC connection failed.");
      }
    };
  }

Future<void> _attachToRenderer(MediaStream stream) async {
  try {
    if (_dummyRenderer.textureId != null) {
      await _dummyRenderer.dispose();
    }

    _dummyRenderer = RTCVideoRenderer();
    await _dummyRenderer.initialize();
    _dummyRenderer.srcObject = stream;

    print("🎧 Stream attached to dummyRenderer successfully.");
  } catch (e) {
    print("❌ Error attaching stream to dummyRenderer: $e");
  }
}


Future<void> _disposeCallResources() async {
  print("🧹 Disposing call resources...");
  try {
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.close();

    if (_dummyRenderer.textureId != null) {
      await _dummyRenderer.dispose();
      _dummyRenderer = RTCVideoRenderer(); // Recreate to avoid reuse-after-dispose
    }

    _callTimeoutTimer?.cancel();
  } catch (e) {
    print("❌ Error during disposal: $e");
  }
  _peerConnection = null;
  _remoteStream = null;
  _localStream = null;
  _callStarted = false;
}
}