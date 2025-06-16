let sosMarkers = new Map();

let responderTypes = [];
let responderType = null;
let responderTypeLabel = null;


//Emergencies
function loadEmergencyLocationsRealtime() {
    const emergenciesRef = firebase.database().ref("emergencies");
    const usersRef = firebase.database().ref("users");

    emergenciesRef.on("value", async (snapshot) => {
        if (!snapshot.exists()) {
            clearAllEmergencyMarkers();
            return;
        }

        const emergenciesData = snapshot.val();
        let activeEmergencies = new Set();

        for (const [emergencyID, emergency] of Object.entries(emergenciesData)) {
            if (!emergency.user_ID) continue;

            if (emergency.responder_Status === "Done") {
                removeEmergencyMarker(emergencyID);
                continue;
            }

            if (!["Pending", "Responding", "Assigning"].includes(emergency.report_Status)) continue;

            try {
                const userSnapshot = await usersRef.child(emergency.user_ID).once("value");
                const userData = userSnapshot.exists() ? userSnapshot.val() : {};


            
                responderTypes = [];
                responderType = null;
                responderTypeLabel = null;

                if (emergency.responder_ID) {
                    let responderIDs = [];

                    if (typeof emergency.responder_ID === "string" && emergency.responder_ID.trim() !== "") {
                        responderIDs = emergency.responder_ID.split(",").map(id => id.trim()).filter(Boolean);
                        console.log("📦 Parsed responder_ID as string:", responderIDs);
                    } else if (Array.isArray(emergency.responder_ID)) {
                        responderIDs = emergency.responder_ID.filter(Boolean);
                        console.log("📦 Parsed responder_ID as array:", responderIDs);
                    } else if (typeof emergency.responder_ID === "object" && emergency.responder_ID !== null) {
                        responderIDs = Object.values(emergency.responder_ID).filter(Boolean);
                        console.log("📦 Parsed responder_ID as object:", emergency.responder_ID, "→", responderIDs);
                    } else {
                        console.log("🚫 No valid responder_ID structure found for:", emergency.responder_ID);
                    }

                    if (responderIDs.length > 0) {
                        for (const id of responderIDs) {
                            try {
                                const responderSnap = await usersRef.child(id).once("value");
                                if (responderSnap.exists()) {
                                    const type = responderSnap.val().responder_type;
                                    if (type && !responderTypes.includes(type)) {
                                        responderTypes.push(type);
                                        console.log(`✅ Fetched responder [${id}] with type:`, type);
                                    }
                                }
                            } catch (err) {
                                console.warn(`⚠️ Error fetching responder ${id}`, err);
                            }
                        }

                        const priority = ['PNP', 'BFP', 'TaRSIER Responder', 'MDRRMO', 'Coast Guard'];
                        responderType = priority.find(type => responderTypes.includes(type)) || responderTypes[0] || null;
                        responderTypeLabel = responderTypes.join(" + ");

                        console.log("📊 Unique responder types collected:", responderTypes);
                        console.log("🏷️ Final Responder Type:", responderType);
                        console.log("🏷️ Responder Type Label:", responderTypeLabel);
                    } else {
                        console.warn("⚠️ Skipping responder type assignment — no valid responder IDs.");
                    }
                }
            

                const newLat = emergency.live_es_latitude;
                const newLng = emergency.live_es_longitude;

                const emergencyData = {
                    lat: newLat,
                    lng: newLng,
                    location: emergency.location,
                    status: emergency.report_Status,
                    responderStatus: emergency.responder_Status,
                    date_time: emergency.date_time,
                    userType: emergency.is_User,
                    emergencyID: emergency.report_ID,
                    responderType: responderType,       
                    responderTypeLabel: responderTypeLabel,
                    user_ID: emergency.user_ID,
                    user: {
                        fullname: userData.f_name && userData.l_name
                            ? `${userData.f_name} ${userData.l_name}`
                            : "Unknown",
                        contact: userData.user_contact || "N/A",
                        email: userData.email || "N/A"
                    }
                };

                activeEmergencies.add(emergencyID);

                if (!knownEmergencies.has(emergencyID)) {
                    knownEmergencies.set(emergencyID, emergencyData);
                    addSOSMarker(emergencyData);
                    playAlarm();
                } else {
                    const existingData = knownEmergencies.get(emergencyID);

                    const hasChanged = (
                        existingData.lat !== newLat ||
                        existingData.lng !== newLng ||
                        existingData.location !== emergency.location ||
                        existingData.status !== emergency.report_Status ||
                        existingData.responderStatus !== emergency.responder_Status ||
                        existingData.date_time !== emergency.date_time ||
                        existingData.user.fullname !== emergencyData.user.fullname ||
                        existingData.user.contact !== emergencyData.user.contact ||
                        existingData.user.email !== emergencyData.user.email ||
                        existingData.responderType !== emergencyData.responderType // ✅ check if responder type changed
                    );

                    if (hasChanged) {
                        console.log(`🔄 Updating marker for Emergency ID: ${emergencyID}`);

                        if (existingData.lat !== newLat || existingData.lng !== newLng) {
                            console.log(`📍 Moving marker for Emergency ID: ${emergencyID}`);
                            updateSOSMarker(emergencyID, newLat, newLng);
                        }

                        updateSOSMarkerInfo(emergencyID, emergencyData);
                        knownEmergencies.set(emergencyID, emergencyData);
                    }
                }

            } catch (error) {
                console.error(`❌ Error processing emergency ID ${emergencyID}:`, error);
            }
        }

        removeInactiveEmergencyMarkers(activeEmergencies);
    }, (error) => {
        console.error("❌ Error fetching emergencies:", error);
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
                    fullname: `${userData.f_name} ${userData.l_name}`,
                    contact: userData.user_contact || "N/A",
                    email: userData.email || "N/A"
                },
                user_ID: emergency.user_ID
            };

            if (sosMarkers.has(emergencyID)) {
                const marker = sosMarkers.get(emergencyID);
                marker.setLatLng([updatedEmergencyData.lat, updatedEmergencyData.lng]);
                marker.setPopupContent(getEmergencyInfoContent(updatedEmergencyData));
                marker.status = updatedEmergencyData.status;
                knownEmergencies.set(emergencyID, updatedEmergencyData);
            }
        } catch (err) {
            console.error("❌ Error updating emergency marker:", err);
        }
    }, error => {
        console.error("❌ Error listening to emergency updates:", error);
    });
}


