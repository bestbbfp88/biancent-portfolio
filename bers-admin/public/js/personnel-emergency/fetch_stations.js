document.addEventListener("DOMContentLoaded", () => {
        console.log("✅ DOM Content Loaded");
    
        const stationSelect = document.getElementById("responderCreatedFor");
        console.log("📍 responderCreatedFor exists?", !!stationSelect);
    
        const addResponderModal = document.getElementById("addResponderModal");
        console.log("📦 addResponderModal exists?", !!addResponderModal);
    
        if (stationSelect) {
        stationSelect.innerHTML = `<option value="" disabled selected>Loading...</option>`;
        populateResponderStations();
        }

    async function populateResponderStations() {
    console.log("🚀 Starting populateResponderStations");

    const usersRef = db.ref("users");
    const stationSelect = document.getElementById("responderCreatedFor");

    if (!stationSelect) {
        console.warn("⚠️ 'responderCreatedFor' select element not found in DOM.");
        return;
    }

    try {
        console.log("🔍 Querying users with role = 'Emergency Responder Station'");
        const snapshot = await usersRef
        .orderByChild("user_role")
        .equalTo("Emergency Responder Station")
        .once("value");

        const promises = [];
        let userCount = 0;

        snapshot.forEach(userSnap => {
        const userId = userSnap.key;
        const userData = userSnap.val();
        const stationID = userData.station_id;

        console.log(`👤 Found station user: ${userId}`, userData);

        const stationInfoRef = db.ref("emergency_responder_station/" + stationID);
        const promise = stationInfoRef.once("value").then(stationSnap => {
            const stationData = stationSnap.val();

            if (stationData) {
            console.log(`🏥 Station info for user ${userId}:`, stationData);
            } else {
            console.warn(`⚠️ No station data found for user: ${userId}`);
            }

            if (stationData && stationData.station_name) {
            const option = document.createElement("option");
            option.value = userId;
            option.textContent = stationData.station_name;
            stationSelect.appendChild(option);
            console.log(`✅ Added option: ${stationData.station_name} (${userId})`);
            } else {
            console.warn(`⛔ Missing or invalid station name for: ${userId}`);
            }
        });

        promises.push(promise);
        userCount++;
        });

        console.log(`📦 Total station users found: ${userCount}`);
        await Promise.all(promises);
        console.log("✅ Finished populating station dropdown.");
    } catch (error) {
        console.error("❌ Error fetching or populating stations:", error);
    }
    }


    document.getElementById("responderCreatedFor").addEventListener("change", function () {
        const selectedValue = this.value;
        document.getElementById("selectedStationUID").value = selectedValue;
        console.log("📥 Hidden input updated with station UID:", selectedValue);
      });
      
});


