let existingContactNumbers = [];


document.addEventListener("DOMContentLoaded", async function () {
    await fetchExistingContactNumbers();
    const addHospitalForm = document.getElementById("addHospitalForm");
    const contactContainer = document.getElementById("contactNumbersContainer");
    const addContactBtn = document.getElementById("addContactNumber");
    let existingHospitalNames = [];

    // Fetch existing hospital names from Firebase
    async function fetchExistingHospitalNames() {
        const hospitalsRef = firebase.database().ref("hospitals");
        const snapshot = await hospitalsRef.once('value');
        snapshot.forEach(childSnapshot => {
            const hospitalName = childSnapshot.val().name.toLowerCase(); // Normalize to lower case
            existingHospitalNames.push(hospitalName);
        });
    }

    // Wait for existing hospital names to be fetched before allowing form interactions
    await fetchExistingHospitalNames();

    // Function to reset contact number fields
    const resetContactFields = () => {
        console.log("Resetting contact fields");
        contactContainer.innerHTML = `
            <div class="input-group mb-2">
                <input type="text" class="form-control contact-number" name="contactNumbers[]" placeholder="Enter contact number" required>
                <button type="button" class="btn btn-danger remove-contact" style="display: none;">&times;</button>
            </div>
        `;
    };

    // Add new contact number field dynamically
    addContactBtn.addEventListener("click", function () {
        const container = document.getElementById("contactNumbersContainer");
        const div = document.createElement("div");
        div.classList.add("input-group", "mb-2");
        div.innerHTML = `
            <input type="text" class="form-control contact-number" name="contactNumbers[]" placeholder="Enter contact number" required>
            <div class="invalid-feedback">Invalid contact number.</div>
            <button type="button" class="btn btn-danger remove-contact">&times;</button>
        `;
        container.appendChild(div);
    });

    // Remove dynamically added contact number fields
    contactContainer.addEventListener("click", function (e) {
        if (e.target.classList.contains("remove-contact")) {
            console.log("Removing a contact number field");
            e.target.parentElement.remove();
        }
    });

    // Add Hospital form submission event
    addHospitalForm.addEventListener("submit", async function (event) {
        event.preventDefault();
        let valid = true;
        
        console.log("Form submission attempted");

        // Get input values
        // Hospital Name Validation
        const hospitalNameInput = document.getElementById("hospitalName");
        const hospitalName = hospitalNameInput.value.trim().toLowerCase(); // Normalize input for comparison
        const nameFeedback = document.getElementById("hospitalNameFeedback");

        // Check if the input is empty
        if (!hospitalName) {
            hospitalNameInput.classList.add("is-invalid");
            nameFeedback.textContent = "Hospital name is required.";
            nameFeedback.style.display = 'block';
            valid = false;
        } else if (existingHospitalNames.includes(hospitalName)) {
            // Check if the name already exists
            hospitalNameInput.classList.add("is-invalid");
            nameFeedback.textContent = "This hospital name already exists. Please use a different name.";
            nameFeedback.style.display = 'block';
            valid = false;
        } else {
            // If there are no errors
            hospitalNameInput.classList.remove("is-invalid");
            nameFeedback.style.display = 'none';
        }

        // Hospital Address Validation
        const hospitalAddress = document.getElementById("hospitalAddress");
        if (!hospitalAddress.value.trim()) {
            hospitalAddress.classList.add("is-invalid");
            valid = false;
        } else {
            hospitalAddress.classList.remove("is-invalid");
        }

        // Contact Numbers Validation
        document.querySelectorAll(".contact-number").forEach(input => {
            if (!input.value.trim()) {
                input.classList.add("is-invalid");
                valid = false;
            } else {
                input.classList.remove("is-invalid");
            }
        });

        
        const hospitalLat = document.getElementById("hospitalLat").value.trim();
        const hospitalLng = document.getElementById("hospitalLng").value.trim();

        const contactNumbers = Array.from(document.querySelectorAll(".contact-number"))
        .map(input => input.value.trim());

        document.querySelectorAll(".contact-number").forEach(input => {
            const number = input.value.trim();
            const feedbackElement = input.nextElementSibling; // Assumes invalid-feedback is right after input

            // Validate the phone number format
            if (!/^(\+63)9\d{9}$/.test(number)) {
                input.classList.add("is-invalid");
                feedbackElement.textContent = "Please enter a valid Philippine mobile number (e.g., +639123456789).";
                feedbackElement.style.display = 'block';
                valid = false;
            } else if (existingContactNumbers.includes(number)) {
                // Check if the number already exists
                input.classList.add("is-invalid");
                feedbackElement.textContent = "This mobile number is already registered.";
                feedbackElement.style.display = 'block';
                valid = false;
            } else {
                input.classList.remove("is-invalid");
                feedbackElement.style.display = 'none';
            }
        });


    
    if (!valid) {
        return; // Stop submission if not valid
    }
        // Prepare hospital data object
        const hospitalData = {
            name: hospitalName,
            address: hospitalAddress,
            latitude: parseFloat(hospitalLat),
            longitude: parseFloat(hospitalLng),
            hospital_status: "Active",
            created_at: new Date().toISOString(),
        };

        try {
            // Push the new hospital record to Firebase
            const hospitalsRef = firebase.database().ref("hospitals");
            const hospitalSnapshot = await hospitalsRef.push(hospitalData);
            const hospitalId = hospitalSnapshot.key;

            // Save each contact number
            const contactNumbersRef = firebase.database().ref("hospital_contact_number");
            const contactNumberPromises = contactNumbers.map(contactNumber => {
                existingContactNumbers.push(contactNumber); // Update local list
                return contactNumbersRef.push({
                    hospital_id: hospitalId,
                    contact_number: contactNumber,
                    created_at: new Date().toISOString(),
                });
            });
            
            await Promise.all(contactNumberPromises);

            await Promise.all(contactNumberPromises);
            console.log("All contact numbers added successfully");
            alert("✅ Hospital and contact numbers added successfully!");

            // Reset form fields and update existing names
            existingHospitalNames.push(hospitalName);
            addHospitalForm.reset();
            resetContactFields();

            // Optionally hide the modal
            const addHospitalModalElement = document.getElementById("addHospitalModal");
            if (addHospitalModal) {
                const addHospitalModalInstance = bootstrap.Modal.getInstance(addHospitalModalElement);
                addHospitalModalInstance.hide();
            }
        } catch (error) {
            console.error("❌ Error adding hospital:", error);
            alert("❌ Failed to add hospital. Please try again.");
        }
    });
});

async function fetchExistingContactNumbers() {
    const contactNumbersRef = firebase.database().ref("hospital_contact_number");
    const snapshot = await contactNumbersRef.once('value');
    snapshot.forEach(childSnapshot => {
        const contactNumber = childSnapshot.val().contact_number;
        existingContactNumbers.push(contactNumber); // Assume stored numbers are in +63 format
    });
}