function removeEmergencyMarker(emergencyID) {
    if (sosMarkers.has(emergencyID)) {
        let marker = sosMarkers.get(emergencyID);
        map.removeLayer(marker);
        sosMarkers.delete(emergencyID);
        knownEmergencies.delete(emergencyID);
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
        map.removeLayer(marker);
    }
    sosMarkers.clear();
    knownEmergencies.clear();
    console.log("🗑 Cleared all emergency markers.");
}


// Function to generate info window content
function getEmergencyInfoContent(emergency) {
    let actionButton = ""; 

    if (emergency.status === "Responding" || emergency.status === "Assigning") {
        actionButton = `
            <button onclick="fetchEmergencyDetails('${emergency.emergencyID}')"
                style="background: #ffc107; color: black; border: none; padding: 5px 10px; margin: 5px; cursor: pointer;">
                Edit Ticket
            </button>`;
    } else {
        actionButton = `
            <button onclick="fetchEmergencyDetails('${emergency.emergencyID}')"
                style="background: #007bff; color: white; border: none; padding: 5px 10px; margin: 5px; cursor: pointer;">
                Create Ticket
            </button>`;
    }

    return `
        <div style="text-align: center; padding: 10px; max-width: 250px;">
            <strong style="color: red; font-size: 18px;">🚨 SOS Emergency</strong><br>
            <hr style="margin: 5px 0;">
            <strong>📍 Location:</strong> ${emergency.location || "Unknown"}<br>
            <strong>📌 Status:</strong> <span id="status-${emergency.emergencyID}">${emergency.status || "Unknown"}</span><br>
            <strong>⏳ Reported:</strong> ${formatDateTime(emergency.date_time)}<br> 
            <strong>👤 User Type:</strong> ${emergency.userType || "Unknown"}<br>
            <strong>👮 Responder Type:</strong> ${emergency.responderTypeLabel || "None"}<br>

            <hr style="margin: 5px 0;">
            <strong>🙍‍♂️ Reported By:</strong> ${emergency.user.fullname || "Unknown"}<br>
            <strong>📞 Contact:</strong> ${emergency.user.contact || "N/A"}<br>
            <strong>📧 Email:</strong> ${emergency.user.email || "N/A"}<br>

            ${actionButton}

            <button onclick="handleCallButtonClick('${emergency.user_ID}')"
                style="background: #dc3545; color: white; border: none; padding: 5px 10px; margin: 5px; cursor: pointer;">
                Call Now
            </button>
        </div>`;
}


