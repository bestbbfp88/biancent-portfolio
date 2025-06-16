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

            const activeUnitsByStation = {};

            const responderUnitSnapshot = await firebase.database().ref("responder_unit").once("value");
            const responderUnits = responderUnitSnapshot.val();

            if (responderUnits) {
                Object.values(responderUnits).forEach(unit => {
                    if (unit.unit_Status === "Active" && unit.station_ID) {
                        if (!activeUnitsByStation[unit.station_ID]) {
                            activeUnitsByStation[unit.station_ID] = 0;
                        }
                        activeUnitsByStation[unit.station_ID]++;
                    }
                });
            }

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
            
                const availableCount = activeUnitsByStation[entry.station.user_id] || 0;
            
                li.innerHTML = `<label class="dropdown-item">
                    <input type="checkbox" value="${entry.station.user_id}" class="station-checkbox"
                        data-name="${entry.station.station_name}" data-distance="${entry.distanceText}"
                        ${isChecked ? "checked" : ""}>
                    ${entry.station.station_name} - ${entry.distanceText} (Available Units: ${availableCount})
                </label>`;
            
                dropdownMenu.appendChild(li);
            });
            
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
    const emergencyType = document.getElementById("emergencyType")?.value;
    const recommendedInput = document.getElementById("recommendedTaRSIER");
    const mvcType = document.querySelector('input[name="mvcType"]:checked')?.value || "";


    if (!lat || !lng || isNaN(lat) || isNaN(lng)) {
        console.warn("⚠️ Invalid location for recommending responder");
        recommendedInput.value = "No available responder";
        return;
    }

    const orsApiKey = "5b3ce3597851110001cf6248fea3c11e56ea4db28f82d1f7ef7a6b71";
    const origin = [lng, lat];
    const destinations = [];
    const responderMap = [];

    try {
        // 🔍 Step 1: Load only TaRSIER responders from responder_unit
        const tarsierUnits = [];
        const snapshot = await firebase.database().ref("responder_unit").once("value");
        const units = snapshot.val();

        for (const unitID in units) {
            const unit = units[unitID];

            if (unit.unit_Status === "Active" && unit.unit_Assign === "TaRSIER Unit" && unit.latitude && unit.longitude) {
                const userSnap = await firebase.database().ref(`users/${unit.ER_ID}`).once("value");
                const user = userSnap.val();

                if (user && user.location_status === "Active") {
                    tarsierUnits.push({
                        lat: parseFloat(unit.latitude),
                        lng: parseFloat(unit.longitude),
                        name: `${unit.unit_Name} - ${user.f_name} ${user.l_name}`,
                        type: "TaRSIER"
                    });
                }
            }
        }

        // 🔍 Step 2: Add filtered stations by type
        const addStations = (stations, type) => {
            stations
                .filter(s => s.station_type === type)
                .forEach(station => {
                    destinations.push([station.lng, station.lat]);
                    responderMap.push({ ...station, type: "Station", label: station.station_name });
                });
        };

        // 🔍 Step 3: Add TaRSIER responders
        const addResponders = () => {
            tarsierUnits.forEach(responder => {
                destinations.push([responder.lng, responder.lat]);
                responderMap.push(responder);
            });
        };

        // ✅ Apply based on emergencyType
        if (emergencyType === "Medical") {
            addResponders();
            addStations(responderStations, "MDRRMO");
        } else if (emergencyType === "Trauma") {
            addStations(responderStations, "MDRRMO");
        } else if (emergencyType === "Police") {
            addStations(responderStations, "PNP");
        } else if (emergencyType === "Fire") {
            addStations(responderStations, "BFP");
        } else if (emergencyType === "MVC") {
            if (mvcType === "For Extrication") {
                addStations(responderStations, "BFP");
                addStations(responderStations, "MDRRMO");
            } else {
                addStations(responderStations, "MDRRMO");
            }
        } else  {
            // If no specific type, include all stations + tarsier
            addResponders();
            responderStations.forEach(station => {
                destinations.push([station.lng, station.lat]);
                responderMap.push({ ...station, type: "Station", label: station.station_name });
            });
        }

        if (destinations.length === 0) {
            recommendedInput.value = "No available responder";
            return;
        }

        const response = await fetch("https://api.openrouteservice.org/v2/matrix/driving-car", {
            method: "POST",
            headers: {
                "Authorization": orsApiKey,
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                locations: [origin, ...destinations],
                metrics: ["distance"],
                units: "m"
            })
        });

        const data = await response.json();
        const distances = data.distances[0].slice(1); // Remove origin

        let nearestTaRSIER = null;
        let minTaRSIERDistance = Number.MAX_VALUE;
        let nearestStation = null;
        let minStationDistance = Number.MAX_VALUE;

        distances.forEach((distance, index) => {
            const km = distance / 1000;
            const target = responderMap[index];

            if (target.type === "TaRSIER" && km < minTaRSIERDistance) {
                minTaRSIERDistance = km;
                nearestTaRSIER = target;
            }

            if (target.type === "Station" && km < minStationDistance) {
                minStationDistance = km;
                nearestStation = target;
            }
        });

        if (nearestTaRSIER && nearestStation && emergencyType === "Medical") {
            const diff = Math.abs(minTaRSIERDistance - minStationDistance);
            recommendedInput.value = minTaRSIERDistance <= minStationDistance + 1
                ? nearestTaRSIER.name
                : nearestStation.label;
        } else if (nearestStation) {
            recommendedInput.value = nearestStation.label;
        } else if (nearestTaRSIER) {
            recommendedInput.value = nearestTaRSIER.name;
        } else {
            recommendedInput.value = "No available responder";
        }

    } catch (error) {
        console.error("❌ Error recommending responder:", error);
        recommendedInput.value = "No available responder";
    }
}



