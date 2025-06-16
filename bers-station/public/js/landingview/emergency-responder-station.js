const stationMarkers = [];

function loadEmergencyResponderStationsRealtime() {
    console.log("🚀 Waiting for Firebase auth state...");

    firebase.auth().onAuthStateChanged(user => {
        if (!user) {
            console.warn("⚠️ User not authenticated.");
            return;
        }

        const userUID = user.uid;
        console.log(`✅ Authenticated as UID: ${userUID}`);

        const usersRef = firebase.database().ref(`users/${userUID}`);

        usersRef.once("value")
            .then(snapshot => {
                const userData = snapshot.val();
                console.log("📦 User data from Firebase:", userData);

                if (!userData || userData.user_role !== "Emergency Responder Station" || userData.user_status !== "Active") {
                    console.warn("⚠️ User is not an active Emergency Responder Station.");
                    return;
                }

                const stationID = userData.station_id;
                if (!stationID) {
                    console.warn("⚠️ No station_id found for current user.");
                    return;
                }

                console.log(`📌 Station ID: ${stationID}`);
                fetchStationDetails(stationID, userData);
            })
            .catch(error => {
                console.error("❌ Error fetching user data:", error);
            });
    });
}

function fetchStationDetails(stationID, user) {
    console.log(`📡 fetchStationDetails() called for stationID: ${stationID}`);

    const stationRef = firebase.database().ref(`emergency_responder_station/${stationID}`);

    stationRef.once("value", snapshot => {
        const stationData = snapshot.val();
        console.log("🏢 Station data from Firebase:", stationData);

        if (!stationData) {
            console.warn(`⚠️ No station data found for ID: ${stationID}`);
            return;
        }

        const lat = parseFloat(stationData.latitude);
        const lng = parseFloat(stationData.longitude);

        console.log(`📍 Parsed coordinates - lat: ${lat}, lng: ${lng}`);

        if (!isValidLatLng(lat, lng)) {
            console.error(`❌ Invalid coordinates for station: ${stationID}`, stationData);
            return;
        }

        addResponderStationMarker({
            stationID,
            lat,
            lng,
            stationName: stationData.station_name,
            stationType: stationData.station_type,
            email: user.email,
            contact: user.user_contact
        });
    }, error => {
        console.error(`❌ Error fetching station details for stationID: ${stationID}`, error);
    });
}

function addResponderStationMarker(station) {
    const { lat, lng, stationName, stationType, stationID, email, contact, status } = station;

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

    const marker = L.marker([lat, lng], { icon: icon, title: `Station: ${stationName}` }).addTo(map);

    const popupContent = `
        <div style="text-align: center; padding: 10px; max-width: 250px;">
            <strong style="color: blue; font-size: 18px;">🏢 Emergency Responder Station</strong><br>
            <hr style="margin: 5px 0;">
            <strong>🏠 Name:</strong> ${stationName}<br>
            <strong>🚓 Type:</strong> ${stationType}<br>
            <strong>📍 Location:</strong> (${lat}, ${lng})<br>
            <strong>📞 Contact:</strong> ${contact || "N/A"}<br>
            <strong>📧 Email:</strong> ${email || "N/A"}<br>
            <strong>🏢 Station ID:</strong> ${stationID}<br>
        </div>`;

    marker.bindPopup(popupContent);
    stationMarkers.push(marker);

    console.log("✅ Responder station marker added to Leaflet map");
}
