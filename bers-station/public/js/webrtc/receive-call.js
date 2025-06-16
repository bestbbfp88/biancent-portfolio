let currentIncomingCallID = null;

firebase.auth().onAuthStateChanged(user => {
    if (user) {
        const currentUserID = user.uid;

        firebase.database().ref("calls").on("child_added", async (snapshot) => {
            const callID = snapshot.key;
            const callData = snapshot.val();

            const isReceiver = callData.receivers?.[currentUserID] === "ringing";
            const isRinging = callData.status === "ringing";

            if (isReceiver && isRinging) {
                console.log("📞 Incoming call detected:", callID);
                currentIncomingCallID = callID;

                // 🔍 Fetch caller details
                const callerId = callData.callerId;
                let callerDisplayName = "Unknown Caller";

                try {
                    const userSnapshot = await firebase.database().ref(`users/${callerId}`).once("value");
                    const callerData = userSnapshot.val();

                    if (callerData && callerData.f_name && callerData.l_name) {
                        callerDisplayName = `${callerData.f_name} ${callerData.l_name}`;
                    } else {
                        callerDisplayName = callerId;
                    }
                } catch (e) {
                    console.error("❌ Error fetching caller name:", e);
                }

                // 🔊 Play ringtone and show modal
                const ringing = document.getElementById("ringingAudio");
                if (ringing) ringing.play();

                showIncomingCallModal(callerDisplayName);
            }
        });
    }
});


function showIncomingCallModal(callerDisplay) {
    const callerText = document.getElementById("callerName");
    if (callerText) {
        callerText.textContent = `From: ${callerDisplay}`;
    }

    const modal = document.getElementById("incomingCallModal");
    if (modal) modal.style.display = "flex";
}

async function acceptCall() {
    const userID = firebase.auth().currentUser.uid;
    const callID = currentIncomingCallID;

    if (!callID || !userID) return;

    const callRef = firebase.database().ref(`calls/${callID}`);
    const receiversRef = callRef.child("receivers");

    const ringing = document.getElementById("ringingAudio");
    if (ringing) {
        ringing.pause();
        ringing.currentTime = 0;
    }

    try {
        const snapshot = await receiversRef.once("value");
        const receivers = snapshot.val() || {};

        await receiversRef.child(userID).set("accepted");
        console.log(`✅ Receiver ${userID} set to 'accepted'`);

        for (const receiverID in receivers) {
            if (receiverID !== userID && receivers[receiverID] === "ringing") {
                await receiversRef.child(receiverID).remove();
                console.log(`🗑️ Removed receiver ${receiverID}`);
            }
        }

        await callRef.child("status").set("accepted");
        console.log(`📞 Call status updated to 'accepted'`);

        document.getElementById("incomingCallModal").style.display = "none";
      
        receiverJoinWebRTCCall(callID);

    } catch (error) {
        console.error("❌ Error while accepting call:", error);
    }
}



function declineCall() {
    const userID = firebase.auth().currentUser.uid;
    if (!currentIncomingCallID || !userID) return;

    const ringing = document.getElementById("ringingAudio");
    if (ringing) {
        ringing.pause();
        ringing.currentTime = 0;
    }

    const declineAudio = document.getElementById("declineAudio");
    if (declineAudio) declineAudio.play();

    firebase.database()
        .ref(`calls/${currentIncomingCallID}/receivers/${userID}`)
        .set("declined");

    document.getElementById("incomingCallModal").style.display = "none";
}