function addSOSMarker(emergency) {
    const { lat, lng, status, emergencyID, responderType } = emergency;

    // Color mapping
    const typeColorMap = {
        'PNP': '#007bff',
        'BFP': '#dc3545',
        'MDRRMO': '#28a745',
        'Coast Guard': '#fd7e14',
        'TaRSIER Responder': '#0e1a73'
    };

    // Use red for pending, or lookup from responderType
    const color = status === "Pending"
        ? '#e60000'
        : (typeColorMap[responderType] || '#6c757d'); // Fallback to gray

    const delay = Math.floor(Math.random() * 1500);

    const sosIcon = L.divIcon({
        className: '',
        html: `
            <div class="sos-marker-wrapper">
                <div class="sos-marker-pulse" style="
                    background: ${hexToRGBA(color, 0.3)};
                    border-color: ${hexToRGBA(color, 0.6)};
                    animation-delay: ${delay}ms;
                "></div>
                <div class="sos-marker-core" style="
                    background: ${color};
                    box-shadow: 0 0 10px ${color};
                "></div>
            </div>
        `,
        iconSize: [30, 30],
        iconAnchor: [15, 15]
    });

    let marker;
    if (sosMarkers.has(emergencyID)) {
        marker = sosMarkers.get(emergencyID);
        marker.setLatLng([lat, lng]);
        marker.setPopupContent(getEmergencyInfoContent(emergency));
        marker.setIcon(sosIcon);
        marker.status = status;
    } else {
        marker = L.marker([lat, lng], { icon: sosIcon })
            .addTo(map)
            .bindPopup(getEmergencyInfoContent(emergency));

        marker.status = status;
        sosMarkers.set(emergencyID, marker);
    }
}

function hexToRGBA(hex, alpha = 1) {
    const bigint = parseInt(hex.replace('#', ''), 16);
    const r = (bigint >> 16) & 255;
    const g = (bigint >> 8) & 255;
    const b = bigint & 255;
    return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}


function updateSOSMarkerInfo(emergencyID, emergencyData) {
    const marker = sosMarkers.get(emergencyID);
    if (!marker) return;

    const { lat, lng, status, responderType } = emergencyData;

    // Define new color based on updated type/status
    const typeColorMap = {
        'PNP': '#007bff',
        'BFP': '#dc3545',
        'MDRRMO': '#28a745',
        'Coast Guard': '#fd7e14',
        'TaRSIER Responder': '#0e1a73',
    };

    const color = status === "Pending"
        ? '#e60000'
        : (typeColorMap[responderType] || '#6c757d');

    const delay = Math.floor(Math.random() * 1500);

    const updatedIcon = L.divIcon({
        className: '',
        html: `
            <div class="sos-marker-wrapper">
                <div class="sos-marker-pulse" style="
                    background: ${hexToRGBA(color, 0.3)};
                    border-color: ${hexToRGBA(color, 0.6)};
                    animation-delay: ${delay}ms;
                "></div>
                <div class="sos-marker-core" style="
                    background: ${color};
                    box-shadow: 0 0 10px ${color};
                "></div>
            </div>
        `,
        iconSize: [30, 30],
        iconAnchor: [15, 15]
    });

    // Update marker position, popup content, and icon color
    marker.setLatLng([lat, lng]);
    marker.setPopupContent(getEmergencyInfoContent(emergencyData));
    marker.setIcon(updatedIcon);
    marker.status = status;
}

//End Emergencies