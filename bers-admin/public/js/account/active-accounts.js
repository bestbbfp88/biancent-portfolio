document.addEventListener("DOMContentLoaded", function () {

    function cleanNameInput(inputElement) {
        if (inputElement && inputElement.value !== undefined) {
            inputElement.value = inputElement.value
                .replace(/[^a-zA-Z\s\-]/g, "")   // Allow only letters, spaces, hyphens
                .replace(/\s{2,}/g, " ")         // Replace multiple spaces with single space
                .trim();                         // Remove starting/trailing spaces
        }
    }
    
    function applyLiveNameValidation(inputElement) {
        if (inputElement) {
            inputElement.addEventListener("input", () => {
                cleanNameInput(inputElement);
            });
        }
    }
    

    const tableBody = document.getElementById("activeAccountsTable");
    const searchInput = document.getElementById("searchUsers");
    const updateUserForm = document.getElementById("updateUserForm");
    const updateUserModal = document.getElementById("updateUserModal");

    const confirmDeactivateModal = document.getElementById("confirmDeactivateModal");
    const successDeactivateModal = document.getElementById("successDeactivateModal");

    const closeConfirmModal = document.getElementById("close-confirm-modal-deactivate");
    const cancelConfirmModal = document.getElementById("cancel-confirm-modal-deactivate");
    const closeSuccessModal = document.getElementById("close-success-modal-deactivate");
    const confirmDeactivateBtn = document.getElementById("confirmDeactivateBtn");
    

    let activeUsers = [];
    let userToDeactivate = null;
    

    const db = firebase.database();
    const activeUsersRef = db.ref('users');

    activeUsersRef.on('value', snapshot => {
        const usersData = snapshot.val();

        const allowedRoles = [
            "Emergency Responder",
            "Emergency Responder Station",
            "Resource Manager",
            "Communicator"
        ];

        activeUsers = usersData
            ? Object.entries(usersData)
                .map(([id, user]) => ({ id, ...user }))
                .filter(user => allowedRoles.includes(user.user_role) && user.user_status === "Active")
            : [];

        displayUsers(activeUsers);
    }, error => {
        console.error("❌ Firebase Listener Error:", error);
    });

    // ✅ Display Users
    async function displayUsers(users) {
        const tableBody = document.getElementById("tableBody");
        if (!tableBody) return;
    
        tableBody.innerHTML = "";
    
        if (users.length === 0) {
            tableBody.innerHTML = `<tr><td colspan="5" class="text-center text-danger">No active users available.</td></tr>`;
            return;
        }
    
        const stationsSnapshot = await firebase.database().ref("emergency_responder_station").once("value");
        const stationsData = stationsSnapshot.val() || {};

        users.forEach(user => {
            // Determine the display name based on the role
            let displayName;

            if (user.user_role === "Emergency Responder Station") {
                // Find the station name using the user's station_id
                displayName = stationsData[user.station_id]?.station_name || "Unknown Station";
            } else {
                // Construct the full name for non-emergency responder users
                displayName = `${user.l_name || ""} ${user.f_name || ""}`.trim() || "Unknown";
            }
        
            let verificationButton = user.verified
                ? `<span class="badge bg-success">Verified</span>`
                : `<button class="btn btn-info btn-sm send-verification-btn" data-email="${user.email}">Reset Password</button>`;
        
            let row = `
                <tr>
                    <td>${displayName}</td>
                    <td><a href="mailto:${user.email}">${user.email || "N/A"}</a></td>
                    <td>${user.user_role || "N/A"}</td>
                    <td>
                        <div class="d-flex gap-2">
                            <button class="btn btn-primary btn-sm view-btn" data-id="${user.id}">View</button>
                            <button class="btn btn-warning btn-sm update-btn-account" data-id="${user.id}">Update</button>
                            <button class="btn btn-danger btn-sm deactivate-btn" data-id="${user.id}">Deactivate</button>
                            ${verificationButton}
                        </div>
                    </td>
                </tr>
            `;
            tableBody.insertAdjacentHTML("beforeend", row);
        });        
    
        attachEventListeners();
    }
    
    

    function attachEventListeners() {
        document.querySelectorAll(".update-btn-account").forEach(button => {
            button.addEventListener("click", () => {
                console.log("🚀 Button clicked:", button);  // ✅ Log the clicked button element
        
                const userId = button.dataset.id;  // Extract user ID from the button
                console.log("🔍 Extracted user ID:", userId);  // ✅ Log the ID
        
                if (userId) {
                    console.log(`✅ Navigating to updateUser() with ID: ${userId}`);
                    updateUser(userId);  // ✅ Proceed with the update function
                } else {
                    console.warn("⚠️ No user ID found for update button.");
                }
            });
        });
        
        

        document.querySelectorAll(".deactivate-btn").forEach(btn =>
            btn.onclick = () => openConfirmDeactivateModal(btn.dataset.id));

        document.querySelectorAll(".send-verification-btn").forEach(btn =>
            btn.onclick = () => sendVerification(btn.dataset.email));

        document.querySelectorAll(".view-btn").forEach(btn =>
            btn.onclick = () => openViewModal(btn.dataset.id));
    }

    async function updateUser(id) {
        const user = activeUsers.find(u => u.id === id);
    
        console.log("🛠 updateUser() called with ID:", id);
        if (!user) {
            alert("❌ User not found!");
            return;
        }
    
        console.log("🔄 Editing user:", user);
    
        // Fill base fields
        document.getElementById("update_user_id").value = user.id;
        document.getElementById("update_f_name").value = user.f_name || "";
        document.getElementById("update_l_name").value = user.l_name || "";
        document.getElementById("update_email").value = user.email || "";
        document.getElementById("update_phone").value = user.user_contact || "";
        document.getElementById("update_role").value = user.user_role || "";
        document.getElementById("update_role").disabled = true;
        document.getElementById("update-name-container").style.display = "block";

        applyLiveNameValidation(document.getElementById("update_f_name"));
        applyLiveNameValidation(document.getElementById("update_l_name"));
        applyLiveNameValidation(document.getElementById("update_station_name"));
    
        // Hide all conditional fields by default
        document.getElementById("update_station-name-container").style.display = "none";
        document.getElementById("update_responder-type-container").style.display = "none";
        document.getElementById("update_lgu-station-container").style.display = "none";
        document.getElementById("update_station-fields-container").style.display = "none";
    
        // ✅ Handle role-specific fields
        if (user.user_role === "Emergency Responder") {
            document.getElementById("update_responder-type-container").style.display = "block";
            document.getElementById("update_responder-type").value = user.responder_type || "";
            document.getElementById("update_responder-type").disabled = true;  
    
            const isLGU = ["PNP", "BFP", "Coast Guard", "MDRRMO"].includes(user.responder_type);
    
            if (isLGU && user.created_by) {
                document.getElementById("update_lgu-station-container").style.display = "block";
    
                try {
                    // 🔥 Step 1: Fetch user with created_by UID from users collection
                    const userRef = firebase.database().ref(`users/${user.created_by}`);
                    const userSnapshot = await userRef.once("value");
    
                    if (userSnapshot.exists()) {
                        const creatorData = userSnapshot.val();
                        console.log("👤 Found creator:", creatorData);
    
                        if (creatorData.station_id) {
                            const stationId = creatorData.station_id;
    
                            // 🔥 Step 2: Find matching stations by responder_type
                            const stationsRef = firebase.database().ref("emergency_responder_station");
                            const stationsSnapshot = await stationsRef.once("value");
                            const stations = stationsSnapshot.val();
    
                            // ✅ Filter stations by responder_type
                            const stationDropdown = document.getElementById("update_lgu-station");
                            stationDropdown.innerHTML = ""; // Clear existing options
    
                            if (stations) {
                                let foundMatch = false;
    
                                Object.keys(stations).forEach((key) => {
                                    const station = stations[key];
    
                                    // Match responder type and pre-select the station
                                    if (station.station_type === user.responder_type) {
                                        const option = document.createElement("option");
                                        option.value = key;
                                        option.textContent = station.station_name;
    
                                        if (key === stationId) {
                                            option.selected = true; // ✅ Pre-select matching station
                                            foundMatch = true;
                                        }
    
                                        stationDropdown.appendChild(option);
                                    }
                                });
    
                                if (!foundMatch) {
                                    console.warn(`⚠️ No matching station found for station_id: ${stationId}`);
                                    const option = document.createElement("option");
                                    option.value = "";
                                    option.textContent = "Unknown Station";
                                    stationDropdown.appendChild(option);
                                }
                            } else {
                                console.warn("⚠️ No stations found.");
                                const option = document.createElement("option");
                                option.value = "";
                                option.textContent = "No Stations Available";
                                stationDropdown.appendChild(option);
                            }

                            stationDropdown.disabled = true;
                        } else {
                            console.warn(`⚠️ No station_id found for creator UID: ${user.created_by}`);
                            document.getElementById("update_lgu-station").innerHTML = "<option value=''>No station assigned</option>";
                        }
                    } else {
                        console.warn(`⚠️ No creator found with UID: ${user.created_by}`);
                        document.getElementById("update_lgu-station").innerHTML = "<option value=''>Unknown Creator</option>";
                    }
                } catch (error) {
                    console.error("❌ Error fetching LGU Station:", error);
                    document.getElementById("update_lgu-station").innerHTML = "<option value=''>Error fetching station</option>";
                }
            }
        }
    
        // ✅ Handle Emergency Responder Station fields
        if (user.user_role === "Emergency Responder Station") {
            document.getElementById("update_station-name-container").style.display = "block";
            document.getElementById("update_station-fields-container").style.display = "block";
            document.getElementById("update-name-container").style.display = "none";
        
            // ✅ Fetch address, latitude, and longitude from Firebase
            if (user.station_id) {
                try {
                    console.log(`🔍 Fetching station info for station_id: ${user.station_id}`);
        
                    // 🔥 Fetch station data from emergency_responder_station collection
                    const stationRef = firebase.database().ref(`emergency_responder_station/${user.station_id}`);
                    const stationSnapshot = await stationRef.once("value");
        
                    if (stationSnapshot.exists()) {
                        const stationData = stationSnapshot.val();
                        console.log("✅ Found station data:", stationData);
        
                      
                        document.getElementById("update_station_name").value = stationData.station_name || "";
                        document.getElementById("update_station-type").value = stationData.station_type || "";
                        document.getElementById("update_station-type").disabled = true;
        
                        document.getElementById("update_latitude").value = stationData.latitude || "";
                        document.getElementById("update_longitude").value = stationData.longitude || "";

                        if (stationData.latitude && stationData.longitude) {
                            const lat = parseFloat(stationData.latitude);
                            const lng = parseFloat(stationData.longitude);
                        
                            const nominatimUrl = `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${lat}&lon=${lng}`;
                        
                            try {
                                const response = await fetch(nominatimUrl, {
                                    headers: {
                                        "User-Agent": "bohol-emergency-response-system/1.0 (admin@example.com)" // Replace with your email
                                    }
                                });
                        
                                const data = await response.json();
                        
                                if (data && data.display_name) {
                                    document.getElementById("update_address").value = data.display_name;
                                } else {
                                    document.getElementById("update_address").value = "Unable to decode address";
                                }
                        
                            } catch (geoError) {
                                console.error("❌ Error decoding address with OSM:", geoError);
                                document.getElementById("update_address").value = "Error fetching address";
                            }
                        } else {
                            document.getElementById("update_address").value = "Coordinates not available";
                        }
                        
                    } else {
                        console.warn(`⚠️ No station found with ID: ${user.station_id}`);
                        document.getElementById("update_address").value = "Unknown Address";
                        document.getElementById("update_latitude").value = "";
                        document.getElementById("update_longitude").value = "";
                    }
                } catch (error) {
                    console.error("❌ Error fetching station data:", error);
                    document.getElementById("update_address").value = "Error fetching address";
                    document.getElementById("update_latitude").value = "";
                    document.getElementById("update_longitude").value = "";
                }
            } else {
                console.warn("⚠️ No station_id found in the user data.");
                document.getElementById("update_address").value = "No station assigned";
                document.getElementById("update_latitude").value = "";
                document.getElementById("update_longitude").value = "";
                
            }
        }
        
        //  Ensure the correct modal is shown
        const modalId = "updateAccountModal";
        const modalElement = document.getElementById(modalId);
    
        if (modalElement) {
            const modal = new bootstrap.Modal(modalElement);
            console.log(`Showing modal with ID: ${modalId}`);
            modal.show();
        } else {
            console.error(`Modal with ID '${modalId}' not found.`);
        }

        // Open the map modal
        document.getElementById("update_address").addEventListener("click", () => {
            console.log("📍 Opening map modal...");
            document.getElementById("update_map-modal-location").style.display = "block";
        
            setTimeout(() => {
                initMap(); // ⚡ Delay to ensure the DOM is fully ready
            }, 300);
        });
        

        // 🔥 Close the map modal
        document.getElementById("update_close-map").addEventListener("click", () => {
            console.log("❌ Closing map modal...");
            document.getElementById("update_map-modal-location").style.display = "none";
        });

        let updatedLat = null;
        let updatedLng = null;

        function initMap() {
            const latInput = parseFloat(document.getElementById("update_latitude").value) || 9.677789012375596;
            const lngInput = parseFloat(document.getElementById("update_longitude").value) || 123.8916706698973;

            const initialCoords = [latInput, lngInput];

            // Clear previous map if exists
            const existingMap = L.DomUtil.get("update_map-location");
            if (existingMap && existingMap._leaflet_id) {
                existingMap._leaflet_id = null;
            }

            const updateMap = L.map("update_map-location").setView(initialCoords, 15);

            L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
                attribution: '© OpenStreetMap contributors'
            }).addTo(updateMap);

            const updateMarker = L.marker(initialCoords, {
                draggable: true
            }).addTo(updateMap).bindPopup("📍 Drag to select location").openPopup();

            updatedLat = initialCoords[0];
            updatedLng = initialCoords[1];

            updateMarker.on("dragend", function (e) {
                const position = updateMarker.getLatLng();
                updatedLat = position.lat;
                updatedLng = position.lng;
                console.log(`📍 Dragged to: ${updatedLat}, ${updatedLng}`);
            });

            L.Control.geocoder({
                defaultMarkGeocode: false
            })
            .on("markgeocode", function (e) {
                const center = e.geocode.center;
                updateMap.setView(center, 16);
                updateMarker.setLatLng(center);

                updatedLat = center.lat;
                updatedLng = center.lng;

                console.log(`📍 Searched to: ${updatedLat}, ${updatedLng}`);
            })
            .addTo(updateMap);
        }


    // 🔥 Confirm and save the new location
   document.getElementById("update_confirm-location").addEventListener("click", async () => {
        if (updatedLat && updatedLng) {
            console.log(`✅ Saving selected location: ${updatedLat}, ${updatedLng}`);

            // 👉 Set coordinates to form fields
            document.getElementById("update_latitude").value = updatedLat;
            document.getElementById("update_longitude").value = updatedLng;

            try {
                // 🌍 Reverse geocode to get address from lat/lng
                const address = await reverseGeocode(updatedLat, updatedLng);
                document.getElementById("update_address").value = address;
                console.log(`✅ Resolved address: ${address}`);
            } catch (error) {
                console.error("❌ Reverse geocoding failed:", error);
                document.getElementById("update_address").value = "Address not found";
            }

            // ✅ Close the map modal (if using Bootstrap modal)
            const modal = bootstrap.Modal.getInstance(document.getElementById("update_map-modal-location"));
            if (modal) {
                modal.hide();
            } else {
                // Fallback (manual close)
                document.getElementById("update_map-modal-location").style.display = "none";
            }

        } else {
            alert("⚠️ Please select a location by dragging or searching on the map.");
        }
    });

    async function reverseGeocode(lat, lng) {
        const url = `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lng}&format=json`;

        const response = await fetch(url, {
            headers: {
                'User-Agent': 'Bohol Emergency System - Demo (your@email.com)',
                'Accept-Language': 'en',
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        return data.display_name || "Address not found";
    }

     // ✅ Handle form submission
     const form = document.getElementById("update-account-form");
     form.onsubmit = (e) => {
         e.preventDefault();
         console.log(`🚀 Submitting update form for ID: ${user.id}`);
         submitUpdateForm(user.id); // Pass ID to updater
     };

    }
    
    
    async function submitUpdateForm(user_id) {
        console.log("🟡 Starting user update for ID:", user_id);
        showLoadingModal();
    
        const db = firebase.database();
        const userRole = document.getElementById("update_role").value;
        const newEmail = document.getElementById("update_email").value;
        const phoneInput = document.getElementById("update_phone").value;
        const fNameInput = document.getElementById("update_f_name")?.value || "";
        const lNameInput = document.getElementById("update_l_name")?.value || "";
        const responderTypeInput = document.getElementById("update_responder-type")?.value || "";
        const lguStationInput = document.getElementById("update_lgu-station")?.value || "";
    
        const updatedData = {
            phone: phoneInput,
            f_name: fNameInput,
            l_name: lNameInput,
            user_role: userRole,
            updated_at: new Date().toISOString(),
        };
    
        try {
            console.log("🔍 Fetching current user data from Firebase...");
            const userSnapshot = await db.ref(`users/${user_id}`).once("value");
            const userData = userSnapshot.val();
            const currentEmail = userData?.email || "";
            const stationId = userData?.station_id || null;
    
            console.log("📨 Current Email:", currentEmail);
    
            // ✉️ Update email if changed
            if (newEmail !== currentEmail) {
                console.log("📧 Email has changed. Sending update request to backend...");
    
                const response = await fetch(`/update-user-email/${user_id}`, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        "Accept": "application/json",
                        "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]').getAttribute("content")
                    },
                    body: JSON.stringify({ email: newEmail }),
                });
    
                const result = await response.json();
    
                if (!response.ok) {
                    console.error("❌ Backend email update failed:", result.message);
                    alert("❌ Email update error: " + result.message);
                    return;
                }
    
                console.log("✅ Backend email update success:", result);
                updatedData.email = newEmail;
            }
    
            // 📍 Special role-based updates
            if (userRole === "Emergency Responder Station" && stationId) {
                const stationName = document.getElementById("update_station_name")?.value || "";
                const stationType = document.getElementById("update_station-type")?.value || "";
                const address = document.getElementById("update_address")?.value || "";
                const latitude = document.getElementById("update_latitude")?.value || "";
                const longitude = document.getElementById("update_longitude")?.value || "";
    
                const stationUpdate = { station_name: stationName, station_type: stationType, address, latitude, longitude };
                await db.ref(`emergency_responder_station/${stationId}`).update(stationUpdate);
    
                updatedData.station_name = stationName;
                updatedData.station_type = stationType;
                updatedData.address = address;
                updatedData.latitude = latitude;
                updatedData.longitude = longitude;
            }
    
            if (userRole === "Emergency Responder") {
                updatedData.responder_type = responderTypeInput;
                updatedData.lgu_station_id = lguStationInput;
            }
    
            console.log("📤 Updating user data in Firebase:", updatedData);
            await db.ref(`users/${user_id}`).update(updatedData);
    
            alert("✅ User data updated successfully!");
    
            const modalElement = document.getElementById("updateAccountModal");
            const modalInstance = bootstrap.Modal.getInstance(modalElement);
            if (modalInstance) modalInstance.hide();
    
        } catch (error) {
            console.error("❌ Caught error during update process:", error);
            alert("❌ Failed to update user.");
        } finally {
            console.log("🔚 Update process complete.");
            hideLoadingModal();
        }
    }
    
    
    
    function openConfirmDeactivateModal(user_id) {
        userToDeactivate = user_id;
        confirmDeactivateModal.style.display = "flex";
    }

    async function deactivateUser() {
        if (!userToDeactivate) return;
    
        showLoadingModal();
    
        try {
            // ✅ Step 1: Fetch user details from `users`
            const userSnapshot = await firebase.database().ref(`users/${userToDeactivate}`).once("value");
            
            if (!userSnapshot.exists()) {
                alert("❌ User not found.");
                hideLoadingModal();
                return;
            }
    
            const userData = userSnapshot.val();
            const userRole = userData.user_role || "";
            const stationId = userData.station_id || null;
    
            console.log(`🔍 Deactivating user (${userRole}) with ID: ${userToDeactivate}`);
    
            // ✅ Step 2: Check if the user is still assigned to a responder unit (ER_ID)
            const unitSnapshot = await firebase.database().ref("responder_unit")
                .orderByChild("ER_ID")
                .equalTo(userToDeactivate)
                .once("value");
    
            if (unitSnapshot.exists()) {
                console.warn("⚠️ User is still assigned to a responder unit. Cannot archive.");
                alert("❌ Cannot archive user. The user is still assigned to a responder unit.");
                hideLoadingModal();
                return;  // 🚫 Stop the process
            }
    
            // ✅ Step 3: If Emergency Responder Station, check if linked to a station in `users`
            if (userRole === "Emergency Responder Station" && stationId) {
                const stationAssignedSnapshot = await firebase.database().ref("users")
                    .orderByChild("station_id")
                    .equalTo(stationId)
                    .once("value");
    
                if (stationAssignedSnapshot.exists()) {
                    console.warn("⚠️ User is still linked to a responder station. Cannot archive.");
                    alert("❌ Cannot archive user. The user is still linked to a responder station.");
                    hideLoadingModal();
                    return;  // 🚫 Stop the process
                }
            }
    
            console.log("✅ User is not assigned to any unit or station. Proceeding with deactivation...");
    
            // ✅ Step 4: Disable the user in Firebase Auth through Laravel
            const response = await fetch(`/admin/disable-user/${userToDeactivate}`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
                }
            });
    
            const result = await response.json();
    
            if (!result.success) {
                console.error("❌ Failed to disable user in Auth:", result.message);
                alert(`❌ Error: ${result.message}`);
                return;  // 🚫 Stop the process if Auth disabling fails
            }
    
            console.log("✅ User disabled in Firebase Auth");
    
            // ✅ Step 5: Update the user's status in Firebase RTDB
            await firebase.database().ref(`users/${userToDeactivate}`).update({
                user_status: "Archived"
            });
    
            console.log("✅ User status updated in RTDB");
    
            // ✅ Display success modal
            confirmDeactivateModal.style.display = "none";
            successDeactivateModal.style.display = "flex";
    
            setTimeout(() => {
                successDeactivateModal.style.display = "none";
            }, 2000);
    
        } catch (error) {
            console.error("❌ Error deactivating user:", error);
            alert("❌ Failed to deactivate user.");
        } finally {
            hideLoadingModal();
        }
    }
    
    async function sendVerification(email) {
        showLoadingModal();

        try {
            const response = await fetch(`/admin/password-reset/${email}`, {
                method: "POST",
                headers: { "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]').getAttribute("content") }
            });

            const data = await response.json();
            if (response.ok && data.success) {
                alert("✅ Verification email sent successfully!");
            } else {
                alert("❌ Error: " + data.message);
            }
        } catch (error) {
            console.error("❌ Error sending verification email:", error);
        } finally {
            hideLoadingModal();
        }
    }

    async function openViewModal(id) {
        const user = activeUsers.find(u => u.id === id);
        if (!user) {
            alert("❌ User not found!");
            console.error(`User with ID ${id} not found in activeUsers.`);
            return;
        }
    
        console.log("👤 Viewing user:", user);
    
        const fullNameField = document.getElementById("viewModalFullName");
        const emailField = document.getElementById("viewModalEmail");
        const phoneField = document.getElementById("viewModalPhone");
        const roleField = document.getElementById("viewModalRole");
        const locationContainer = document.getElementById("viewModalLocationContainer");
        const locationField = document.getElementById("viewModalLocation");
        const lguStationContainer = document.getElementById("viewModalLGUStationContainer");
        const lguStationField = document.getElementById("viewModalLGUStation");
    
        // Hide optional fields by default
        [locationContainer, lguStationContainer].forEach(container => {
            container.classList.add("d-none");
            container.classList.remove("d-flex");
        });
        locationField.textContent = "";
        lguStationField.textContent = "";
    
        // Set email and phone
        emailField.textContent = user.email || "N/A";
        phoneField.textContent = user.user_contact || "N/A";
    
        // Set role and responder type
        roleField.textContent = user.user_role === "Emergency Responder"
            ? `${user.user_role} - ${user.responder_type || "Unknown"}`
            : user.user_role || "N/A";
    
        // CASE 1: Emergency Responder Station (get station_name + location)
        if (user.user_role === "Emergency Responder Station" && user.station_id) {
            try {
                const snapshot = await firebase.database().ref(`emergency_responder_station/${user.station_id}`).once("value");
                const stationData = snapshot.val();
        
                if (stationData) {
                    fullNameField.textContent = stationData.station_name || "Unnamed Station";
        
                    if (stationData.latitude && stationData.longitude) {
                        const lat = parseFloat(stationData.latitude);
                        const lng = parseFloat(stationData.longitude);
        
                        const nominatimUrl = `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${lat}&lon=${lng}`;
        
                        try {
                            const response = await fetch(nominatimUrl, {
                                headers: {
                                    "User-Agent": "bohol-emergency-system/1.0 (pacatang.biancent@hnu.edu.ph)" // Replace with a valid email
                                }
                            });
                            const data = await response.json();
        
                            if (data && data.display_name) {
                                locationField.textContent = data.display_name;
                            } else {
                                locationField.textContent = "Unable to decode location";
                            }
                        } catch (geoError) {
                            console.error("❌ OSM Geocoding error:", geoError);
                            locationField.textContent = "Unable to decode location";
                        }
        
                        locationContainer.classList.remove("d-none");
                        locationContainer.classList.add("d-flex");
        
                    } else {
                        locationField.textContent = "Location not available";
                        locationContainer.classList.remove("d-none");
                        locationContainer.classList.add("d-flex");
                    }
                } else {
                    fullNameField.textContent = "Unnamed Station";
                }
            } catch (error) {
                console.error("❌ Error fetching Emergency Responder Station:", error);
                fullNameField.textContent = "Unnamed Station";
            }
        } else {
            fullNameField.textContent = `${user.f_name || ""} ${user.l_name || ""}`.trim() || "N/A";
        }
        
        // CASE 2: LGU Responder (PNP, BFP, MDRRMO, Coast Guard)
        const allowedResponderTypes = ["PNP", "BFP", "MDRRMO", "Coast Guard"];
        if (
            user.user_role === "Emergency Responder" &&
            allowedResponderTypes.includes(user.responder_type) &&
            user.created_by
        ) {
            try {
                const creatorSnap = await firebase.database().ref(`users/${user.created_by}`).once("value");
                const creatorData = creatorSnap.val();
    
                if (creatorData && creatorData.station_id) {
                    const stationSnap = await firebase.database().ref(`emergency_responder_station/${creatorData.station_id}`).once("value");
                    const stationData = stationSnap.val();
    
                    if (stationData) {
                        lguStationField.textContent = stationData.station_name || "Unknown Station";
                        lguStationContainer.classList.remove("d-none");
                        lguStationContainer.classList.add("d-flex");
                    }
                }
            } catch (error) {
                console.warn("⚠️ Could not fetch LGU station:", error);
            }
        }
    
        // Show modal
        console.log("📦 Opening modal for user...");
        new bootstrap.Modal(document.getElementById("viewModal")).show();
    }
    
    
    searchInput.addEventListener("input", () => {
        const searchTerm = searchInput.value.toLowerCase().trim(); // <-- add ()
        
        const filtered = activeUsers.filter(u =>
          (u.f_name || "").toLowerCase().includes(searchTerm) ||
          (u.l_name || "").toLowerCase().includes(searchTerm) ||
          (u.email || "").toLowerCase().includes(searchTerm) ||
          (u.user_role || "").toLowerCase().includes(searchTerm)
        );
      
        displayUsers(filtered);
      });
      

    confirmDeactivateBtn.addEventListener("click", deactivateUser);
    cancelConfirmModal.addEventListener("click", () => confirmDeactivateModal.style.display = "none");
    closeConfirmModal.addEventListener("click", () => confirmDeactivateModal.style.display = "none");
    closeSuccessModal.addEventListener("click", () => successDeactivateModal.style.display = "none");

    function showLoadingModal() {
        document.getElementById('loadingModal').style.display = 'block';
    }

    function hideLoadingModal() {
        document.getElementById('loadingModal').style.display = 'none';
    }

    const userManagementModal = document.getElementById("userManagementModal");
    const viewModal = document.getElementById("viewModal");

    // When viewModal opens, hide userManagementModal
    viewModal.addEventListener("show.bs.modal", () => {
        const userManagementInstance = bootstrap.Modal.getInstance(userManagementModal);
        if (userManagementInstance) {
            userManagementInstance.hide();
        }
    });

    // When viewModal closes, show userManagementModal again
    viewModal.addEventListener("hidden.bs.modal", () => {
        const userManagementInstance = new bootstrap.Modal(userManagementModal);
        userManagementInstance.show();
    });
    //fetchStationAddressOnLoad();
});
