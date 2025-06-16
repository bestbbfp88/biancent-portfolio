let responderStations = []; 
let stationDropdownInitialized = false;

function assignNearestStation(lat, lng, preselectedStationIDs = []) {
    let emergencyType = document.getElementById("emergencyType").value;
    const mvcType = document.querySelector('input[name="mvcType"]:checked')?.value || "";

    if (!lat || !lng || isNaN(lat) || isNaN(lng)) {
        console.warn("⚠️ Invalid location for assigning nearest station", { lat, lng });
        return;
    }

    const dropdownMenu = document.getElementById("stationDropdownMenu");
    const stationDropdownButton = document.getElementById("stationDropdownButton");
    const nearestStationInput = document.getElementById("nearestStation");
    const distanceToStationInput = document.getElementById("distanceToStation");

    dropdownMenu.innerHTML = "";

    if (emergencyType === "Police") {
        getTownFromCoordinates(lat, lng, town => {
            console.log("📍 Resolved Town from Coordinates:", town || "❌ Not Found");
    
            if (!town) {
                console.warn("❌ Unable to determine town. Showing all PNP stations as fallback.");
                const fallbackStations = responderStations.filter(s => s.station_type === "PNP");
                console.log(`🛡️ Fallback PNP Stations Found: ${fallbackStations.length}`);
                continueAssign(fallbackStations);
            } else {
                const townStations = responderStations.filter(s =>
                    s.station_type === "PNP" &&
                    s.station_name.toLowerCase().includes(town.toLowerCase())
                );
    
                console.log(`🏙️ Matching PNP Stations for "${town}": ${townStations.length}`);
                
                if (townStations.length === 0) {
                    console.warn(`⚠️ No PNP stations matched for "${town}". Falling back to all.`);
                    const fallbackStations = responderStations.filter(s => s.station_type === "PNP");
                    console.log(`🛡️ Fallback PNP Stations Found: ${fallbackStations.length}`);
                    continueAssign(fallbackStations);
                } else {
                    continueAssign(townStations);
                }
            }
        });
        return;
    }
    
    const filteredStations = responderStations.filter(station => {
        if (emergencyType === "Medical") return station.station_type === "MDRRMO";
        if (emergencyType === "Fire") return station.station_type === "BFP";
        if (emergencyType === "Trauma") return station.station_type === "MDRRMO";
        if (emergencyType === "Police") return station.station_type === "PNP";
        if (emergencyType === "MVC") {
            if (mvcType === "For Extrication") {
                return station.station_type === "BFP" || station.station_type === "MDRRMO";
            } else {
                return station.station_type === "MDRRMO";
            }
        }
        return true; // Default fallback
    });
    

    continueAssign(filteredStations);

    async function continueAssign(filteredStations) {
        if (filteredStations.length === 0) return;
    
        const orsApiKey = "5b3ce3597851110001cf6248fea3c11e56ea4db28f82d1f7ef7a6b71"; // Replace with your actual ORS API key
        const originCoords = [lng, lat]; // ORS requires [lng, lat] format
        const destinations = filteredStations.map(s => [s.lng, s.lat]);
    
        try {
            const response = await fetch("https://api.openrouteservice.org/v2/matrix/driving-car", {
                method: "POST",
                headers: {
                    "Authorization": orsApiKey,
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    locations: [originCoords, ...destinations],
                    metrics: ["distance", "duration"],
                    units: "m"
                })
            });
    
            const data = await response.json();
            const results = data.distances[0].slice(1); // Skip the origin itself
    
            let stationsWithDistance = results.map((distance, index) => ({
                station: filteredStations[index],
                distanceValue: distance,
                distanceText: `${(distance / 1000).toFixed(2)} km`
            }));

            const seen = new Set();
            stationsWithDistance = stationsWithDistance.filter(entry => {
                const key = `${entry.station.station_name}-${entry.station.user_id}-${entry.distanceText}`;
                if (seen.has(key)) return false;
                seen.add(key);
                return true;
            });

    
            stationsWithDistance.sort((a, b) => a.distanceValue - b.distanceValue);
            const topStations = stationsWithDistance.slice(0, 10);
    
            // Populate Dropdown
            const noneOption = document.createElement("li");
            noneOption.innerHTML = `<label class="dropdown-item">
                <input type="checkbox" value="" class="station-checkbox"> None
            </label>`;
            dropdownMenu.appendChild(noneOption);
    
            topStations.forEach(entry => {
                const isChecked = preselectedStationIDs.includes(entry.station.user_id);
                const li = document.createElement("li");
                li.innerHTML = `<label class="dropdown-item">
                    <input type="checkbox" value="${entry.station.user_id}" class="station-checkbox"
                        data-name="${entry.station.station_name}" data-distance="${entry.distanceText}"
                        ${isChecked ? "checked" : ""}>
                    ${entry.station.station_name} - ${entry.distanceText}
                </label>`;
                dropdownMenu.appendChild(li);
            });
    
            // Attach change listener once
            if (!stationDropdownInitialized) {
                dropdownMenu.addEventListener("change", () => {
                    const selectedCheckboxes = document.querySelectorAll(".station-checkbox:checked");
                    const selectedIDs = [], selectedNames = [], selectedDistances = [];
    
                    selectedCheckboxes.forEach(cb => {
                        if (cb.value !== "") {
                            selectedIDs.push(cb.value);
                            selectedNames.push(cb.getAttribute("data-name"));
                            selectedDistances.push(`${cb.getAttribute("data-name")}: ${cb.getAttribute("data-distance")}`);
                        }
                    });
    
                    nearestStationInput.value = selectedIDs.join(",");
                    distanceToStationInput.value = selectedDistances.join(", ");
                    stationDropdownButton.textContent = selectedNames.length > 0
                        ? selectedNames.join(", ")
                        : "-- Select Station(s) --";
                });
                stationDropdownInitialized = true;
            }
    
            // Populate preselected values
            const preselectedNames = topStations
                .filter(entry => preselectedStationIDs.includes(entry.station.user_id))
                .map(entry => entry.station.station_name);
    
            const preselectedDistances = topStations
                .filter(entry => preselectedStationIDs.includes(entry.station.user_id))
                .map(entry => `${entry.station.station_name}: ${entry.distanceText}`);
    
            nearestStationInput.value = preselectedStationIDs.join(",");
            distanceToStationInput.value = preselectedDistances.join(", ");
            stationDropdownButton.textContent = preselectedNames.length > 0
                ? preselectedNames.join(", ")
                : "-- Select Station(s) --";
    
        } catch (error) {
            console.error("❌ ORS Matrix API error:", error);
        }
    }
    
}


