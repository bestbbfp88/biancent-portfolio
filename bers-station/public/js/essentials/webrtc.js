
// let localStream;
// let remoteStream;
// let peerConnection;
// const peerConfig = { iceServers: [{ urls: "stun:stun.l.google.com:19302" }] };
// const callRoom = db.ref("webrtc_calls");

// // Start WebRTC Call
// async function startVoiceCall(receiverID) {
//     const roomID = `room_${Date.now()}`;
//     const callRef = db.ref(`webrtc_calls/${roomID}`);

//     // Store call request in Firebase RTDB
//     await callRef.set({
//         caller: firebase.auth().currentUser.uid,
//         receiver: receiverID,
//         status: "ringing",
//         timestamp: firebase.database.ServerValue.TIMESTAMP,
//     });

//     console.log(`✅ Call request sent to Flutter user ${receiverID}`);
// }


// // 
// // Handle Signaling Messages
// socket.on("signal", async (data) => {
//     if (data.sdp) {
//         await peerConnection.setRemoteDescription(new RTCSessionDescription(data.sdp));
//         if (data.sdp.type === "offer") {
//             peerConnection.createAnswer()
//                 .then((answer) => peerConnection.setLocalDescription(answer))
//                 .then(() => socket.emit("signal", { room: "emergency-call", sdp: peerConnection.localDescription }));
//         }
//     } else if (data.candidate) {
//         peerConnection.addIceCandidate(new RTCIceCandidate(data.candidate));
//     }
// });

// // ✅ End WebRTC Call
// function endCall() {
//     if (peerConnection) peerConnection.close();
//     if (localStream) localStream.getTracks().forEach(track => track.stop());
//     document.getElementById("localVideo").srcObject = null;
//     document.getElementById("remoteVideo").srcObject = null;
//     new bootstrap.Modal(document.getElementById("webrtcModal")).hide();
// }
