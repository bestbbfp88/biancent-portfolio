const responderDataMap = {};
const unitDataMap = {};

function loadEmergencyRespondersRealtime() {
    firebase.auth().onAuthStateChanged(currentUser => {
        if (!currentUser) {
            console.warn("⚠️ User not authenticated.");
            return;
        }

        const userUID = currentUser.uid;
        console.log("✅ Authenticated UID:", userUID);

        const unitsRef = firebase.database().ref("responder_unit");
        const respondersRef = firebase.database().ref("users");

        unitsRef.on("value", unitsSnapshot => {
            const unitsData = unitsSnapshot.val();
            if (!unitsData) {
                console.warn("⚠️ No responder units found.");
                return;
            }

            Object.entries(unitsData).forEach(([unitID, unit]) => {
                if ((unit.unit_Status === "Active" || unit.unit_Status === "Responding") && unit.station_ID === userUID) {
                    unitDataMap[unit.ER_ID] = {
                        unit_ID: unitID,
                        unit_Name: unit.unit_Name,
                        unit_Assign: unit.unit_Assign,
                        unit_Status: unit.unit_Status,
                        station_ID: unit.station_ID || null,
                        lat: parseFloat(unit.latitude),
                        lng: parseFloat(unit.longitude)
                    };
                }
            });

            syncMarkers();
        });

        respondersRef.on("value", respondersSnapshot => {
            const respondersData = respondersSnapshot.val();
            if (!respondersData) {
                console.warn("🚫 No responders found.");
                return;
            }

            Object.entries(respondersData).forEach(([responderID, responder]) => {
                if (responder.user_role === "Emergency Responder" && responder.location_status === "Active" && responder.created_by === userUID) {
                    responderDataMap[responderID] = {
                        responder_ID: responderID,
                        f_name: responder.f_name,
                        l_name: responder.l_name,
                        user_contact: responder.user_contact,
                        email: responder.email,
                        responder_type: responder.responder_type,
                        station_ID: responder.station_id,
                        location_status: responder.location_status,
                        timestamp: responder.timestamp
                    };
                }
            });

            syncMarkers();
        });
    });
}

function syncMarkers() {
    const displayedResponderIDs = new Set();

    Object.keys(unitDataMap).forEach(unitID => {
        const unit = unitDataMap[unitID];
        const responder = responderDataMap[unitID];

        if (!responder || responder.location_status !== "Active") return;

        if (isValidLatLng(unit.lat, unit.lng)) {
            addOrUpdateResponderMarker({
                responderID: unitID,
                lat: unit.lat,
                lng: unit.lng,
                name: `${responder.f_name || "Unknown"} ${responder.l_name || ""}`,
                contact: responder.user_contact || "N/A",
                email: responder.email || "N/A",
                responderType: responder.responder_type || "N/A",
                stationID: unit.station_ID || responder.station_ID || "N/A",
                timestamp: responder.timestamp || "N/A",
                unitName: unit.unit_Name || "N/A",
                unitAssign: unit.unit_Assign || "N/A",
                unitStatus: unit.unit_Status || "N/A"
            });

            displayedResponderIDs.add(unitID);
        }
    });

    Object.keys(responderMarkers).forEach(responderID => {
        if (!displayedResponderIDs.has(responderID)) {
            map.removeLayer(responderMarkers[responderID]);
            delete responderMarkers[responderID];
        }
    });
}

function addOrUpdateResponderMarker(responder) {
    const {
        lat, lng, name, contact, email, responderType, responderID,
        stationID, timestamp, unitName, unitAssign, unitStatus
    } = responder;

    if (responderMarkers[responderID]) {
        responderMarkers[responderID].setLatLng([lat, lng]);
        return;
    }

    let responderIconUrl = "../images/default_marker.png";
    if (responderType === "PNP") responderIconUrl = "../images/POLICE.gif";
    else if (responderType === "BFP") responderIconUrl = "../images/firetruck.gif";
    else if (responderType === "MDRRMO") responderIconUrl = "../images/ambulance.gif";
    else if (responderType === "Coast Guard") responderIconUrl = "../images/COASTGUARD.gif";
    else if (responderType === "TaRSIER Responder") responderIconUrl = "../images/TARSIER.gif";

    const icon = L.icon({
        iconUrl: responderIconUrl,
        iconSize: [45, 45],
        iconAnchor: [22, 45],
        className: '' // avoid canvas rendering
    });

    const marker = L.marker([lat, lng], {
        icon: icon,
        title: `Responder: ${name}`
    }).addTo(map);

    const popupContent = `
        <div style="text-align: center; padding: 10px; max-width: 300px;">
            <strong style="color: green; font-size: 18px;">🚑 Emergency Responder</strong><br>
            <hr style="margin: 5px 0;">
            <strong>🚨 Unit Name:</strong> ${unitName}<br>
            <strong>🔧 Unit Assign:</strong> ${unitAssign}<br>
            <strong>✅ Unit Status:</strong> ${unitStatus}<br>
            <strong>📞 Contact:</strong> ${contact}<br>
            <strong>🏢 Station ID:</strong> ${stationID}<br>
        </div>`;

    marker.bindPopup(popupContent);

    responderMarkers[responderID] = marker;
}

function animateMarkerMovement(marker, newLat, newLng) {
    const currentLatLng = marker.getLatLng();
    const currentLat = currentLatLng.lat;
    const currentLng = currentLatLng.lng;

    const steps = 30;
    let step = 0;

    const interval = setInterval(() => {
        step++;
        const lat = currentLat + (newLat - currentLat) * (step / steps);
        const lng = currentLng + (newLng - currentLng) * (step / steps);

        marker.setLatLng([lat, lng]);

        if (step === steps) {
            clearInterval(interval);
        }
    }, 50); // Adjust animation speed here
}
