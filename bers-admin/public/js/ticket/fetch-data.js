let tarsierResponders = [];
let emergencyLocation = null;

function fetchEmergencyDetails(emergencyID) {
    const emergenciesRef = firebase.database().ref(`emergencies/${emergencyID}`);

    window.currentEmergencyID = emergencyID;

    emergenciesRef.once("value", async (snapshot) => {
        if (!snapshot.exists()) {
            console.error("❌ Emergency report not found!");
            return;
        }

        const emergencyData = snapshot.val();
        const userID = emergencyData.user_ID;
        const ticketID = emergencyData.dispatch_ID; 

        if (!userID) {
            console.error("❌ No user ID associated with this emergency.");
            return;
        }

        emergencyLocation = { 
            lat: parseFloat(emergencyData.live_es_latitude), 
            lng: parseFloat(emergencyData.live_es_longitude) 
        };

    //    assignNearestStation(emergencyLocation.lat, emergencyLocation.lng);
        loadTarsierResponders(emergencyLocation.lat, emergencyLocation.lng);

        try {
            const userSnapshot = await firebase.database().ref(`users/${userID}`).once("value");

            if (userSnapshot.exists()) {
                const userData = userSnapshot.val();

                userData.fullName = userData.f_name && userData.l_name
                    ? `${userData.f_name.trim()} ${userData.l_name.trim()}`
                    : "Unknown";

                if (ticketID) {
                    const ticketSnapshot = await firebase.database().ref(`tickets/${ticketID}`).once("value");

                    if (ticketSnapshot.exists()) {
                        const ticketData = ticketSnapshot.val();
                        emergencyData.emergencyID = emergencyID;
                       
                        createTicket(emergencyData, userData, ticketData, ticketID);
                    } else {
                        console.warn(`⚠️ Ticket ID found but no ticket data exists: ${ticketID}`);
                    }
                } else {
                    console.log("ℹ️ No ticket exists for this emergency. Creating a new one...");
                    emergencyData.emergencyID = emergencyID;
                    
                    createTicket(emergencyData, userData, {}, ""); // Empty ticketData
                }

                let modalElement = document.getElementById("createTicketModal");
                modalElement.setAttribute("data-user-id", userID);
                if (modalElement) {
                    modalElement.setAttribute("data-emergency-id", emergencyID);
                } 
            } 
        } catch (error) {
            console.error(`❌ Error fetching user data for user_ID: ${userID}`, error);
        }
    });
}


function loadEmergencyResponderStations() {
    const userRef = firebase.database().ref("users");
    const stationRef = firebase.database().ref("emergency_responder_station");

    responderStations = []; // ✅ Clear on every load
    const addedSet = new Set(); // ✅ Track duplicates

    userRef.once("value", userSnapshot => {
        let userStationMap = [];

        userSnapshot.forEach(childSnapshot => {
            const user = childSnapshot.val();
            if (user.user_role === "Emergency Responder Station" && user.station_id) {
                userStationMap.push({
                    user_id: childSnapshot.key,
                    station_id: user.station_id
                });
            }
        });

        if (userStationMap.length === 0) {
            console.warn("⚠️ No users found with role 'Emergency Responder Station'!");
            return;
        }

        stationRef.once("value", stationSnapshot => {
            stationSnapshot.forEach(childSnapshot => {
                const station = childSnapshot.val();
                const stationId = childSnapshot.key;

                let matchedUsers = userStationMap.filter(user => user.station_id === stationId);

                matchedUsers.forEach(user => {
                    const uniqueKey = `${user.user_id}-${stationId}`;
                    if (
                        station.latitude &&
                        station.longitude &&
                        station.station_type &&
                        !addedSet.has(uniqueKey)
                    ) {
                        responderStations.push({
                            user_id: user.user_id,
                            station_id: stationId,
                            station_name: station.station_name,
                            lat: parseFloat(station.latitude),
                            lng: parseFloat(station.longitude),
                            station_type: station.station_type
                        });
                        addedSet.add(uniqueKey);
                    }
                });
            });
        });
    });
}

function loadTarsierResponders(lat, lng) {

    if (!lat || !lng || isNaN(lat) || isNaN(lng)) {
        console.error("❌ Error: Invalid emergency location provided! Cannot calculate distances.");
        return;
    }

    const userRef = firebase.database().ref("users");

    userRef.once("value").then(snapshot => {
        tarsierResponders = []; // Clear previous data

        snapshot.forEach(childSnapshot => {
            const user = childSnapshot.val();
            if (user.user_role === "Emergency Responder" && 
                user.responder_type === "TaRSIER Responder" && 
                user.location_status === "Active") {

                tarsierResponders.push({
                    user_id: childSnapshot.key,
                    name: `${user.f_name} ${user.l_name}`,
                    lat: parseFloat(user.latitude),
                    lng: parseFloat(user.longitude),
                    contact: user.user_contact,
                    email: user.email
                });
            }
        });

        if (tarsierResponders.length === 0) {
            console.warn("⚠️ No active TaRSIER responders found!");
            return;
        }

        updateDropdownWithTarsier(lat, lng);
    }).catch(error => {
        console.error("❌ Error fetching TaRSIER responders:", error);
    });
}
