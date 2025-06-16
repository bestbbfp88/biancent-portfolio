// let emergencyLocation = null;
// let tarsierResponders = [];
// let responderStations = []; // Stores mapped stations with user IDs

// // ✅ Function to Calculate Distance (Haversine Formula)
// function calculateDistance(lat1, lng1, lat2, lng2) {
//     const R = 6371; // Radius of Earth in km
//     const dLat = (lat2 - lat1) * (Math.PI / 180);
//     const dLng = (lng2 - lng1) * (Math.PI / 180);
//     const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
//               Math.cos(lat1 * (Math.PI / 180)) * Math.cos(lat2 * (Math.PI / 180)) *
//               Math.sin(dLng / 2) * Math.sin(dLng / 2);
//     const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
//     return (R * c).toFixed(2); // Distance in km
// }

// // ✅ Load Emergency Responder Stations in Real-Time
// function loadEmergencyResponderStations() {
//     console.log("🔄 Loading Emergency Responder Stations...");

//     const userRef = firebase.database().ref("users");
//     const stationRef = firebase.database().ref("emergency_responder_station");

//     userRef.once("value", userSnapshot => {
//         console.log("📡 Fetching users with role 'Emergency Responder Station'...");

//         let userStationMap = [];

//         userSnapshot.forEach(childSnapshot => {
//             const user = childSnapshot.val();
//             if (user.user_role === "Emergency Responder Station" && user.station_id) {
//                 userStationMap.push({
//                     user_id: childSnapshot.key,
//                     station_id: user.station_id
//                 });
//             }
//         });

//         if (userStationMap.length === 0) {
//             console.warn("⚠️ No users found with role 'Emergency Responder Station'!");
//             return;
//         }

//         stationRef.once("value", stationSnapshot => {
//             console.log("📡 Fetching responder stations from Firebase...");

//             stationSnapshot.forEach(childSnapshot => {
//                 const station = childSnapshot.val();
//                 const stationId = childSnapshot.key;

//                 let matchedUsers = userStationMap.filter(user => user.station_id === stationId);

//                 if (matchedUsers.length > 0) {
//                     matchedUsers.forEach(user => {
//                         if (station.latitude && station.longitude && station.station_type) {
//                             responderStations.push({
//                                 user_id: user.user_id,
//                                 station_id: stationId,
//                                 station_name: station.station_name,
//                                 lat: parseFloat(station.latitude),
//                                 lng: parseFloat(station.longitude),
//                                 station_type: station.station_type
//                             });
//                         } else {
//                             console.warn(`⚠️ Skipping station ${stationId} due to missing data.`);
//                         }
//                     });
//                 }
//             });

//             console.log("✅ Emergency Responder Stations Loaded:", responderStations);
//         });
//     });
// }

// // ✅ Assign Nearest Station Based on Distance
// function assignNearestStation(lat, lng) {
//     let emergencyType = document.getElementById("emergencyType").value;
//     if (!lat || !lng || isNaN(lat) || isNaN(lng)) {
//         console.warn("⚠️ Invalid location for assigning nearest station", { lat, lng });
//         return;
//     }

//     console.log(`📍 Assigning nearest stations for emergency at ${lat}, ${lng}...`);

//     let stationDistances = [];
//     let dropdownMenu = document.getElementById("stationDropdownMenu");
//     let distanceInput = document.getElementById("distanceToStation");

//     dropdownMenu.innerHTML = ""; // Clear previous options

//     // ✅ Filter Stations Based on Emergency Type
//     let filteredStations = responderStations.filter(station => {
//         if (emergencyType === "Police") return station.station_type === "PNP";
//         if (emergencyType === "Medical") return station.station_type === "MDRRMO";
//         if (emergencyType === "Fire") return station.station_type === "BFP";
//         return true; // ✅ Show all stations for "Other"
//     });

//     // ✅ Calculate Distances
//     filteredStations.forEach(station => {
//         let distance = calculateDistance(lat, lng, station.lat, station.lng);
//         stationDistances.push({ station, distance });
//     });

//     // ✅ Sort by Nearest Distance
//     stationDistances.sort((a, b) => a.distance - b.distance);
//     let topStations = stationDistances.slice(0, 5);

//     // ✅ Populate Dropdown with Nearest Stations
//     let noneOption = document.createElement("li");
//     noneOption.innerHTML = `<label class="dropdown-item">
//         <input type="checkbox" value="" class="station-checkbox"> None
//     </label>`;
//     dropdownMenu.appendChild(noneOption);

