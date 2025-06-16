document.addEventListener("DOMContentLoaded", async function () {

    const createAccountForm = document.getElementById("create-account-form");
    const roleSelect = document.getElementById("role");
    const responderTypeContainer = document.getElementById("responder-type-container");
    const responderTypeSelect = document.getElementById("responder-type");
    const lguStationContainer = document.getElementById("lgu-station-container");
    const lguStationSelect = document.getElementById("lgu-station");
    const lguStationError = document.getElementById("lgu-station-error");
    const stationFieldsContainer = document.getElementById("station-fields-container");
    const stationnameContainer = document.getElementById("station-name-container");

    const fullnameInput = document.getElementById("name-container");
    const fname_input = document.getElementById("f_name");
    const lname_input = document.getElementById("l_name");
    const stationnameInput = document.getElementById("station_name");
    const emailInput = document.getElementById("email");
    const phoneInput = document.getElementById("phone");
    const stationTypeSelect = document.getElementById("station-type");
    const addressInput = document.getElementById("address");
    const latitudeInput = document.getElementById("latitude");
    const longitudeInput = document.getElementById("longitude");

    //✅ Get modal elements
    const openModalBtn = document.getElementById("open-modal-btn");
    const modal = document.getElementById("account-modal");
    const closeModalBtn = document.getElementById("close-modal-btn");
    const openSucessModal = document.getElementById("success-modal");

    
    let autocompleteInitialized = false;
    

    // ✅ Ensure elements exist before using them
    if (!openModalBtn || !modal || !closeModalBtn) {
        console.error("❌ Modal elements missing in Blade file.");
        return;
    }

    phoneInput.addEventListener("keydown", function (e) {
        if (phoneInput.selectionStart <= 3 && (e.key === "Backspace" || e.key === "Delete")) {
            e.preventDefault();
        }
    });

    phoneInput.addEventListener("keydown", function (e) {
        // Disallow deleting inside "+63"
        if ((phoneInput.selectionStart <= 3) && 
            (e.key === "Backspace" || e.key === "Delete")) {
            e.preventDefault();
        }
    
        // Disallow typing over "+63"
        if (phoneInput.selectionStart < 3 && 
            !["ArrowLeft", "ArrowRight", "Tab"].includes(e.key)) {
            e.preventDefault();
        }
    });
    
    // ✅ Always restore "+63" if someone tries to erase
    phoneInput.addEventListener("input", function () {
        if (!phoneInput.value.startsWith("+63")) {
            phoneInput.value = "+63";
        }
    });
    
    // ✅ When focusing, ensure cursor is after "+63"
    phoneInput.addEventListener("focus", function () {
        if (phoneInput.value.trim() === "") {
            phoneInput.value = "+63";
        }
        setTimeout(() => {
            if (phoneInput.selectionStart < 3) {
                phoneInput.setSelectionRange(3, 3);
            }
        }, 0);
    });

    openModalBtn.addEventListener("click", function (event) {
        event.preventDefault();
        modal.style.display = "flex";
    
        // ✅ Automatically set "+63" when opening the form
        if (!phoneInput.value.startsWith("+63")) {
            phoneInput.value = "+63";
        }
    });
    

    // ✅ Close modal when "X" button is clicked
    closeModalBtn.addEventListener("click", function () {
        modal.style.display = "none";
    });

    // ✅ Close modal when clicking outside the content
    window.addEventListener("click", function (event) {
        if (event.target === modal) {
            modal.style.display = "none";
        }
    });



    // ✅ Role Selection Logic
    roleSelect.addEventListener("change", function () {
        const selectedRole = roleSelect.value;

        if (selectedRole === "Emergency Responder") {
            responderTypeContainer.style.display = "block"; // Show Emergency Responder Type
            stationFieldsContainer.style.display = "none";  // Hide Station Fields
            lguStationContainer.style.display = "none";     // Hide LGU Station Select
            fullnameInput.style.display = "block";
            stationnameContainer.style.display = "none";
        } 
        else if (selectedRole === "Emergency Responder Station") {
            responderTypeContainer.style.display = "none";  // Hide Emergency Responder Type
            stationFieldsContainer.style.display = "block"; // Show Station Fields
            lguStationContainer.style.display = "none";     // Hide LGU Station Select
            fullnameInput.style.display = "none";
            stationnameContainer.style.display = "block";
        } 
        else {
            responderTypeContainer.style.display = "none";
            stationFieldsContainer.style.display = "none";
            lguStationContainer.style.display = "none";
            stationnameContainer.style.display = "none";
            fullnameInput.style.display = "block";
        }

    });


    //  Show LGU Station Selection Only for LGU Responders
    responderTypeSelect.addEventListener("change", function () {
        if (!responderTypeSelect.value.includes("TaRSIER Responder")) {
            lguStationContainer.style.display = "block"; 
            fetchLGUStations();
        } else {
            lguStationContainer.style.display = "none"; 
        }
    });


    responderTypeSelect.addEventListener("change", fetchLGUStations);
    
    async function fetchLGUStations() {
        const selectedType = responderTypeSelect.value;
    
        try {
            const usersRef = firebase.database().ref("users");
            const stationsRef = firebase.database().ref("emergency_responder_station");
    
            const [usersSnapshot, stationsSnapshot] = await Promise.all([
                usersRef.once("value"),
                stationsRef.once("value")
            ]);
    
            if (usersSnapshot.exists() && stationsSnapshot.exists()) {
                lguStationSelect.innerHTML = '<option value="" disabled selected>Select LGU Responder Station</option>';
    
                usersSnapshot.forEach(userSnap => {
                    const user = userSnap.val();
                    const userUID = userSnap.key;
    
                    // ✅ Only Emergency Responder Stations
                    if (user.user_role === "Emergency Responder Station") {
                        const stationId = user.station_id;
    
                        // ✅ Get corresponding station data from emergency_responder_station
                        const stationData = stationsSnapshot.child(stationId).val();
    
                        if (stationData && stationData.station_type === selectedType) {
                            const option = document.createElement("option");
                            option.value = userUID; // ✅ UID from users collection
                            option.textContent = `${stationData.station_name} - ${stationData.station_type}`;
                            lguStationSelect.appendChild(option);
                        }
                    }
                });
            } else {
                lguStationSelect.innerHTML = '<option value="" disabled selected>No LGU Responder Stations Available</option>';
            }
        } catch (error) {
            console.error("❌ Error fetching LGU stations:", error);
        }
    }

    document.getElementById("confirm-location").addEventListener("click", () => {
        const lat = parseFloat(latitudeInput.value);
        const lng = parseFloat(longitudeInput.value);
    
        if (!isNaN(lat) && !isNaN(lng)) {
            const event = new CustomEvent("locationConfirmed", {
                detail: { lat, lng }
            });
            window.dispatchEvent(event);
        }
    
        mapModal.style.display = "none";
    });
    
    
    if (createAccountForm) {
        createAccountForm.addEventListener("submit", async function (event) {
            event.preventDefault();
    
            console.log("🚀 Form submission initiated...");
    
            // ✅ Clear previous error messages
            document.querySelectorAll(".error-message").forEach(el => el.style.display = "none");
    
            // ✅ Form Validation
            let isValid = true;
    
            if (roleSelect.value === "Emergency Responder") {

                // ✅ Validate Responder Type
                if (!responderTypeSelect.value.trim()) {
                    console.log("❌ Responder Type is missing");
                    document.getElementById("responder-type-error").style.display = "block";
                    isValid = false;
                } else {
                    console.log(`✅ Responder Type: ${responderTypeSelect.value}`);
                    document.getElementById("responder-type-error").style.display = "none";
                }
            
                // ✅ Validate LGU Station if not TaRSIER Responder
                if (responderTypeSelect.value.trim() !== "TaRSIER Responder") {
                    if (!lguStationSelect.value.trim()) {
                        console.log("❌ LGU Station is missing for non-TaRSIER Responder");
                        document.getElementById("lgu-station-error").style.display = "block";
                        isValid = false;
                    } else {
                        console.log(`✅ LGU Station: ${lguStationSelect.value}`);
                        document.getElementById("lgu-station-error").style.display = "none";
                    }
                } else {
                    console.log("🚀 Skipping LGU Station validation for TaRSIER Responder.");
                    document.getElementById("lgu-station-error").style.display = "none";
                }
            }
            

            if (roleSelect.value === "Emergency Responder Station") {
                // ✅ Validate station_name for Emergency Responder Station
                if (!stationnameInput.value.trim()) {
                    console.log("❌ Station name is missing");
                    document.getElementById("stationName-error").style.display = "block";
                    isValid = false;
                } else {
                    console.log(`✅ Station name: ${stationnameInput.value.trim()}`);
                    document.getElementById("stationName-error").style.display = "none";
                }
            
                // ✅ Validate latitude
                if (!latitudeInput.value.trim() && !longitudeInput.value.trim()) {
                    document.getElementById("address-error").style.display = "block";
                    isValid = false;
                } else {
                    document.getElementById("address-error").style.display = "none";
                }
            
                if (!stationTypeSelect.value.trim()) {
                    document.getElementById("station-type-error").style.display = "block";
                    isValid = false;
                } else {
                    document.getElementById("station-type-error").style.display = "none";
                }
            
            
            } else {
                // ✅ Validate f_name and l_name for other roles
                if (!fname_input.value.trim()) {
                    console.log("❌ First name is missing");
                    document.getElementById("fname-error").style.display = "block";
                    isValid = false;
                } else {
                    console.log(`✅ First name: ${fname_input.value.trim()}`);
                    document.getElementById("fname-error").style.display = "none";
                }
            
                if (!lname_input.value.trim()) {
                    console.log("❌ Last name is missing");
                    document.getElementById("lname-error").style.display = "block";
                    isValid = false;
                } else {
                    console.log(`✅ Last name: ${lname_input.value.trim()}`);
                    document.getElementById("lname-error").style.display = "none";
                }
            }
    
         
            // Validate Email
            const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailInput.value.trim() || !emailPattern.test(emailInput.value.trim())) {
                console.log("❌ Invalid email format or missing email");
                document.getElementById("email-error").style.display = "block";
                isValid = false;
            } else {
                console.log(`✅ Email: ${emailInput.value.trim()}`);
            }
    
            // ✅ Automatically add "+" if missing
            let phoneNumber = phoneInput.value.trim().replace(/\s/g, ""); 

            // If the number starts with "63" but is missing "+", add it
            if (/^63\d{10}$/.test(phoneNumber)) {
                console.log("ℹ️ Missing '+' detected. Adding it...");
                phoneNumber = `+${phoneNumber}`;
            }

            const phonePattern = /^\+63\d{10}$/;

            if (!phoneNumber || !phonePattern.test(phoneNumber)) {
                console.log("❌ Invalid phone number format:", phoneNumber);
                document.getElementById("phone-error").style.display = "block";
                isValid = false;
            } else {
                console.log(`✅ Phone: ${phoneNumber}`);
                document.getElementById("phone-error").style.display = "none";
            }


    
            // Validate Role Selection
            if (!roleSelect.value.trim()) {
                console.log("❌ Role not selected");
                document.getElementById("role-error").style.display = "block";
                isValid = false;
            } else {
                console.log(`✅ Role: ${roleSelect.value.trim()}`);
            }
    
            // Validate LGU Selection if LGU Responder is chosen
            if (responderTypeSelect.value.includes("LGU Responder") && !lguStationSelect.value) {
                console.log("❌ LGU station not selected for LGU Responder");
                document.getElementById("lgu-station-error").style.display = "block";
                isValid = false;
            } else {
                console.log(`✅ LGU Station: ${lguStationSelect.value || "N/A"}`);
            }
    
            // Stop submission if form is invalid
            if (!isValid) {
                console.log("⚠️ Form validation failed. Submission halted.");
                return;
            }
    
            // ✅ Gather Form Data
            const formData = {
                f_name: fname_input.value.trim(),
                l_name: lname_input.value.trim(),
                station_name: stationnameInput.value.trim() || null,
                email: emailInput.value.trim(),
                phone: phoneInput.value.trim(),
                role: roleSelect.value.trim(),
                responder_type: responderTypeSelect.value || null,
                location: addressInput.value.trim() || null,
                lgu_station_id: lguStationSelect.value || null,
                station_type: stationTypeSelect.value || null,
                latitude: latitudeInput.value.trim() || null,
                longitude: longitudeInput.value.trim() || null
            };
    
            console.log("✅ Form data collected:", formData);
    
            try {
                showLoadingModal();
    
                // ✅ Send Data to Laravel Backend
                const response = await fetch('/api/admin/create-user', {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
                    },
                    body: JSON.stringify(formData),
                });
    
                console.log("🔍 Response received:", response);
    
                const result = await response.json();
                console.log("✅ Server response:", result);
    
                if (result.success) {
                    console.log("🎯 User successfully created!");
    
                    // ✅ Hide modal after successful submission
                    modal.style.display = "none";
                    openSucessModal.style.display = "flex";
    
                    // ✅ Reset the form fields
                    document.getElementById("create-account-form").reset();
    
                    // ✅ Reset dynamically controlled fields
                    document.getElementById("name-container").style.display = "block"; 
                    document.getElementById("station-name-container").style.display = "none";
                    document.getElementById("responder-type-container").style.display = "none";
                    document.getElementById("lgu-station-container").style.display = "none";
                    document.getElementById("station-fields-container").style.display = "none";
    
                    // ✅ Hide success message after 2 seconds
                    setTimeout(() => {
                        openSucessModal.style.display = "none";
                    }, 2000);
                } else {
                    console.error("❌ Error from server:", result.message);
                    alert("Error: " + result.message);
                }
    
            } catch (error) {
                console.error("❌ Exception caught:", error);
                alert("Error: " + error.message);
            } finally {
                console.log("✅ Hiding loading modal.");
                hideLoadingModal();
            }
        });
    }
    

    function showLoadingModal() {
        const loadingModal = document.getElementById('loadingModal');
        if (loadingModal) loadingModal.style.display = 'block';
    }

    function hideLoadingModal() {
        const loadingModal = document.getElementById('loadingModal');
        if (loadingModal) loadingModal.style.display = 'none';
    }

    allowOnlyLetters(fname_input);
    allowOnlyLetters(lname_input);
    
});

function allowOnlyLetters(inputElement) {
    inputElement.addEventListener("input", function (e) {
        this.value = this.value
            .replace(/[^a-zA-Z\s\-]/g, "") // Allow only letters, spaces, and hyphens
            .replace(/\s{2,}/g, " "); // Replace multiple spaces with a single space
    });
}
    