async function receiverJoinWebRTCCall(callID) {
    resetCallUI();
    currentCallID = callID;
    isCaller = false;

    const receiverModal = document.getElementById("webrtcModalReceiver");
        if (receiverModal) {
            receiverModal.style.display = "flex"; // or "block"
            receiverModal.style.visibility = "visible";
            receiverModal.style.opacity = "1";
            console.log("✅ Forced receiver modal visible after reset.");
        }
    const userID = firebase.auth().currentUser.uid;
    const callRef = firebase.database().ref(`calls/${callID}`);

    // 1. Get the offer
    const offerSnapshot = await callRef.child("offer").once("value");
    const offer = offerSnapshot.val();

    if (!offer) {
        console.warn("⚠️ No offer found for call ID:", callID);
        return;
    }

    const callerSnapshot = await callRef.child("callerId").once("value");
    const callerId = callerSnapshot.val();
    
            
    if (typeof peerConnection !== 'undefined' && peerConnection !== null) {
         try {
            peerConnection.getSenders().forEach(sender => peerConnection.removeTrack(sender));
            peerConnection.close();
            console.log("🧹 Existing PeerConnection closed.");
            } catch (e) {
            console.warn("⚠️ Failed to close previous PeerConnection:", e);
            }
            peerConnection = null;
    }

    const config = {
        iceServers: [
            { urls: "stun:stun.l.google.com:19302" },
            {
                urls: "turn:relay.metered.ca:80",
                username: "openai",
                credential: "openai"
            }
        ]
    };


    peerConnection = new RTCPeerConnection(config);
    console.log("🔧 Created RTCPeerConnection (audio only)");

    // 3. Setup remote stream
    const remoteAudio = document.getElementById("remoteAudio");
    remoteStream = new MediaStream();
    remoteAudio.srcObject = remoteStream;

    peerConnection.ontrack = event => {
        remoteStream.addTrack(event.track);
        console.log("🎧 Received remote audio track");
    };

    // 4. Get local audio
    try {
        localStream = await navigator.mediaDevices.getUserMedia({ audio: true, video: false });
        localStream.getTracks().forEach(track => peerConnection.addTrack(track, localStream));
        console.log("🎙️ Local audio stream added to connection");
    } catch (err) {
        console.error("❌ Failed to get local audio stream:", err);
        return;
    }

    // 5. Apply remote description
    await peerConnection.setRemoteDescription(new RTCSessionDescription(offer));
    console.log("📥 Set remote description (offer)");

    // 6. Create and send answer
    const answer = await peerConnection.createAnswer();
    await peerConnection.setLocalDescription(answer);

    await callRef.child("answer").set({
        type: answer.type,
        sdp: answer.sdp
    });
    console.log("📤 Answer sent to Firebase");

    // 7. Send receiver's ICE candidates
    peerConnection.onicecandidate = event => {
        if (event.candidate) {
            callRef.child(`candidates/${userID}`).push(event.candidate.toJSON());
            console.log("📡 Sent local ICE candidate");
        }
    };

    // 8. Listen to caller's ICE candidates
    callRef.child(`candidates/${callerId}`).on("child_added", snapshot => {
        const data = snapshot.val();
        if (data) {
            const candidate = new RTCIceCandidate(data);
            peerConnection.addIceCandidate(candidate);
            console.log("🌍 Added remote ICE candidate from caller");
        }
    });

    document.getElementById("webrtcModalReceiver").style.display = "block";
    setTimeout(() => {
        startCallTimer();
    }, 300);
    console.log("✅ WebRTC audio call established");
    listenToReceiverStatus(callID);
}


async function endCallAsReceiver() {
    const userId = firebase.auth().currentUser.uid;
    const callId = currentIncomingCallID;

    if (!userId || !callId) {
        console.warn("⚠️ Missing user or call ID.");
        return;
    }

    const callRef = firebase.database().ref(`calls/${callId}`);
    const statusRef = callRef.child(`status`);
    const receiverRef = callRef.child(`receivers/${userId}`);
    const connectionStatusRef = callRef.child(`connection/status`);
    const connectionEndedAtRef = callRef.child(`connection/endedAt`);

    try {
        // ✅ 1. Check if this user is even listed as a receiver
        const snapshot = await receiverRef.once("value");
        const status = snapshot.val();

        if (!status) {
            console.warn("⚠️ You are not listed as a receiver for this call.");
            return;
        }

        console.log(`📴 Receiver ${userId} ending call ${callId}`);

        // ✅ 2. Update receiver status and overall status
        await receiverRef.set("ended");
        await statusRef.set("ended");

        // ✅ 3. Update connection status and timestamp
        await connectionStatusRef.set("ended");
        await connectionEndedAtRef.set(Date.now());

        // ✅ 4. Optional: cleanup local WebRTC stuff
        if (peerConnection) {
            peerConnection.close();
            peerConnection = null;
        }

        if (localStream) {
            localStream.getTracks().forEach(track => track.stop());
            localStream = null;
        }

        if (remoteStream) {
            remoteStream.getTracks().forEach(track => track.stop());
            remoteStream = null;
        }

        const localAudio = document.getElementById("localAudio");
        const remoteAudio = document.getElementById("remoteAudio");
        if (localAudio) localAudio.srcObject = null;
        if (remoteAudio) remoteAudio.srcObject = null;

        const callingText = document.getElementById("callingTextIncallReceiver");
        if (callingText) {
            callingText.textContent = "You left the call";
            callingText.classList.add("call-ended-animation");
        }

        document.querySelector(".call-controls").style.opacity = "0.3";

        setTimeout(() => {
            const modal = document.getElementById("webrtcModalReceiver");
            if (modal) modal.style.display = "none";
        }, 4000);

        console.log("✅ Receiver call ended, connection status updated, and UI cleaned up.");
        
    } catch (error) {
        console.error("❌ Error ending call as receiver:", error);
    }
}


