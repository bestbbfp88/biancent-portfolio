let localStream;
let remoteStream;
let peerConnection;
let currentCallID = null;
let callTimeout = null;
let isCaller = false;


const peerConfig = {
    iceServers: [{ urls: "stun:stun.l.google.com:19302" }]
};

async function startVoiceCall(receiverID) {
    resetCallUI();
   

    const roomID = `call_${Date.now()}`;
    const callRef = firebase.database().ref(`calls/${roomID}`);
    
    currentCallID = roomID;
    isCaller = true;

    const callerID = firebase.auth().currentUser.uid;
    console.log("📞 Starting call to:", receiverID);

    await callRef.set({
        callerId: callerID,
        receivers: {
            [receiverID]: "ringing"
        },
        status: "ringing",
        timestamp: firebase.database.ServerValue.TIMESTAMP
    });

    document.getElementById("callingStatusIndicator").style.display = "block";
    const ringtone = document.getElementById("ringtoneAudio");
    if (ringtone) ringtone.play();

    // 🔗 Setup the WebRTC connection...
    peerConnection = new RTCPeerConnection(peerConfig);
    localStream = await navigator.mediaDevices.getUserMedia({ audio: true });
    console.log("🎙️ Got local audio stream");
    localStream.getTracks().forEach(track => peerConnection.addTrack(track, localStream));

    peerConnection.onicecandidate = (event) => {
        if (event.candidate) {
            console.log("📡 Caller ICE candidate:", event.candidate);
            firebase.database().ref(`calls/${roomID}/candidates/${callerID}`).push(event.candidate.toJSON());
        }
    };

    const offer = await peerConnection.createOffer();
    await peerConnection.setLocalDescription(offer);

    await callRef.child("offer").set({
        type: offer.type,
        sdp: offer.sdp
    });
    console.log("📨 Sent offer to Firebase");

    peerConnection.ontrack = (event) => {
        if (!remoteStream) remoteStream = new MediaStream();
    
        remoteStream.addTrack(event.track);
        console.log("🔊 Received remote audio track");
    
        const remoteAudio = document.getElementById("remoteAudio");
        if (remoteAudio) {
            remoteAudio.srcObject = remoteStream;
            remoteAudio.muted = false;
            remoteAudio.play().catch((e) => console.warn("⚠️ Audio autoplay failed:", e));
        }
    };

    
    callTimeout = setTimeout(() => {
        console.warn("⌛ Call timed out. No response.");
        document.getElementById("callingStatusIndicator").style.display = "none";
        if (currentCallID) {
            firebase.database().ref(`calls/${currentCallID}`).update({ status: "missed" });
        }
        if (ringtone) {
            ringtone.pause();
            ringtone.currentTime = 0;
        }        

        const timeoutAudio = document.getElementById("timeoutAudio");
        if (timeoutAudio) timeoutAudio.play();

        const noAnswerEl = document.getElementById("noAnswerStatusIndicator");
        if (noAnswerEl) {
            noAnswerEl.style.display = "block";
    
            setTimeout(() => {
                noAnswerEl.style.display = "none";
            }, 3000);
        }

        if (peerConnection) peerConnection.close();
        if (localStream) localStream.getTracks().forEach(track => track.stop());
    }, 30000);    
    
    firebase.auth().onAuthStateChanged(async (user) => {
        if (!user) return;
    
        const currentUserID = user.uid;
        const callRef = firebase.database().ref(`calls/${currentCallID}`);
    
        try {
            const snapshot = await callRef.once("value");
            const callData = snapshot.val();
    
            if (!callData) {
                console.warn("⚠️ No call data found for ID:", currentCallID);
                return;
            }
    
            const isCaller = callData.callerId === currentUserID;
    
            if (!isCaller) {
                console.log("ℹ️ You are not the caller. Skipping status listener.");
                return;
            }
    
            console.log("📡 Listening for call status (caller side)...");
    
            callRef.child("status").on("value", (snapshot) => {
                const status = snapshot.val();
                console.log("📥 Call status updated:", status);
    
                if (status === "accepted") {
                    document.getElementById("callingStatusIndicator").style.display = "none";
                    startCallTimer();
    
                    if (callTimeout) {
                        clearTimeout(callTimeout);
                        callTimeout = null;
                    }
    
                    if (ringtone) {
                        ringtone.pause();
                        ringtone.currentTime = 0;
                    }
    
                    firebase.database().ref(`calls/${roomID}/candidates/${receiverID}`).on("child_added", (snapshot) => {
                        const candidate = new RTCIceCandidate(snapshot.val());
                        console.log("🔁 Received remote ICE candidate from receiver");
                        peerConnection.addIceCandidate(candidate);
                    });
    
                    const callModal = document.getElementById("webrtcModal");
                    if (callModal) callModal.style.display = "block";
    
                    firebase.database().ref(`calls/${currentCallID}/answer`).on("value", (snapshot) => {
                        const answer = snapshot.val();
                        if (answer && !peerConnection.currentRemoteDescription) {
                            const remoteDesc = new RTCSessionDescription(answer);
                            peerConnection.setRemoteDescription(remoteDesc)
                                .then(() => console.log("✅ Set remote answer"))
                                .catch((err) => console.error("❌ Failed to set remote answer:", err));
                        } else if (!answer) {
                            console.warn("⚠️ No answer received yet.");
                        }
                    });
                }
    
                if (["ended", "missed"].includes(status)) {
                    console.log("🔚 Call ended or declined:", status);
                    if (ringtone) {
                        ringtone.pause();
                        ringtone.currentTime = 0;
                    }
                    if (callTimeout) {
                        clearTimeout(callTimeout);
                        callTimeout = null;
                    }
                    if (peerConnection) peerConnection.close();
                    if (localStream) localStream.getTracks().forEach(track => track.stop());
    
                    const callingText = document.getElementById("callingTextIncall");
                    if (callingText) {
                        callingText.textContent = "Call Ended";
                        callingText.classList.add("call-ended-animation");
                    }
    
                    const declineAudio = document.getElementById("declineAudio");
                    if (declineAudio) declineAudio.play();
    
                    document.getElementById("callingStatusIndicator").style.display = "none";
                    stopCallTimer();
                    setTimeout(() => {
                        const modal = document.getElementById("webrtcModal");
                        if (modal) modal.style.display = "none";
                    }, 4000);
                }
    
                if (status === "cancelled") {
                    clearTimeout(callTimeout);
                    if (ringtone) {
                        ringtone.pause();
                        ringtone.currentTime = 0;
                    }

                    if (callTimeout) {
                        clearTimeout(callTimeout);
                        callTimeout = null;
                    }
    
                    const cancelAudio = document.getElementById("cancelAudio");
                    if (cancelAudio) cancelAudio.play();
    
                    cancelOutgoingCall();
                    const cancelCall = document.getElementById("endStatusIndicator");
                    if (cancelCall) {
                        cancelCall.style.display = "block";
                        setTimeout(() => {
                            cancelCall.style.display = "none";
                        }, 3000);
                    }
                    if (peerConnection) peerConnection.close();
                    if (localStream) localStream.getTracks().forEach(track => track.stop());
                }
    
                if (status === "declined") {
                    clearTimeout(callTimeout);
                    if (ringtone) {
                        ringtone.pause();
                        ringtone.currentTime = 0;
                    }
                    if (callTimeout) {
                        clearTimeout(callTimeout);
                        callTimeout = null;
                    }
                    const declineAudio = document.getElementById("declineAudio");
                    if (declineAudio) declineAudio.play();
    
                    if (peerConnection) peerConnection.close();
                    if (localStream) localStream.getTracks().forEach(track => track.stop());
                    document.getElementById("callingStatusIndicator").style.display = "none";
    
                    const declineCall = document.getElementById("declineStatusIndicator");
                    if (declineCall) {
                        declineCall.style.display = "block";
                        setTimeout(() => {
                            declineCall.style.display = "none";
                        }, 3000);
                    }
                }
            });
    
        } catch (error) {
            console.error("❌ Error while checking callerId before status listener:", error);
        }
    });
    
    
    // (Optional) store call ID globally to cancel if needed
    window.currentCallID = roomID;

    console.log(`✅ Call request sent to user ${receiverID}`);
}

