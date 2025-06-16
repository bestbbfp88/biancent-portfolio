//Emergency Responder Station

const stationMarkers = [];

function loadEmergencyResponderStationsRealtime() {
    const usersRef = firebase.database().ref("users");

    usersRef.on("value", snapshot => {
        const data = snapshot.val();
        if (!data) return;

        Object.entries(data).forEach(([userID, user]) => {
            if (user.user_role === "Emergency Responder Station" && user.user_status === "Active") {
                const stationID = user.station_id;
                if (stationID) {
                    fetchStationDetails(stationID, { ...user, uid: userID }); // ✅ Pass UID along
                }
            }
        });
        
    }, error => {
        console.error("❌ Error fetching emergency responder stations:", error);
    });
}


function fetchStationDetails(stationID, user) {
    const stationRef = firebase.database().ref(`emergency_responder_station/${stationID}`);

    stationRef.once("value", async snapshot => {
        const stationData = snapshot.val();
        if (!stationData) return;

        const lat = parseFloat(stationData.latitude);
        const lng = parseFloat(stationData.longitude);

        if (!isValidLatLng(lat, lng)) {
            console.error(`❌ Invalid LatLng for station: ${stationID}`, stationData);
            return;
        }

        const stationUID = user.uid; // ✅ Use UID directly as the matching value
        console.log("User Id", stationUID);
        let activeCount = 0;
        let respondingCount = 0;

        try {
            const unitsSnapshot = await firebase.database().ref("responder_unit").once("value");
            const units = unitsSnapshot.val();

            if (units) {
                Object.values(units).forEach(unit => {
                    if (unit.station_ID === stationUID) {
                        if (unit.unit_Status === "Active") activeCount++;
                        if (unit.unit_Status === "Responding") respondingCount++;
                    }
                });
            }
        } catch (err) {
            console.error("❌ Error fetching responder units:", err);
        }

        addResponderStationMarker({
            stationID,
            lat,
            lng,
            stationName: stationData.station_name,
            stationType: stationData.station_type,
            email: user.email,
            contact: user.user_contact,
            activeUnits: activeCount,
            respondingUnits: respondingCount,
        });
    });
}


function addResponderStationMarker(station) {
    const { lat, lng, stationName, stationType, stationID, email, contact, status, activeUnits = 0, respondingUnits = 0 } = station;

    let stationIconUrl = "../images/default_station.png";
    if (stationType === "PNP") stationIconUrl = "../images/POLICE_STATION.png";
    else if (stationType === "BFP") stationIconUrl = "../images/FIRE_STATION.png";
    else if (stationType === "MDRRMO") stationIconUrl = "../images/AMBULANCE_STATION.png";
    else if (stationType === "Coast Guard") stationIconUrl = "../images/COASTGUARD_STATION.png";
    else if (stationType === "TaRSIER Unit") stationIconUrl = "../images/operations_center.png";

    const icon = L.icon({
        iconUrl: stationIconUrl,
        iconSize: [50, 50],
        iconAnchor: [25, 50]
    });

    const marker = L.marker([lat, lng], { icon })
        .bindPopup(`
            <div style="text-align: center; padding: 10px; max-width: 250px;">
                <strong style="color: blue; font-size: 18px;">🏢 Emergency Responder Station</strong><br>
                <hr style="margin: 5px 0;">
                <strong>🏠 Name:</strong> ${stationName}<br>
                <strong>🚓 Type:</strong> ${stationType}<br>
                <strong>📞 Contact:</strong> ${contact || "N/A"}<br>
                <strong>📧 Email:</strong> ${email || "N/A"}<br>
                <hr style="margin: 8px 0;">
                <strong>🟢 Active Units:</strong> ${activeUnits}<br>
                <strong>🟡 Responding Units:</strong> ${respondingUnits}<br>
            </div>
        `);

    marker.stationType = stationType;
    marker.stationStatus = status || "Active";

    stationMarkers.push(marker);

    const toggle = document.getElementById("stationToggleSwitch");
    if (stationType === "TaRSIER Unit" || (status === "Active" && toggle?.checked)) {
        marker.addTo(map);
    }
}



document.addEventListener("DOMContentLoaded", () => {
    const stationToggle = document.getElementById("stationToggleSwitch");
    const tarsierStationToggle = document.getElementById("tarsierToggleSwitch");
    const responderToggle = document.getElementById("responderToggleSwitch");
    const tarsierResponderToggle = document.getElementById("tarsierResponderToggleSwitch");

    // 📍 LGU Station Toggle
    stationToggle.addEventListener("change", () => {
        const show = stationToggle.checked;
        stationMarkers.forEach(marker => {
            if (marker.stationType !== "TaRSIER Unit") {
                if (show) marker.addTo(map);
                else map.removeLayer(marker);
            }
        });
    });

    // 📍 TaRSIER Station Toggle
    tarsierStationToggle.addEventListener("change", () => {
        const show = tarsierStationToggle.checked;
        stationMarkers.forEach(marker => {
            if (marker.stationType === "TaRSIER Unit") {
                if (show) marker.addTo(map);
                else map.removeLayer(marker);
            }
        });
    });

    // 🚨 LGU Responder Toggle
    responderToggle.addEventListener("change", () => {
        const show = responderToggle.checked;
        Object.values(responderMarkers).forEach(marker => {
            const isLGU = ["PNP", "BFP", "MDRRMO", "Coast Guard"].includes(marker.responderType);
            if (isLGU) {
                if (show) marker.addTo(map);
                else map.removeLayer(marker);
            }
        });
    });

    // 🚨 TaRSIER Responder Toggle
    tarsierResponderToggle.addEventListener("change", () => {
        const show = tarsierResponderToggle.checked;
        Object.values(responderMarkers).forEach(marker => {
            if (marker.responderType === "TaRSIER Responder") {
                if (show) marker.addTo(map);
                else map.removeLayer(marker);
            }
        });
    });
});


//End Emergency Responder Station
