// Maps to store responder and unit data
const responderDataMap = {};
const unitDataMap = {};
const stationDataMap = {}; 
const stationUserMap = {};   
const distressStatusCache = new Map();

function loadEmergencyRespondersRealtime() {
    const unitsRef = firebase.database().ref("responder_unit");
    const respondersRef = firebase.database().ref("users");

    unitsRef.on("value", unitsSnapshot => {
        const unitsData = unitsSnapshot.val();
        if (!unitsData) {
            console.warn("⚠️ No units found.");
            return;
        }

        // Update unit data map
        Object.entries(unitsData).forEach(([unitID, unit]) => {
            if (unit.unit_Status === "Active" || unit.unit_Status === "Responding" || unit.unit_Status === "Emergency") {
                unitDataMap[unit.ER_ID] = {
                    unit_ID: unitID,
                    unit_Name: unit.unit_Name,
                    unit_Assign: unit.unit_Assign,
                    unit_Status: unit.unit_Status,
                    station_ID: unit.station_ID || null,
                    lat: unit.latitude ? parseFloat(unit.latitude) : NaN,
                    lng: unit.longitude ? parseFloat(unit.longitude) : NaN,
                    isDistressed: unit.unit_Status === "Emergency"
                };

                console.log(`🔥 Real-time status update: ${unit.unit_Name} → ${unit.unit_Status}`);
            } else {
                delete unitDataMap[unit.ER_ID];
            }
            
        });

        // ✅ Sync markers after units update
        syncMarkers();
    });

    // ✅ Listen to `users` collection in real-time for responder details
    respondersRef.on("value", respondersSnapshot => {
        const respondersData = respondersSnapshot.val();
        if (!respondersData) {
            console.warn("🚫 No responders found.");
            return;
        }

        // Update responder data map
        Object.entries(respondersData).forEach(([responderID, responder]) => {
            // ✅ Only store responders with `location_status: Active`
            if (responder.user_role === "Emergency Responder" && responder.location_status === "Active") {
                responderDataMap[responderID] = {
                    responder_ID: responderID,
                    f_name: responder.f_name,
                    l_name: responder.l_name,
                    user_contact: responder.user_contact,
                    email: responder.email,
                    responder_type: responder.responder_type,
                    station_ID: responder.station_id,
                    location_status: responder.location_status,  // ✅ Ensure it's "Active"
                    timestamp: responder.timestamp
                };
            } else {
                // Remove inactive responders
                delete responderDataMap[responderID];
            }
        });
        
        firebase.database().ref("users").on("value", snapshot => {
            console.log("📥 Fetching users...");
        
            snapshot.forEach(childSnapshot => {
                const userID = childSnapshot.key;
                const userData = childSnapshot.val();
        
                // Debug log for each user
                console.log(`👤 User Loaded: ${userID}`, userData);
        
                if (userData.user_role === "Emergency Responder Station") {
                    stationUserMap[userID] = userData.station_id;
                    console.log(`✅ Station User Mapped: ${userID} ➜ station_id: ${userData.station_id}`);
                }
            });
        
            console.log("📦 Final stationUserMap:", stationUserMap);
        
            // Fetch emergency responder station data
            firebase.database().ref("emergency_responder_station").on("value", snapshot => {
                console.log("📥 Fetching emergency_responder_station data...");
        
                snapshot.forEach(childSnapshot => {
                    const stationID = childSnapshot.key;
                    const stationData = childSnapshot.val();
        
                    stationDataMap[stationID] = stationData;
        
                    console.log(`🏥 Station Loaded: ${stationID}`, stationData);
                });
        
                console.log("📦 Final stationDataMap:", stationDataMap);
        
                // Call syncMarkers
                console.log("🚀 Calling syncMarkers...");
                syncMarkers();
            });
        });


    });
}