function listenToReceiverStatus(callID) {
    const userId = firebase.auth().currentUser?.uid;
    if (!userId) {
        console.warn("⚠️ No user ID found, listener aborted.");
        return;
    }

    console.log(`👂 Listening for receiver status at calls/${callID}/receivers/${userId}`);

    const receiverStatusRef = firebase.database().ref(`calls/${callID}/receivers/${userId}`);

    receiverStatusRef.on("value", snapshot => {
        const status = snapshot.val();
        console.log(`📡 Receiver status update: ${status}`);

        if (status === "ended") {
            console.log("👋 Your receiver status changed to 'ended'");

            stopCallTimer();

            // 🧼 UI: Update text and animation
            const callingTextReceiver = document.getElementById("callingTextIncallReceiver");
            if (callingTextReceiver) {
                console.log("✅ Found callingTextIncallReceiver element");
                callingTextReceiver.textContent = "Call Ended";
                callingTextReceiver.classList.add("call-ended-animation");
            } else {
                console.warn("❌ callingTextIncallReceiver element not found");
            }

            // ⏳ Fade out modal after 2 seconds
            setTimeout(() => {
                const modal = document.getElementById("webrtcModalReceiver");
                if (modal) {
                    console.log("🎬 Hiding webrtcModalReceiver");
                    modal.style.display = "none";
                } else {
                    console.warn("❌ webrtcModalReceiver modal not found");
                }

                // 🔕 Stop listening
                receiverStatusRef.off("value");
                console.log("🛑 Listener removed for receiver status");

            }, 2000);

            // 🎧 Clean up media
            if (peerConnection) {
                console.log("📴 Closing peer connection");
                peerConnection.close();
                peerConnection = null;
            }

            if (localStream) {
                console.log("🎙️ Stopping local stream tracks");
                localStream.getTracks().forEach(track => track.stop());
                localStream = null;
            }

            if (remoteStream) {
                console.log("🔈 Stopping remote stream tracks");
                remoteStream.getTracks().forEach(track => track.stop());
                remoteStream = null;
            }

            const remoteAudio = document.getElementById("remoteAudio");
            if (remoteAudio) {
                console.log("🔇 Clearing remoteAudio srcObject");
                remoteAudio.srcObject = null;
            } else {
                console.warn("❌ remoteAudio element not found");
            }
        }
    });
}

function resetCallUI() {
    // Reset call status text
    const receiverText = document.getElementById("callingTextIncallReceiver");
    if (receiverText) {
        receiverText.textContent = "In Call...";
        receiverText.classList.remove("call-ended-animation");
    }

    const callerText = document.getElementById("callingTextIncall");
    if (callerText) {
        callerText.textContent = "Calling...";
        callerText.classList.remove("call-ended-animation");
    }

    // Reset modal visibility and opacity
    const receiverModal = document.getElementById("webrtcModalReceiver");
    if (receiverModal) {
        receiverModal.style.display = "none";
        document.querySelector(".call-controls").style.opacity = "1";
    }

    const callerModal = document.getElementById("webrtcModal");
    if (callerModal) {
        callerModal.style.display = "none";
        document.querySelector(".call-controls").style.opacity = "1";
    }
}
