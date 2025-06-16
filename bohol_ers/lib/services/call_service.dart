
import 'package:bohol_emergency_response_system/main_navigation/call_screen.dart';
import 'package:bohol_emergency_response_system/services/play-audio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/material.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCVideoRenderer _dummyRenderer = RTCVideoRenderer();
  
  audioPlayer _audioPlayer = audioPlayer();
  bool isRendererDisposed = false;
  
  bool isMuted = false;
  String? activeCallID;
  bool isInCall = false;

  // Future<void> initRenderer() async {
  //   await remoteRenderer.initialize();
  //   print("🎥 Remote renderer initialized.");
  // }

 Future<void> disposeCallResources() async {
  print("🧹 Disposing call resources...");

  try {
    // ❌ Stop local stream and tracks
    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    await _localStream?.dispose();
    _localStream = null;
    print("🎤 Local stream stopped and disposed.");

    // ❌ Stop remote stream if any
    _remoteStream?.getTracks().forEach((track) {
      track.stop();
    });
    await _remoteStream?.dispose();
    _remoteStream = null;
    print("🔈 Remote stream stopped and disposed.");
    await _dummyRenderer.dispose();

    // ❌ Dispose peer connection
    await _peerConnection?.close();
    await _peerConnection?.dispose();
    _peerConnection = null;
    print("🔌 PeerConnection closed and disposed.");

  } catch (e) {
    print("❌ Error during disposeCallResources: $e");
  }
}

Future<void> acceptCall(String callId, BuildContext context) async {
  activeCallID = callId;

  isInCall = true;
  await _dummyRenderer.initialize();

  print("📞 Accepting call with ID: $callId");

  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  await _audioPlayer.stopRingtone();


  final DatabaseReference callRef = _dbRef.child('calls/$callId');

  await callRef.child('status').set("accepted");
  await callRef.child("receivers/$userId").set("accepted");

  final config = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {
        'urls': 'turn:relay.metered.ca:443',
        'username': 'openai',
        'credential': 'openai',
      },
    ],
  };

  _peerConnection = await createPeerConnection(config);
  print("🔧 PeerConnection created.");

  _localStream = await navigator.mediaDevices.getUserMedia({
    'audio': true,
    'video': false,
  });
  _localStream!.getTracks().forEach((track) {
    _peerConnection!.addTrack(track, _localStream!);
    print("📤 Track added: ${track.kind}");
  });
  
  setLocalStream(_localStream!);
  // Remote track setup
 _peerConnection!.onTrack = (event) async {
  print("📡 Remote track received.");

  if (_remoteStream == null) {
    _remoteStream = await createLocalMediaStream('remote');
  }

  _remoteStream!.addTrack(event.track);

   if (event.track.kind == 'audio') {
      event.track.enabled = true;
      Helper.setSpeakerphoneOn(true);
      await _attachToRenderer(_remoteStream!);
    }
};

  // Listen for caller's ICE candidates
  final callerIdSnapshot = await callRef.child('callerId').get();
  final String callerId = callerIdSnapshot.value.toString();

  callRef.child("candidates/$callerId").onChildAdded.listen((event) {
    final data = Map<String, dynamic>.from(event.snapshot.value as Map);
    final candidate = RTCIceCandidate(
      data['candidate'],
      data['sdpMid'],
      data['sdpMLineIndex'],
    );
    _peerConnection!.addCandidate(candidate);
    print("📥 Added remote ICE candidate.");
  });

  // Send own ICE candidates
  _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
    print("📡 Sending ICE candidate...");
    callRef.child("candidates/$userId").push().set({
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    });
  };

  // Get the offer
  final offerSnapshot = await callRef.child('offer').get();
  if (offerSnapshot.exists) {
    final offerData = offerSnapshot.value as Map;
    final offer = RTCSessionDescription(offerData['sdp'], offerData['type']);

    await _peerConnection!.setRemoteDescription(offer);
    print("📲 Remote offer set.");

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    await callRef.child('answer').set(answer.toMap());
    print("📤 Sent answer: ${answer.toMap()}");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          callID: callId,
          isCaller: false,
        ),
      ),
    );
  } else {
    print("❌ Offer not found yet in Firebase.");
  }
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


void setLocalStream(MediaStream stream) {
  _localStream = stream;
  print("✅ Local stream assigned in CallService.");
}

  Future<void> toggleMute() async {
    if (_localStream == null) {
      print("❌ Local stream is null.");
      return;
    }

    final audioTracks = _localStream!.getAudioTracks();
    if (audioTracks.isEmpty) {
      print("❌ No audio tracks found.");
      return;
    }

    final track = audioTracks.first;
    track.enabled = !track.enabled;
    isMuted = !track.enabled;

    print(isMuted ? "🔇 Muted in CallService" : "🎙️ Unmuted in CallService");
  }