function syncMarkers() {
    console.log("Markers");
    const displayedResponderIDs = new Set();

    Object.keys(unitDataMap).forEach(unitID => {
        const unit = unitDataMap[unitID];
        const responder = responderDataMap[unitID];

        if (!responder || responder.location_status !== "Active") return;
        

        if (isValidLatLng(unit.lat, unit.lng)) {
            // Step 1: Get the station user ID
            const stationUserID = unit.station_ID || responder.station_ID;

            // Step 2: Use it to get the actual station_ID
            const actualStationID = stationUserMap[stationUserID];

            // Step 3: Use the station_ID to get the station name
            const stationName = stationDataMap[actualStationID]?.station_name || "N/A";

            console.log(`📍 Marker for ${responder.f_name} from station ${stationUserID} ➜ ${actualStationID} ➜ ${stationName}`);

            addOrUpdateResponderMarker({
                responderID: unitID,
                lat: unit.lat,
                lng: unit.lng,
                name: `${responder.f_name || "Unknown"} ${responder.l_name || ""}`,
                contact: responder.user_contact || "N/A",
                email: responder.email || "N/A",
                responderType: responder.responder_type || "N/A",
                stationID: stationName,
                timestamp: responder.timestamp || "N/A",
                unitName: unit.unit_Name || "N/A",
                unitAssign: unit.unit_Assign || "N/A",
                unitStatus: unit.unit_Status || "N/A",
                isDistressed: unit.isDistressed || false // 👈 Add this
            });
            

            displayedResponderIDs.add(unitID);
        }
    });

    // Remove inactive markers
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
        stationID, timestamp, unitName, unitAssign, unitStatus, isDistressed
      } = responder;      

    // 🔄 If marker already exists, update its location
    if (responderMarkers[responderID]) {
        const existingMarker = responderMarkers[responderID];
        const wasDistressed = distressStatusCache.get(responderID); // Get last known status
      
        if (wasDistressed !== isDistressed) {
          console.log(`🔔 Status changed for ${responderID}: ${wasDistressed} → ${isDistressed}`);
          
          // ✅ Play sound only on actual status change
          if (isDistressed) {
            new Audio('/audio/distress.mp3').play();
          } 
          // 💾 Update cache
          distressStatusCache.set(responderID, isDistressed);
      
          // 🔄 Replace marker
          map.removeLayer(existingMarker);
          delete responderMarkers[responderID];
        } else {
          // Just location changed
          existingMarker.setLatLng([lat, lng]);
          return;
        }
      }
      
      

    // 🖼️ Select custom icon based on responder type
    let responderIconUrl = "../images/default_marker.png";
    if (responderType === "PNP") responderIconUrl = "../images/POLICE.gif";
    else if (responderType === "BFP") responderIconUrl = "../images/firetruck.gif";
    else if (responderType === "MDRRMO") responderIconUrl = "../images/ambulance.gif";
    else if (responderType === "Coast Guard") responderIconUrl = "../images/COASTGUARD.gif";
    else if (responderType === "TaRSIER Responder") responderIconUrl = "../images/TARSIER.gif";

    const iconHtml = isDistressed
    ? `
        <div class="pulse-wrapper">
        <div class="pulse-circle"></div>
        <img src="${responderIconUrl}" style="width: 45px; height: 45px;" />
        </div>
    `
    : `<img src="${responderIconUrl}" style="width: 45px; height: 45px;" />`;

    const icon = L.divIcon({
    html: iconHtml,
    className: '', // Prevent default Leaflet styles
    iconSize: [50, 50],
    iconAnchor: [22, 45],
    });


    const popupContent = `
        <div style="text-align: center; padding: 10px; max-width: 300px;">
            <strong style="color: green; font-size: 18px;">🚑 Emergency Responder</strong><br>
            ${isDistressed ? '<div style="color: red; font-weight: bold; margin-top: 6px;">🚨 UNIT IN DISTRESS!</div>' : ''}
            <hr style="margin: 5px 0;">
            <strong>🚨 Unit Name:</strong> ${unitName}<br>
            <strong>🔧 Unit Assign:</strong> ${unitAssign}<br>
            <strong>✅ Unit Status:</strong> ${unitStatus}<br>
            <strong>📞 Contact:</strong> ${contact}<br>
            <strong>🏢 Station ID:</strong> ${stationID}<br>
        </div>`;
  

    const marker = L.marker([lat, lng], { icon })
        .addTo(map)
        .bindPopup(popupContent);

    marker.responderType = responderType;
    responderMarkers[responderID] = marker;
}