function updateSelectedStations() {
    let checkboxes = document.querySelectorAll(".station-checkbox");
    let selectedStationIds = [];
    let selectedStationNames = [];
    let selectedDistances = [];

    checkboxes.forEach(checkbox => {
        if (checkbox.checked && checkbox.value !== "") {
            selectedStationIds.push(checkbox.value);
            selectedStationNames.push(checkbox.getAttribute("data-name")); 
            selectedDistances.push(`${checkbox.getAttribute("data-name")}: ${parseFloat(checkbox.getAttribute("data-distance")).toFixed(2)} km`);
        }
    });

    document.getElementById("nearestStation").value = selectedStationIds.join(",");

    let distanceInput = document.getElementById("distanceToStation");
    distanceInput.value = selectedDistances.length > 0 ? selectedDistances.join(", ") : "";

    updateDropdownButton(selectedStationNames);
}

function updateDropdownButton(selectedStationNames) {
    let dropdownButton = document.getElementById("stationDropdownButton");

    if (!dropdownButton) {
        return;
    }

    dropdownButton.textContent = selectedStationNames.length > 0 ? selectedStationNames.join(", ") : "-- Select Station(s) --";
}


async function recommendNearestEmergencyUnit(lat, lng) {
    const recommendedInput = document.getElementById("recommendedTaRSIER");

    console.log("🚀 recommendNearestEmergencyUnit called with:", { lat, lng });

    if (!lat || !lng || isNaN(lat) || isNaN(lng)) {
        console.warn("⚠️ Invalid location for recommending responder");
        recommendedInput.value = "No available responder";
        return;
    }

    const currentUser = firebase.auth().currentUser;
    if (!currentUser) {
        console.error("❌ No authenticated user.");
        recommendedInput.value = "No available responder";
        return;
    }

    const stationUID = currentUser.uid;
    const origin = [lng, lat];
    const destinations = [];
    const responderMap = [];

    try {
        const unitSnapshot = await firebase.database().ref("responder_unit").once("value");
        const units = unitSnapshot.val();

        console.log("📦 Loaded responder_unit entries:", units ? Object.keys(units).length : 0);

        if (!units) {
            console.warn("⚠️ No responder units found.");
            recommendedInput.value = "No available responder";
            return;
        }

        for (const unitID in units) {
            const unit = units[unitID];

            if (unit.station_ID !== stationUID) {
                console.log(`⏩ Skipping unit ${unitID} - station_ID does not match current user`);
                continue;
            }

            console.log(`🔎 Processing unit ${unitID}:`, unit);

            const erId = unit.ER_ID;
            const lat = unit.latitude;
            const lng = unit.longitude;

            if (!lat || !lng) {
                console.warn(`⚠️ Skipping unit ${unitID} due to missing coordinates.`);
                continue;
            }

            const userSnapshot = await firebase.database().ref(`users/${erId}`).once("value");

            if (!userSnapshot.exists()) {
                console.warn(`❌ No user data found for ER_ID: ${erId}`);
                continue;
            }

            const userData = userSnapshot.val();
            const isActive = userData.user_status === "Active";

            if (!isActive) {
                console.log(`⛔ Skipping user ${erId} - status is not Active (${userData.user_status})`);
                continue;
            }

            const responderName = `${userData.f_name || "Unnamed"} ${userData.l_name || ""}`.trim();

            console.log(`✅ Including responder: ${unit.unit_Name} - ${responderName}`);

            destinations.push([lng, lat]); // ORS expects [lng, lat]
            responderMap.push({
                erId,
                name: `${unit.unit_Name} - ${responderName}`,
                lng,
                lat
            });
        }

        if (destinations.length === 0) {
            console.warn("⚠️ No active responders found for this station.");
            recommendedInput.value = "No available responder";
            return;
        }

        console.log("📍 Calculating distance with ORS. Total destinations:", destinations.length);

        const orsApiKey = "5b3ce3597851110001cf6248fea3c11e56ea4db28f82d1f7ef7a6b71";
        const response = await fetch("https://api.openrouteservice.org/v2/matrix/driving-car", {
            method: "POST",
            headers: {
                "Authorization": orsApiKey,
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                locations: [origin, ...destinations],
                metrics: ["distance"],
                units: "km"
            })
        });

        const data = await response.json();

        console.log("📊 ORS Response Matrix:", data);

        let nearest = null;
        let minDistance = Number.MAX_VALUE;

        responderMap.forEach((target, index) => {
            const distance = data.distances[0][index + 1]; // index 0 = origin
            console.log(`📏 ${target.name} → ${distance.toFixed(2)} km`);
            if (distance < minDistance) {
                minDistance = distance;
                nearest = target;
            }
        });

        if (nearest) {
            console.log("✅ Nearest responder selected:", nearest.name, "| Distance:", minDistance.toFixed(2));
        } else {
            console.warn("⚠️ No nearest responder found.");
        }

        recommendedInput.value = nearest?.name || "No available responder";

    } catch (error) {
        console.error("❌ Error during nearest responder calculation:", error);
        recommendedInput.value = "No available responder";
    }
}