Future<void> rejectCall(BuildContext context) async {
  isInCall = false;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  await _audioPlayer.stopRingtone();
  try {
    // Fetch the calls where the receiver's status is "ringing"
    final querySnapshot = await _dbRef
        .child("calls")
        .orderByChild("receivers/$userId")
        .equalTo("ringing")
        .get();

    if (querySnapshot.exists) {
      // Loop through the query snapshot to check and update the status of "ringing" calls
      querySnapshot.children.forEach((callSnapshot) {
        final callData = callSnapshot.value as Map;
        final status = callData["status"];

        // If the call status is "ringing", update it to "rejected"
        if (status == "ringing") {
          print("❌ Rejecting call with ID: ${callSnapshot.key}");

          // Update the overall call status to "rejected"
          _dbRef.child("calls/${callSnapshot.key}/status").set("declined");
          print("✅ Call status updated to 'rejected' in Firebase");

          // Update the receivers' status to "rejected"
          _dbRef.child("calls/${callSnapshot.key}/receivers/$userId").set("declined");
          print("✅ Receiver status updated to 'rejected' in Firebase");

          // Optionally, navigate back or perform other actions after rejecting the call
          Navigator.pop(context);
        }
      });
    } else {
      print("⚠️ No calls found with status 'ringing' for receiverId: $userId");
    }
  } catch (e) {
    print("❌ Error rejecting the call: $e");
  }
}

 Future<void> endCall(BuildContext context) async {
      activeCallID = null;
      isInCall = false;
      

      final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

      try {
        // Fetch the calls where the receiver's status is "accepted"
        final querySnapshot = await _dbRef
            .child("calls")
            .orderByChild("receivers/$userId")
            .equalTo("accepted")
            .get();

        if (querySnapshot.exists) {
          // Loop through the query snapshot to check and update the status of "accepted" calls
          querySnapshot.children.forEach((callSnapshot) async {
            final callData = callSnapshot.value as Map;
            final status = callData["status"];

            // If the call status is "accepted", update it to "ended"
            if (status == "accepted") {
              print("❌ Ending call with ID: ${callSnapshot.key}");

              // Update the overall call status to "ended"
              await _dbRef.child("calls/${callSnapshot.key}/status").set("ended");
              print("✅ Call status updated to 'ended' in Firebase");

              // Update the receivers' status to "ended"
              await _dbRef.child("calls/${callSnapshot.key}/receivers/$userId").set("ended");
              print("✅ Receiver status updated to 'ended' in Firebase");

              // Perform cleanup on the WebRTC session
              if (_peerConnection != null) {
                _peerConnection?.close();
                print("✅ Peer connection closed.");
              }

              if (_localStream != null) {
                _localStream?.getTracks().forEach((track) {
                  track.stop();
                });
                print("✅ Local stream tracks stopped.");
              }

              if (_remoteStream != null) {
                _remoteStream?.getTracks().forEach((track) {
                  track.stop();
                });
                print("✅ Remote stream tracks stopped.");
              }
              await _dummyRenderer.dispose();

              // Reset all references
              _peerConnection = null;
              _localStream = null;
              _remoteStream = null;

                Navigator.pop(context);

              print("📴 Call ended and all resources cleaned up.");
            }
          });
        } else {
          print("⚠️ No calls found with status 'accepted' for receiverId: $userId");
        }
      } catch (e) {
        print("❌ Error ending the call: $e");
      }
    }

}

Future<List<String>> getReceivers(String callId) async {
  final usersRef = FirebaseDatabase.instance.ref("users");
  final callsRef = FirebaseDatabase.instance.ref("calls/$callId/receivers");

  final usersSnapshot = await usersRef.get();
  final callsSnapshot = await callsRef.get();

  List<String> eligibleReceiverIDs = [];

  if (usersSnapshot.exists) {
    final usersData = Map<String, dynamic>.from(usersSnapshot.value as Map);

    for (final entry in usersData.entries) {
      final String userId = entry.key;
      final Map<String, dynamic> userData = Map<String, dynamic>.from(entry.value);

      final isCommunicatorOrAdmin = userData["user_role"] == "Communicator" || userData["user_role"] == "Admin";
      final isAccepted = callsSnapshot.child(userId).value == "accepted";

      if (isCommunicatorOrAdmin && !isAccepted) {
        eligibleReceiverIDs.add(userId);
        print("✅ Eligible receiver: $userId");
      }
    }
  }

  print("🎯 Final eligible receivers: $eligibleReceiverIDs");
  return eligibleReceiverIDs;
}

