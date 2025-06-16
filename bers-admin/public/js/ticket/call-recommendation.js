async function detectNetworkFromFirebase(user_ID) {
    const networkRef = firebase.database().ref("network_status");

    try {
        const snapshot = await networkRef.orderByChild("user_ID").equalTo(user_ID).limitToLast(1).once("value");

        if (!snapshot.exists()) {
            console.warn("⚠️ No network status found for this user.");
            showCallRecommendation("unknown", 0);
            return;
        }

        let networkType = "unknown";
        let networkSpeed = 0;
        snapshot.forEach(childSnapshot => {
            const networkData = childSnapshot.val();
            networkType = networkData.network_type || "unknown";
            networkSpeed = networkData.speed_mbps || 0;
        });

        showCallRecommendation(networkType, networkSpeed, user_ID);
    } catch (error) {
        console.error("❌ Error fetching network status:", error);
        showCallRecommendation("unknown", 0);
    }
}


function showCallRecommendation(networkType, networkSpeed, uid) {
    const networkRef = firebase.database().ref("users");

    if (!uid || uid.trim() === "") {
        alert("❌ No user ID provided.");
        return;
    }

    networkRef.child(uid).once("value")
        .then(snapshot => {
            if (!snapshot.exists()) {
                alert("❌ User not found.");
                return;
            }

            const userData = snapshot.val();
            const phoneNumber = userData.user_contact || "";

            if (!phoneNumber || phoneNumber.trim() === "") {
                alert("❌ No contact number available.");
                return;
            }

            const callRecommendationText = document.getElementById("callRecommendationText");
            const webrtcCallOption = document.getElementById("webrtcCallOption");
            const localCallOption = document.getElementById("localCallOption");

            const phoneCall = document.getElementById("phoneCall");
            if (phoneCall) phoneCall.href = `tel:${phoneNumber}`;

            const webrtcCall = document.getElementById("startWebRTCCall");
            if (webrtcCall) {
                webrtcCall.setAttribute("data-user-id", uid);
            }

            const modalBody = document.querySelector("#callRecommendationModal .modal-body");

            // Clear previous order
            webrtcCallOption.style.display = "none";
            localCallOption.style.display = "none";
            if (modalBody.contains(webrtcCallOption)) modalBody.removeChild(webrtcCallOption);
            if (modalBody.contains(localCallOption)) modalBody.removeChild(localCallOption);

            // ✅ Determine which is recommended and place it first
            if ((networkType.includes("Wi-Fi") || networkType.includes("4G") || networkType.includes("5G")) && networkSpeed > 1) {
                callRecommendationText.innerHTML = `User is on <strong>${networkType}</strong> with a speed of <strong>${networkSpeed} Mbps</strong>. WebRTC call is recommended.`;

                webrtcCallOption.style.display = "block";
                localCallOption.style.display = "block";

                modalBody.appendChild(webrtcCallOption);
                modalBody.appendChild(localCallOption);
            } else {
                callRecommendationText.innerHTML = `User's network speed is low (<strong>${networkSpeed} Mbps</strong>). A local phone call is recommended.`;

                localCallOption.style.display = "block";
                webrtcCallOption.style.display = "block";

                modalBody.appendChild(localCallOption);
                modalBody.appendChild(webrtcCallOption);
            }

            // ✅ Show the Modal
            const callModal = document.getElementById("callRecommendationModal");
            if (callModal) {
                new bootstrap.Modal(callModal).show();
            } else {
                console.error("❌ Call Recommendation Modal not found in DOM.");
            }

        })
        .catch(error => {
            console.error("❌ Error fetching user contact:", error);
            alert("❌ Error fetching user details.");
        });
}


function handleCallButtonClick(userID) {

    if (!userID || userID === "null") {
        console.error("⚠️ No user ID found for call recommendation.");
        alert("User ID not found. Please try again.");
        return;
    }

    detectNetworkFromFirebase(userID);
}


function startWebRTCCallFromButton(button) {
    const receiverID = button.getAttribute("data-user-id");
    if (receiverID) {
        startVoiceCall(receiverID);
    } else {
        console.error("❌ No receiver ID found on button.");
    }
}