async function updateDropdownWithTarsier(lat, lng, preselectedResponderIDs = []) {
    console.log("🚨 updateDropdownWithTarsier() called with:", { lat, lng, preselectedResponderIDs });

    const tarsierDropdownMenu = document.getElementById("responderDropdownMenu");
    const tarsierDropdownButton = document.getElementById("responderDropdownButton");
    const assignedResponderInput = document.getElementById("assignedResponder");

    if (!tarsierDropdownMenu || !assignedResponderInput || !tarsierDropdownButton) {
        console.error("❌ Tarsier dropdown elements not found!");
        return;
    }

    // Clear previous items
    console.log("🧹 Clearing dropdown menu...");
    tarsierDropdownMenu.innerHTML = "";

    const currentUser = firebase.auth().currentUser;
    if (!currentUser) {
        alert("⚠️ You must be logged in to assign responders.");
        return;
    }

    const userUID = currentUser.uid;
    console.log(`👤 Current User UID: ${userUID}`);

    try {
        const unitsSnapshot = await firebase.database().ref("responder_unit").once("value");
        const units = unitsSnapshot.val();
        console.log(`📦 Units fetched: ${Object.keys(units || {}).length}`);

        const respondersWithDistance = [];

        for (const unitID in units) {
            const unit = units[unitID];
            console.log(`🔍 Checking unit: ${unitID}`, unit);

            if (unit.unit_Status === "Active" && unit.station_ID === userUID) {
                console.log(`✅ Unit ${unitID} is active and matches user station.`);

                const userSnapshot = await firebase.database().ref("users/" + unit.ER_ID).once("value");
                const userData = userSnapshot.val();
                console.log("User Data:", userData)

                if (userData && unit.latitude && unit.longitude) {
                    const status = userData.location_status || "Unknown";
                
                    if (status !== "Active") {
                        console.log(`⛔ Skipping ${userData.f_name} ${userData.l_name} — location_status: ${status}`);
                        continue;
                    }
                
                    const distance = calculateDistance(lat, lng, unit.latitude, unit.longitude);
                    const responderInfo = {
                        user_id: unit.ER_ID,
                        name: `${userData.f_name} ${userData.l_name}`,
                        distance: parseFloat(distance),
                    };
                
                    console.log("📍 Responder added (Active):", responderInfo);
                    respondersWithDistance.push(responderInfo);
                } else {
                    console.warn(`⚠️ Missing location or user data for ER_ID: ${unit.ER_ID}`);
                }
                
            }
        }

        respondersWithDistance.sort((a, b) => a.distance - b.distance);
        console.log("📏 Sorted responders by distance:", respondersWithDistance);

        // Add "None" option
        const noneOption = document.createElement("li");
        noneOption.innerHTML = `<label class="dropdown-item">
            <input type="checkbox" value="" class="tarsier-checkbox"> None
        </label>`;
        tarsierDropdownMenu.appendChild(noneOption);
        console.log("➕ 'None' option added.");

        // Add responders
        respondersWithDistance.forEach(responder => {
            const isChecked = preselectedResponderIDs.includes(responder.user_id);
            const li = document.createElement("li");
            li.innerHTML = `<label class="dropdown-item">
                <input type="checkbox" value="${responder.user_id}" class="tarsier-checkbox"
                    data-name="${responder.name}" data-distance="${responder.distance}" ${isChecked ? "checked" : ""}>
                ${responder.name} - ${responder.distance.toFixed(2)} km
            </label>`;
            tarsierDropdownMenu.appendChild(li);
            console.log(`➕ Responder "${responder.name}" added to dropdown.`);
        });

        // Change listener
        tarsierDropdownMenu.addEventListener("change", () => {
            const selectedCheckboxes = document.querySelectorAll(".tarsier-checkbox:checked");
            const selectedNames = [];
            const selectedIDs = [];

            selectedCheckboxes.forEach(cb => {
                if (cb.value !== "") {
                    selectedIDs.push(cb.value);
                    selectedNames.push(cb.getAttribute("data-name"));
                }
            });

            assignedResponderInput.value = selectedIDs.join(",");
            tarsierDropdownButton.textContent = selectedNames.length > 0
                ? selectedNames.join(", ")
                : "-- Select Emergency Responder(s) --";

            console.log("📝 Updated selected responders:", {
                ids: selectedIDs,
                names: selectedNames
            });
        });

        // Pre-fill selected
        const selectedNames = respondersWithDistance
            .filter(responder => preselectedResponderIDs.includes(responder.user_id))
            .map(responder => responder.name);

        assignedResponderInput.value = preselectedResponderIDs.join(",");
        tarsierDropdownButton.textContent = selectedNames.length > 0
            ? selectedNames.join(", ")
            : "-- Select Emergency Responder(s) --";

        console.log("✅ Pre-fill completed. Selected:", selectedNames);

    } catch (error) {
        console.error("❌ Error loading TaRSIER dropdown:", error);
    }
}