function cancelOutgoingCall() {

    document.getElementById("callingStatusIndicator").style.display = "none";

    if (window.currentCallID) {
        firebase.database().ref(`calls/${window.currentCallID}`).update({ status: "cancelled" });
    }

    if (peerConnection) peerConnection.close();
    if (localStream) localStream.getTracks().forEach(track => track.stop());


    console.log("❌ Call cancelled.");
}


async function endCall() {
    const user = firebase.auth().currentUser;
    const userId = user?.uid;
    const callId = window.currentCallID;

    if (!userId || !callId) {
        console.warn("⚠️ Missing user ID or currentCallID.");
        return;
    }

    console.log(`📞 endCall(): Caller ${userId} ending call ${callId}`);

    try {
        const callRef = firebase.database().ref(`calls/${callId}`);

        const snapshot = await callRef.once("value");
        if (!snapshot.exists()) {
            console.warn(`⚠️ Call ${callId} not found.`);
            return;
        }

        const callData = snapshot.val();
        console.log(`ℹ️ Current call status: ${callData.status}`);

        if (callData.callerId !== userId) {
            console.warn("⚠️ You are not the caller for this call.");
            return;
        }

        if (callData.status === "ended") {
            console.log("⚠️ Call already ended.");
            return;
        }

        // ✅ Update call status to "ended"
        await callRef.child("status").set("ended");
        console.log("✅ Call status set to 'ended'.");

        // ✅ Update all receiver statuses to "ended"
        const receivers = callData.receivers || {};
        for (const receiverId in receivers) {
            await callRef.child(`receivers/${receiverId}`).set("ended");
            console.log(`✅ Receiver ${receiverId} status set to 'ended'`);
        }

        // 🧹 Clean up
        if (peerConnection) {
            peerConnection.close();
            peerConnection = null;
            console.log("🔌 Peer connection closed.");
        }

        if (localStream) {
            localStream.getTracks().forEach(track => track.stop());
            localStream = null;
            console.log("🎤 Local stream stopped.");
        }

        if (remoteStream) {
            remoteStream.getTracks().forEach(track => track.stop());
            remoteStream = null;
            console.log("🔊 Remote stream stopped.");
        }

        const localAudio = document.getElementById("localAudio");
        const remoteAudio = document.getElementById("remoteAudio");
        if (localAudio) localAudio.srcObject = null;
        if (remoteAudio) remoteAudio.srcObject = null;

        const callingText = document.getElementById("callingTextIncall");
        if (callingText) {
            callingText.textContent = "Call Ended";
            callingText.classList.add("call-ended-animation");
        }
        const cancelAudio = document.getElementById("cancelAudio");
        if (cancelAudio) cancelAudio.play();
        document.querySelector(".call-controls").style.opacity = "0.3";
        stopCallTimer();
        setTimeout(() => {
            const modal = document.getElementById("webrtcModal");
            if (modal) modal.style.display = "none";
        }, 4000);

        console.log("✅ Call cleanup complete.");
    } catch (error) {
        console.error("❌ Error during endCall():", error);
    }
}

