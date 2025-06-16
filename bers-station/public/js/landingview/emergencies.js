let sosMarkers = new Map();
let userUID = null;

function loadEmergencyLocationsRealtime() {
    const emergenciesRef = firebase.database().ref("emergencies");
    const usersRef = firebase.database().ref("users");

    firebase.auth().onAuthStateChanged(user => {
        if (user) {
            userUID = user.uid;
            console.log("✅ Signed-in user UID:", userUID);

            emergenciesRef.on("value", async (snapshot) => {
                console.log("📡 Fetching emergencies data...");
                if (!snapshot.exists()) {
                    console.log("❌ No emergencies data found.");
                    clearAllEmergencyMarkers();
                    return;
                }

                const emergenciesData = snapshot.val();
                const activeEmergencies = new Set();

                for (const [emergencyID, emergency] of Object.entries(emergenciesData)) {
                    if (!emergency.user_ID) continue;
                    if (!emergency.assign_station) continue;
                
                    const assignedStations = emergency.assign_station.split(",").map(id => id.trim());
                    if (!assignedStations.includes(userUID)) continue;
                
                    if (emergency.responder_Status === "Done") continue;
                    if (emergency.report_Status !== "Assigning" && emergency.report_Status !== "Responding") continue;

                    try {
                        const userSnapshot = await usersRef.child(emergency.user_ID).once("value");
                        if (userSnapshot.exists()) {
                            const userData = userSnapshot.val();

                            const emergencyData = {
                                lat: emergency.live_es_latitude,
                                lng: emergency.live_es_longitude,
                                location: emergency.location,
                                status: emergency.report_Status,
                                responderStatus: emergency.responder_Status,
                                date_time: emergency.date_time,
                                userType: emergency.is_User,
                                emergencyID: emergency.report_ID,
                                user: {
                                    fullname: `${userData.f_name || ""} ${userData.l_name || ""}`.trim(),
                                    contact: userData.user_contact || "N/A",
                                    email: userData.email || "N/A"
                                },
                                user_ID: emergency.user_ID
                            };

                            activeEmergencies.add(emergencyID);

                            if (!knownEmergencies.has(emergencyID)) {
                                knownEmergencies.set(emergencyID, emergencyData);
                                addSOSMarker(emergencyData);
                                playAlarm();
                            } else {
                                let existingData = knownEmergencies.get(emergencyID);
                                if (existingData.lat !== emergencyData.lat || existingData.lng !== emergencyData.lng) {
                                    updateSOSMarker(emergencyID, emergencyData.lat, emergencyData.lng);
                                }
                                updateSOSMarkerInfo(emergencyID, emergencyData);
                                knownEmergencies.set(emergencyID, emergencyData);
                            }
                        }
                    } catch (error) {
                        console.error("❌ Error fetching user data:", error);
                    }
                }

                removeInactiveEmergencyMarkers(activeEmergencies);
            }, error => console.error("❌ Error fetching emergencies:", error));
        }
    });
}

function listenForEmergencyStatusUpdates() {
    const emergenciesRef = firebase.database().ref("emergencies");
    const usersRef = firebase.database().ref("users");

    emergenciesRef.on("child_changed", async (snapshot) => {
        const emergencyID = snapshot.key;
        const emergency = snapshot.val();

        console.log(`🚨 Emergency Updated: ${emergencyID} | New Status: ${emergency.report_Status}`);

        try {
            const userSnapshot = await usersRef.child(emergency.user_ID).once("value");
            if (!userSnapshot.exists()) {
                console.warn(`⚠️ No user found for user_ID: ${emergency.user_ID}`);
                return;
            }

            const userData = userSnapshot.val();

            const updatedEmergencyData = {
                lat: emergency.live_es_latitude,
                lng: emergency.live_es_longitude,
                location: emergency.location,
                status: emergency.report_Status,
                responderStatus: emergency.responder_Status,
                date_time: emergency.date_time,
                userType: emergency.is_User,
                emergencyID: emergency.report_ID,
                user: {
                    fullname: `${userData.f_name || ""} ${userData.l_name || ""}`.trim(),
                    contact: userData.user_contact || "N/A",
                    email: userData.email || "N/A"
                },
                user_ID: emergency.user_ID
            };

            if (sosMarkers.has(emergencyID)) {
                const marker = sosMarkers.get(emergencyID);
                marker.setPopupContent(getEmergencyInfoContent(updatedEmergencyData));
                knownEmergencies.set(emergencyID, updatedEmergencyData);
            }

        } catch (err) {
            console.error("❌ Error updating info window content:", err);
        }
    }, error => {
        console.error("❌ Error listening to emergency updates:", error);
    });
}