//     topStations.forEach(entry => {
//         let stationOption = document.createElement("li");
//         stationOption.innerHTML = `<label class="dropdown-item">
//             <input type="checkbox" value="${entry.station.station_id}" data-name="${entry.station.station_name}" data-distance="${entry.distance}" class="station-checkbox">
//             ${entry.station.station_name} - ${entry.distance} km
//         </label>`;
//         dropdownMenu.appendChild(stationOption);
//     });

//     console.log("✅ Dropdown Updated:", dropdownMenu.innerHTML);
// }


// // ✅ Update Emergency Status
// function updateEmergencyStatus(location, patientName) {
//     const emergenciesRef = firebase.database().ref("emergencies");

//     emergenciesRef.once("value", snapshot => {
//         if (!snapshot.exists()) return;

//         let emergencyFound = false;

//         snapshot.forEach(childSnapshot => {
//             const emergency = childSnapshot.val();
//             const emergencyKey = childSnapshot.key;

//             if (emergency.location === location || emergency.patient_name === patientName) {
//                 emergencyFound = true;
//                 firebase.database().ref(`emergencies/${emergencyKey}`).update({ report_Status: "Responding" });
//             }
//         });

//         if (!emergencyFound) console.warn("⚠️ No matching emergency found to update.");
//     });
// }

// function recommendNearestEmergencyUnit(lat, lng) {
//     let emergencyTypeElement = document.getElementById("emergencyType");
//     let emergencyType = emergencyTypeElement ? emergencyTypeElement.value : "";

//     if (emergencyType !== "Medical" && emergencyType !== "Other") {
//         console.warn("❌ Skipping recommendation: Emergency type is not Medical or Other.");
//         document.getElementById("recommendedTaRSIER").value = "";
//         return;
//     }

//     if (!lat || !lng) {
//         console.warn("⚠️ Invalid location for recommending nearest emergency unit");
//         return;
//     }

//     console.log(`🚑 Checking nearest responder for Medical/Other emergency at location: ${lat}, ${lng}`);

//     let nearestTaRSIER = null;
//     let nearestMDRRMO = null;
//     let minTaRSIERDistance = Number.MAX_VALUE;
//     let minMDRRMODistance = Number.MAX_VALUE;

//     // 🔹 Find the nearest TaRSIER Responder
//     tarsierResponders.forEach(responder => {
//         let distance = calculateDistance(lat, lng, responder.lat, responder.lng);
//         console.log(`📌 Distance to TaRSIER: ${responder.name} = ${distance} km`);

//         if (distance < minTaRSIERDistance) {
//             minTaRSIERDistance = distance;
//             nearestTaRSIER = responder;
//         }
//     });

//     // 🔹 Find the nearest MDRRMO station
//     responderStations.forEach(station => {
//         if (station.type === "MDRRMO") { // Only check MDRRMO stations
//             let distance = calculateDistance(lat, lng, station.lat, station.lng);
//             console.log(`🏥 Distance to MDRRMO: ${station.name} = ${distance} km`);

//             if (distance < minMDRRMODistance) {
//                 minMDRRMODistance = distance;
//                 nearestMDRRMO = station;
//             }
//         }
//     });

//     let recommendedInput = document.getElementById("recommendedTaRSIER");

//     if (nearestTaRSIER && (minTaRSIERDistance <= minMDRRMODistance)) {
//         console.log("✅ Prioritizing TaRSIER Responder:", nearestTaRSIER);
//         recommendedInput.value = nearestTaRSIER.name;
//     } else if (nearestMDRRMO) {
//         console.log("✅ No TaRSIER Available, Assigning MDRRMO:", nearestMDRRMO);
//         recommendedInput.value = nearestMDRRMO.name;
//     } else {
//         console.warn("⚠️ No available TaRSIER or MDRRMO responder.");
//         recommendedInput.value = "No available responder";
//     }
// }

// function updateSelectedStations() {
//     let checkboxes = document.querySelectorAll(".station-checkbox");
//     let selectedStationIds = [];
//     let selectedStationNames = [];
//     let selectedDistances = [];

//     checkboxes.forEach(checkbox => {
//         if (checkbox.checked && checkbox.value !== "") {
//             selectedStationIds.push(checkbox.value); // ✅ Store ID for Firebase
//             selectedStationNames.push(checkbox.getAttribute("data-name")); // ✅ Store Name for UI
//             selectedDistances.push(`${checkbox.getAttribute("data-name")}: ${parseFloat(checkbox.getAttribute("data-distance")).toFixed(2)} km`);
//         }
//     });

//     // ✅ Store selected station IDs in the hidden input field for Firebase
//     document.getElementById("nearestStation").value = selectedStationIds.join(",");