async function joinWebRTCCall(callID) {
    const userID = firebase.auth().currentUser.uid;
    const callRef = firebase.database().ref(`calls/${callID}`);

    // 🔧 Create peer connection
    peerConnection = new RTCPeerConnection(peerConfig);

    // 🎤 Get local audio stream
    localStream = await navigator.mediaDevices.getUserMedia({ audio: true });
    localStream.getTracks().forEach(track => peerConnection.addTrack(track, localStream));
    console.log("🎤 Receiver got local audio stream");

    // 🔊 Handle incoming remote stream
    peerConnection.ontrack = (event) => {
        if (!remoteStream) remoteStream = new MediaStream();
        console.log("🔊 Adding remote track:", event.track.kind);
        remoteStream.addTrack(event.track);

        const remoteAudio = document.getElementById("remoteAudio");
        if (remoteAudio && remoteStream) {
            remoteAudio.srcObject = remoteStream;
            remoteAudio.play().catch((err) => console.warn("⚠️ Audio play failed:", err));
        }
    };

    // 📡 Send ICE candidate
    peerConnection.onicecandidate = (event) => {
        if (event.candidate) {
            firebase.database().ref(`calls/${callID}/candidates/${userID}`).push(event.candidate.toJSON());
            console.log("📡 Receiver ICE candidate sent");
        }
    };

    // ✅ Fetch call data and determine peer
    const callSnap = await callRef.get();
    const callData = callSnap.val();
    const callerId = callData?.callerId;
    const peerId = userID === callerId
        ? Object.keys(callData.receivers).find(id => id !== userID)
        : callerId;

    console.log("👥 Receiver ICE peer target:", peerId);

    // 🔁 Listen to peer ICE candidates
    if (peerId) {
        firebase.database().ref(`calls/${callID}/candidates/${peerId}`).on("child_added", (snapshot) => {
            const candidate = new RTCIceCandidate(snapshot.val());
            peerConnection.addIceCandidate(candidate);
            console.log("📥 Receiver added ICE from peer.");
        });
    }

    // 📩 Get offer and respond with answer
    const offerSnapshot = await callRef.child("offer").once("value");
    const offer = offerSnapshot.val();

    if (offer) {
        await peerConnection.setRemoteDescription(new RTCSessionDescription(offer));
        console.log("📲 Offer set as remote description");

        const answer = await peerConnection.createAnswer();
        await peerConnection.setLocalDescription(answer);

        console.log("📤 Will send answer to Firebase:", answer.toJSON());
        await callRef.child("answer").set(answer.toJSON());
        console.log("📨 Receiver sent answer");
    } else {
        console.warn("⚠️ No offer found in Firebase.");
    }
}

