document.addEventListener("DOMContentLoaded", async function () {
    const createAccountForm = document.getElementById("create-account-form");
    const fname_input = document.getElementById("f_name");
    const lname_input = document.getElementById("l_name");
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

    // ✅ Ensure elements exist before using them
    if (!openModalBtn || !modal || !closeModalBtn) {
        console.error("❌ Modal elements missing in Blade file.");
        return;
    }

    // ✅ Open modal when "Create Account" is clicked
    openModalBtn.addEventListener("click", function (event) {
        event.preventDefault();
        modal.style.display = "flex";
    });

     closeModalBtn.addEventListener("click", function () {
        modal.style.display = "none";
    });

    // ✅ Close modal when clicking outside the content
    window.addEventListener("click", function (event) {
        if (event.target === modal) {
            modal.style.display = "none";
        }
    });


    if (createAccountForm) {
        createAccountForm.addEventListener("submit", async function (event) {
            event.preventDefault();
    
            console.log("🚀 Form submission initiated...");
    
            // ✅ Clear previous error messages
            document.querySelectorAll(".error-message").forEach(el => el.style.display = "none");
    
            // ✅ Form Validation
            let isValid = true;
    
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
    
          
            const currentUser = firebase.auth().currentUser;
            if (!currentUser) {
                alert("⚠️ You must be logged in to create an account.");
                return;
            }

            const userUID = currentUser.uid;
            console.log(`User ID: ${userUID}`);

            let stationID = null;
            let stationType = null;

            try {
                // ✅ Get user data
                const userRef = firebase.database().ref('users/' + userUID);
                const snapshot = await userRef.once('value');
                const userData = snapshot.val();

                if (userData?.station_id) {
                    stationID = userData.station_id;
                    console.log(`✅ Station ID fetched: ${stationID}`);
                } else {
                    console.warn("❌ Station ID not found in user data.");
                    isValid = false;
                }

                if (stationID) {
                    // ✅ Get station type from emergency_responder_station
                    const stationRef = firebase.database().ref('emergency_responder_station/' + stationID);
                    const stationSnapshot = await stationRef.once('value');
                    const stationData = stationSnapshot.val();

                    if (stationData?.station_type) {
                        stationType = stationData.station_type;
                        console.log(`✅ Station type fetched: ${stationType}`);
                    } else {
                        console.warn("❌ Station type not found for this station.");
                        isValid = false;
                    }
                }

            } catch (error) {
                console.error("❌ Error fetching station or user data:", error);
                isValid = false;
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
                email: emailInput.value.trim(),
                user_contact: phoneNumber,  // store phone as correctly formatted
                user_role: "Emergency Responder",
                responder_type: stationType,
                user_status: "Pending",
            };   

            try {
                showLoadingModal();
                // ✅ Send Data to Laravel Backend
                const response = await fetch('/api/emergency-responder-station/create-user', {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        "Accept": "application/json",
                        "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
                    },
                    body: JSON.stringify(formData),
                });
    
                console.log("🔍 Response received:", response);
    
                const result = await response.json();
                console.log("✅ Server response:", result);
    
                if (result.success) {
                   
                    modal.style.display = "none";
                    openSucessModal.style.display = "flex";
    
                    // ✅ Reset the form fields
                    document.getElementById("create-account-form").reset();
    
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

});