async function updateDropdownWithTarsier(lat, lng, preselectedResponderIDs = []) {
    console.log("🚨 updateDropdownWithTarsier() called with:", { lat, lng, preselectedResponderIDs });

    const tarsierDropdownMenu = document.getElementById("tarsierDropdownMenu");
    const tarsierDropdownButton = document.getElementById("tarsierDropdownButton");
    const assignedResponderInput = document.getElementById("assignedResponder");

    if (!tarsierDropdownMenu || !assignedResponderInput || !tarsierDropdownButton) {
        console.error("❌ Tarsier dropdown elements not found!");
        return;
    }

    tarsierDropdownMenu.innerHTML = "";

    const currentUser = firebase.auth().currentUser;
    if (!currentUser) {
        alert("⚠️ You must be logged in to assign responders.");
        return;
    }

    const userUID = currentUser.uid;
    console.log("👤 Logged in as UID:", userUID);

    try {
        const unitsSnapshot = await firebase.database().ref("responder_unit").once("value");
        const units = unitsSnapshot.val();
        console.log("📦 Loaded units:", units ? Object.keys(units).length : 0);

        const respondersWithDistance = [];

        for (const unitID in units) {
            const unit = units[unitID];
            console.log(`➡️ Processing unit ${unitID}`, unit);

            if (unit.unit_Assign !== "TaRSIER Unit") continue;
            
            if (unit.unit_Status === "Active") {
                console.log(`✅ Unit ${unitID} is active and belongs to current station.`);

                const userSnapshot = await firebase.database().ref("users/" + unit.ER_ID).once("value");
                const userData = userSnapshot.val();

                if (userData && unit.latitude && unit.longitude) {
                    const status = userData.location_status || "Unknown";
                    console.log(`👤 Responder ${unit.ER_ID} - Status: ${status}`);

                    if (status !== "Active") {
                        console.log("⛔ Skipping due to inactive status");
                        continue;
                    }

                    const distance = calculateDistance(lat, lng, unit.latitude, unit.longitude);
                    console.log(`📏 Distance to emergency: ${distance} km`);

                    respondersWithDistance.push({
                        user_id: unit.ER_ID,
                        unit_name: unit.unit_Name || "Unnamed Unit",
                        responder_name: `${userData.f_name} ${userData.l_name}`,
                        distance: parseFloat(distance),
                    });
                    
                } else {
                    console.warn(`⚠️ Missing user data or coordinates for unit ${unitID}`);
                }
            }
        }

        console.log("📊 Responders with distance:", respondersWithDistance);

        respondersWithDistance.sort((a, b) => a.distance - b.distance);

        const noneOption = document.createElement("li");
        noneOption.innerHTML = `<label class="dropdown-item">
            <input type="checkbox" value="" class="tarsier-checkbox"> None
        </label>`;
        tarsierDropdownMenu.appendChild(noneOption);

        respondersWithDistance.forEach(responder => {
            const isChecked = preselectedResponderIDs.includes(responder.user_id);
            const li = document.createElement("li");
            li.innerHTML = `<label class="dropdown-item">
                <input type="checkbox" value="${responder.user_id}" class="tarsier-checkbox"
                    data-name="${responder.unit_name} - ${responder.responder_name}" data-distance="${responder.distance}" ${isChecked ? "checked" : ""}>
                ${responder.unit_name} - ${responder.responder_name} (${responder.distance.toFixed(2)} km)
            </label>`;
            tarsierDropdownMenu.appendChild(li);
        });
        

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

            console.log("📝 Selected IDs:", selectedIDs);
            console.log("📝 Selected Names:", selectedNames);
        });

        const selectedNames = respondersWithDistance
            .filter(responder => preselectedResponderIDs.includes(responder.user_id))
            .map(responder => responder.name);

        assignedResponderInput.value = preselectedResponderIDs.join(",");
        tarsierDropdownButton.textContent = selectedNames.length > 0
            ? selectedNames.join(", ")
            : "-- Select Emergency Responder(s) --";

        console.log("✅ Dropdown initialized with preselected:", selectedNames);

    } catch (error) {
        console.error("❌ Error loading TaRSIER dropdown:", error);
    }
}