function removeEmergencyMarker(emergencyID) {
    if (sosMarkers.has(emergencyID)) {
        let marker = sosMarkers.get(emergencyID);
        marker.setMap(null); // Remove from map
        sosMarkers.delete(emergencyID); // Remove from storage
        knownEmergencies.delete(emergencyID); // Remove from known emergencies
        console.log(`🗑 Removed marker for Emergency ID: ${emergencyID}`);
    }
}

function removeInactiveEmergencyMarkers(activeEmergencies) {
    for (let emergencyID of sosMarkers.keys()) {
        if (!activeEmergencies.has(emergencyID)) {
            removeEmergencyMarker(emergencyID);
        }
    }
}

function clearAllEmergencyMarkers() {
    for (let marker of sosMarkers.values()) {
        marker.setMap(null);
    }
    sosMarkers.clear();
    knownEmergencies.clear();
    console.log("🗑 Cleared all emergency markers.");
}


function addSOSMarker(emergency) {
    const { lat, lng, status, emergencyID } = emergency;

    const sosIcon = L.icon({
        iconUrl: "../images/sosmarker.png",
        iconSize: [50, 50],
        iconAnchor: [25, 50]
    });

    let marker;

    if (sosMarkers.has(emergencyID)) {
        marker = sosMarkers.get(emergencyID);
        marker.setLatLng([lat, lng]);
        marker.setPopupContent(getEmergencyInfoContent(emergency));
        marker.status = status;
    } else {
        marker = L.marker([lat, lng], { icon: sosIcon })
            .addTo(map)
            .bindPopup(getEmergencyInfoContent(emergency));
        marker.status = status;
        sosMarkers.set(emergencyID, marker);
    }

    if (status === "Assigning") {
        marker.setBouncingOptions({
            bounceHeight: 20,
            bounceSpeed: 52,
            exclusive: false
        });

        if (!marker.isBouncing()) {
            marker.bounce();
        }
    } else {
        if (marker.isBouncing()) {
            marker.stopBouncing();
        }
    }
}


function updateSOSMarker(emergencyID, lat, lng) {
    const marker = sosMarkers.get(emergencyID);
    if (marker) {
        marker.setLatLng([lat, lng]);
    }
}

function updateSOSMarkerInfo(emergencyID, data) {
    const marker = sosMarkers.get(emergencyID);
    if (marker) {
        marker.setPopupContent(getEmergencyInfoContent(data));
    }
}

function getEmergencyInfoContent(emergency) {
    let actionButton = (emergency.status === "Responding" || emergency.status === "Assigning")
        ? `<button onclick=\"fetchEmergencyDetails('${emergency.emergencyID}')\" style=\"background: #ffc107; color: black; border: none; padding: 5px 10px; margin: 5px; cursor: pointer;\">Edit Ticket</button>`
        : `<button onclick=\"fetchEmergencyDetails('${emergency.emergencyID}')\" style=\"background: #007bff; color: white; border: none; padding: 5px 10px; margin: 5px; cursor: pointer;\">Create Ticket</button>`;

    return `
        <div style="text-align: center; padding: 10px; max-width: 250px;">
            <strong style="color: red; font-size: 18px;">🚨 SOS Emergency</strong><br>
            <hr style="margin: 5px 0;">
            <strong>📍 Location:</strong> ${emergency.location || "Unknown"}<br>
            <strong>📌 Status:</strong> ${emergency.status || "Unknown"}<br>
            <strong>⏳ Reported:</strong> ${formatDateTime(emergency.date_time)}<br>
            <strong>👤 User Type:</strong> ${emergency.userType || "Unknown"}<br>
            <hr style="margin: 5px 0;">
            <strong>🙍‍♂️ Reported By:</strong> ${emergency.user.fullname || "Unknown"}<br>
            <strong>📞 Contact:</strong> ${emergency.user.contact || "N/A"}<br>
            <strong>📧 Email:</strong> ${emergency.user.email || "N/A"}<br>
            ${actionButton}
            <button onclick="handleCallButtonClick('${emergency.user_ID}')" style="background: #dc3545; color: white; border: none; padding: 5px 10px; margin: 5px; cursor: pointer;">Call Now</button>
        </div>`;
}


function clearAllEmergencyMarkers() {
    sosMarkers.forEach(marker => map.removeLayer(marker));
    sosMarkers.clear();
    knownEmergencies.clear();
}

function removeEmergencyMarker(emergencyID) {
    if (sosMarkers.has(emergencyID)) {
        let marker = sosMarkers.get(emergencyID);
        map.removeLayer(marker);
        sosMarkers.delete(emergencyID);
        knownEmergencies.delete(emergencyID);
    }
}

function removeInactiveEmergencyMarkers(activeEmergencies) {
    for (let emergencyID of sosMarkers.keys()) {
        if (!activeEmergencies.has(emergencyID)) {
            removeEmergencyMarker(emergencyID);
        }
    }
}


//End Emergencies