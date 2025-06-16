let callStartTime = null;
let callTimerInterval = null;
let isMuted = false;
let isSpeakerOn = true;
let currentOutputDeviceId = 'default'; 

function startCallTimer() {
    callStartTime = Date.now();
    console.log("⏱️ Timer started at:", new Date(callStartTime).toLocaleTimeString());

    callTimerInterval = setInterval(() => {
        const now = Date.now();
        const elapsed = now - callStartTime;
        const minutes = Math.floor(elapsed / 60000).toString().padStart(2, '0');
        const seconds = Math.floor((elapsed % 60000) / 1000).toString().padStart(2, '0');
        const display = `${minutes}:${seconds}`;

        const callerTimer = document.getElementById("callTimerCaller");
        const receiverTimer = document.getElementById("callTimerReceiver");

        if (callerTimer?.offsetParent !== null) {
            callerTimer.textContent = display;
            console.log("⏱️ Caller timer updated:", display);
        }

        if (receiverTimer?.offsetParent !== null) {
            receiverTimer.textContent = display;
            console.log("⏱️ Receiver timer updated:", display);
        }
    }, 1000);
}


function stopCallTimer() {
  clearInterval(callTimerInterval);
  console.log("🛑 Call timer stopped");

  const callerTimer = document.getElementById("callTimerCaller");
  const receiverTimer = document.getElementById("callTimerReceiver");

  if (callerTimer) {
      callerTimer.textContent = "00:00";
      console.log("🔁 Caller timer reset to 00:00");
  } else {
      console.warn("❌ Caller timer element not found");
  }

  if (receiverTimer) {
      receiverTimer.textContent = "00:00";
      console.log("🔁 Receiver timer reset to 00:00");
  } else {
      console.warn("❌ Receiver timer element not found");
  }
}



function toggleMute() {
    if (!localStream) {
      console.warn("❌ No localStream available.");
      return;
    }
  
    const audioTracks = localStream.getAudioTracks();
    if (audioTracks.length === 0) {
      console.warn("❌ No audio tracks found.");
      return;
    }
  
    isMuted = !isMuted;
    audioTracks.forEach((track, index) => {
      track.enabled = !isMuted;
      console.log(`🎧 Audio track ${index} - kind: ${track.kind} | enabled: ${track.enabled}`);
    });
  
    // Update both mute icons (only one will be visible)
    const callerIcon = document.getElementById("muteIconCaller");
    const receiverIcon = document.getElementById("muteIconReceiver");
  
    if (callerIcon) callerIcon.src = isMuted ? "/images/mic_off.png" : "/images/mic.png";
    if (receiverIcon) receiverIcon.src = isMuted ? "/images/mic_off.png" : "/images/mic.png";
  
    console.log(`🔁 Mute toggled. New state: ${isMuted ? "Muted" : "Unmuted"}`);
  }
  
  function toggleSpeaker() {
    const audioElement = document.getElementById("remoteAudio");
    const speakerIconCaller = document.getElementById("speakerIconCaller");
    const speakerIconReceiver = document.getElementById("speakerIconReceiver");
  
    if (!audioElement || typeof audioElement.setSinkId === 'undefined') {
      alert("🚫 Your browser doesn't support output switching.");
      return;
    }
  
    navigator.mediaDevices.enumerateDevices().then(devices => {
      const outputs = devices.filter(d => d.kind === 'audiooutput');
      if (outputs.length < 2) {
        console.warn("⚠️ Only one audio output device found.");
        return;
      }
  
      const currentIndex = outputs.findIndex(d => d.deviceId === currentOutputDeviceId);
      const nextIndex = (currentIndex + 1) % outputs.length;
      const nextDevice = outputs[nextIndex];
  
      audioElement.setSinkId(nextDevice.deviceId)
        .then(() => {
          currentOutputDeviceId = nextDevice.deviceId;
          isSpeakerOn = nextDevice.label.toLowerCase().includes("speaker");
  
          const iconPath = isSpeakerOn ? "/images/speaker.png" : "/images/earpiece.png";
          if (speakerIconCaller) speakerIconCaller.src = iconPath;
          if (speakerIconReceiver) speakerIconReceiver.src = iconPath;
  
          console.log(`✅ Switched audio output to: ${nextDevice.label || nextDevice.deviceId}`);
        })
        .catch(err => {
          console.error("❌ Failed to switch audio output:", err);
        });
    });
  }
  

function makeElementDraggable(modalId, handleId) {
    const modal = document.getElementById(modalId);
    const handle = document.getElementById(handleId);
  
    let offsetX = 0, offsetY = 0, isDragging = false;
  
    handle.style.cursor = "move";
    modal.style.position = "fixed";
  
    handle.addEventListener("mousedown", (e) => {
      isDragging = true;
      offsetX = e.clientX - modal.getBoundingClientRect().left;
      offsetY = e.clientY - modal.getBoundingClientRect().top;
      modal.style.transform = "none"; // Disable center transform on drag
      document.body.style.userSelect = "none";
    });
  
    document.addEventListener("mousemove", (e) => {
      if (!isDragging) return;
  
      const modalRect = modal.getBoundingClientRect();
      const screenWidth = window.innerWidth;
      const screenHeight = window.innerHeight;
  
      // Clamp left position between 0 and screen width - modal width
      let newLeft = e.clientX - offsetX;
      newLeft = Math.max(0, Math.min(newLeft, screenWidth - modalRect.width));
  
      // Clamp top position between 0 and screen height - modal height
      let newTop = e.clientY - offsetY;
      newTop = Math.max(0, Math.min(newTop, screenHeight - modalRect.height));
  
      modal.style.left = `${newLeft}px`;
      modal.style.top = `${newTop}px`;
    });
  
    document.addEventListener("mouseup", () => {
      isDragging = false;
      document.body.style.userSelect = "";
    });
  }
  

  document.addEventListener("DOMContentLoaded", () => {
    makeElementDraggable("webrtcModal", "webrtcModalHeader");
    makeElementDraggable("webrtcModalReceiver", "webrtcModalReceiverHeader");
  });

  window.addEventListener("beforeunload", async (event) => {
    if (!currentCallID) return;

    console.log("🧹 Page unloading. Cleaning up call:", currentCallID);

    try {
        if (isCaller) {
            await endCall(); // caller's cleanup
        } else {
            await endCallAsReceiver(); // receiver's cleanup
        }
    } catch (err) {
        console.error("❌ Error during unload call cleanup:", err);
    }
});