//     // ✅ Store selected names & distances in distanceToStation for UI
//     let distanceInput = document.getElementById("distanceToStation");
//     distanceInput.value = selectedDistances.length > 0 ? selectedDistances.join(", ") : "";

//     updateDropdownButton(selectedStationNames);
// }

// function updateDropdownButton(selectedStationNames) {
//     let dropdownButton = document.getElementById("stationDropdownButton");

//     if (!dropdownButton) {
//         console.error("❌ Error: Dropdown button not found!");
//         return;
//     }

//     dropdownButton.textContent = selectedStationNames.length > 0 ? selectedStationNames.join(", ") : "-- Select Station(s) --";
// }


// // ✅ Ensure Functions Run on Page Load
// document.addEventListener("DOMContentLoaded", () => {
//     loadEmergencyResponderStations();

//     let patientInput = document.getElementById("numberPatients");
//     if (patientInput) {
//         patientInput.addEventListener("input", () => {
//             if (emergencyLocation) assignNearestStation(emergencyLocation.lat, emergencyLocation.lng);
//         });
//     }
// });

// // ✅ Emergency Type Change Event
// document.addEventListener("DOMContentLoaded", () => {
//     let emergencyTypeDropdown = document.getElementById("emergencyType");
//     if (!emergencyTypeDropdown) return;

//     emergencyTypeDropdown.addEventListener("change", () => {
//         if (emergencyLocation) assignNearestStation(emergencyLocation.lat, emergencyLocation.lng);
//     });
// });


// document.addEventListener("DOMContentLoaded", function () {
//     let emergencyTypeDropdown = document.getElementById("emergencyType");
//     let tarsierSection = document.getElementById("tarsierResponderSection"); // Section for Tarsier Responder
//     let stationDropdown = document.getElementById("stationDropdownButton"); // Emergency Responder Stations

//     if (!emergencyTypeDropdown || !tarsierSection || !stationDropdown) {
//         console.error("❌ Error: Some elements are missing in the DOM!");
//         return;
//     }

//     emergencyTypeDropdown.addEventListener("change", function () {
//         let emergencyType = this.value;
//         let patientCount = parseInt(document.getElementById("numberPatients").value) || 1;

//         console.log("🚑 Emergency Type Changed:", emergencyType);

//         if (emergencyType === "Medical") {
//             tarsierSection.style.display = "block"; // Show Tarsier section
//             if (patientCount === 1) {
//                 stationDropdown.style.pointerEvents = "none"; // Disable selection
//                 stationDropdown.style.opacity = "0.5"; // Reduce visibility
//                 document.querySelectorAll(".station-checkbox").forEach(cb => cb.disabled = true);
//             } else {
//                 stationDropdown.style.pointerEvents = "auto"; // Enable selection if patients > 1
//                 stationDropdown.style.opacity = "1";
//                 document.querySelectorAll(".station-checkbox").forEach(cb => cb.disabled = false);
//             }
//         } else if (emergencyType === "Other") {
//             tarsierSection.style.display = "block"; // Show Tarsier section
//             stationDropdown.style.pointerEvents = "auto"; // Enable selection
//             stationDropdown.style.opacity = "1";
//             document.querySelectorAll(".station-checkbox").forEach(cb => cb.disabled = false);
//         } else {
//             tarsierSection.style.display = "none"; // Hide Tarsier section
//             stationDropdown.style.pointerEvents = "auto"; // Enable selection
//             stationDropdown.style.opacity = "1";
//             document.querySelectorAll(".station-checkbox").forEach(cb => cb.disabled = false);
//         }
        
//     });

//     // Also check patient count when number changes
//     document.getElementById("numberPatients").addEventListener("input", function () {
//         let emergencyType = emergencyTypeDropdown.value;
//         let patientCount = parseInt(this.value) || 1;

//         if ((emergencyType === "Medical" || emergencyType === "Other") && patientCount === 1) {
//             stationDropdown.style.pointerEvents = "none";
//             stationDropdown.style.opacity = "0.5";
//             document.querySelectorAll(".station-checkbox").forEach(cb => cb.disabled = true);
//         } else {
//             stationDropdown.style.pointerEvents = "auto";
//             stationDropdown.style.opacity = "1";
//             document.querySelectorAll(".station-checkbox").forEach(cb => cb.disabled = false);
//         }
//     });
// });

// document.addEventListener("DOMContentLoaded", function () {
//     let dropdownMenu = document.getElementById("stationDropdownMenu");
//     if (!dropdownMenu) {
//         console.error("❌ Error: Dropdown menu not found!");
//         return;
//     }

//     dropdownMenu.addEventListener("change", function (event) {
//         if (event.target.classList.contains("station-checkbox")) {
//             updateSelectedStations();
//         }
//     });
// });


