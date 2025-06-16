document.addEventListener("DOMContentLoaded", function () {
    const addEmergencyForm = document.getElementById("addEmergencyFormEmNumber");

    if (!addEmergencyForm) {
        console.warn("🚫 addEmergencyFormEmNumber not found in the DOM.");
        return;
    }

    const emergencyNumberInput = document.getElementById("emergencyNumberEmNumber");
    const addContactBtn = document.getElementById("addEmergencyModalEmNumber");

    // ✅ Form submission
    addEmergencyForm.addEventListener("submit", async function (event) {
        event.preventDefault();

        const emergencyName = document.getElementById("emergencyNameEmNumber").value.trim();
        const emergencyNumber = emergencyNumberInput.value.trim();

        if (!emergencyName || !emergencyNumber) {
            alert("❌ Please fill in all required fields.");
            return;
        }

        const phoneRegex = /^\+639[0-9]{9}$/;
        if (!phoneRegex.test(emergencyNumber)) {
            emergencyNumberInput.classList.add("is-invalid");
            emergencyNumberInput.nextElementSibling.textContent = "Please enter a valid Philippine mobile number starting with +63.";
            return;
        }

        const emergencyContactsRef = firebase.database().ref("emergency_contacts");
        const snapshot = await emergencyContactsRef.orderByChild("number").equalTo(emergencyNumber).once("value");

        if (snapshot.exists()) {
            emergencyNumberInput.classList.add("is-invalid");
            emergencyNumberInput.nextElementSibling.textContent = "This emergency number already exists.";
            return;
        }

        try {
            const emergencyData = {
                number_name: emergencyName,
                number: emergencyNumber,
                number_status: "Active",
                created_at: new Date().toISOString(),
            };

            await emergencyContactsRef.push(emergencyData);
            alert("✅ Emergency contact added successfully!");
            addEmergencyForm.reset();

            const addEmergencyModalElement = document.getElementById("addEmergencyModalEmNumber");
            const addEmergencyModal = bootstrap.Modal.getInstance(addEmergencyModalElement);
            if (addEmergencyModal) addEmergencyModal.hide();
        } catch (error) {
            console.error("❌ Error adding emergency contact:", error);
            alert("❌ Failed to add emergency contact. Please try again.");
        }
    });

    // ✅ Dynamic contact fields
    if (addContactBtn) {
        addContactBtn.addEventListener("click", function () {
            const div = document.createElement("div");
            div.classList.add("input-group", "mb-2");

            div.innerHTML = `
                <input type="text" class="form-control contact-number" name="contactNumbers[]" placeholder="Enter emergency number" required>
                <button type="button" class="btn btn-danger remove-contact">&times;</button>
            `;

            contactContainer.appendChild(div);
        });

        contactContainer.addEventListener("click", function (e) {
            if (e.target.classList.contains("remove-contact")) {
                e.target.parentElement.remove();
            }
        });
    } else {
        console.warn("🚫 Dynamic contact fields container or add button not found.");
    }
});
