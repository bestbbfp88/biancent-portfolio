document.addEventListener("DOMContentLoaded", function () {
    console.log("✅ Firebase Emergency Number Management Script Loaded!");

    const tableBody = document.getElementById("emergencyListEmNumber");
    const searchInput = document.getElementById("searchEmergency");

    const updateEmergencyForm = document.getElementById("updateEmergencyFormEmNumber");
    const updateEmergencyModal = document.getElementById("updateEmergencyModalEmNumber");

    const successArchiveModalElement = document.getElementById("successArchiveModalEmNumber");

    const confirmArchiveBtn = document.getElementById("confirmArchive-btn");

    const emNumberModalElement = document.getElementById("emergencyModalEmNumber");
    const addEmNumberModalElement = document.getElementById("addEmergencyModalEmNumber");

    const emNumberArchiveModalElement = document.getElementById("archivedEmergencyModalEmNumber");
    if (!emNumberArchiveModalElement) {
        console.error("❌ Modal element not found!");
        return;
    }
    const emNumberModal = new bootstrap.Modal(emNumberModalElement);
  
    let activeEmergencyNumbers = [];
    let emergencyToArchive = null;

    const db = firebase.database();
    const emergencyRef = db.ref("emergency_contacts");

    // ✅ Fetch and listen for real-time emergency number updates
    emergencyRef.on("value", snapshot => {
        if (!snapshot.exists()) {
            tableBody.innerHTML = `<tr><td colspan="3" class="text-center text-danger">No active emergency numbers available.</td></tr>`;
            return;
        }
    
        const emergencyData = snapshot.val();
    
        // Filter only active emergency numbers
        activeEmergencyNumbers = Object.entries(emergencyData)
            .map(([id, emergency]) => ({ id, ...emergency }))
            .filter(emergency => emergency.number_status === "Active"); // Only keep active ones
    
        console.log("Active Emergency Numbers:", activeEmergencyNumbers);
        displayEmergencyNumbers(activeEmergencyNumbers);
    }, error => {
        console.error("❌ Firebase Listener Error:", error);
    });
    
    // ✅ Display Emergency Numbers in Table
    function displayEmergencyNumbers(emergencyNumbers) {
        if (!tableBody) return;

        tableBody.innerHTML = "";

        if (emergencyNumbers.length === 0) {
            tableBody.innerHTML = `<tr><td colspan="3" class="text-center text-danger">No active emergency numbers available.</td></tr>`;
            return;
        }

        console.log("Active Emergency Numbers:", emergencyNumbers);
        emergencyNumbers.forEach(emergency => {
            let row = `
                <tr>
                    <td>${emergency.number_name || "Unknown"}</td>
                    <td>${emergency.number || "N/A"}</td>
                    <td class="d-flex gap-2">
                        <button class="btn btn-warning update-btn-emergency" data-id="${emergency.id}">Update</button>
                        <button class="btn btn-danger archive-btn-emergency" data-id="${emergency.id}">Archive</button>
                    </td>
                </tr>
            `;
            tableBody.insertAdjacentHTML("beforeend", row);
        });

        attachEventListeners();
    }

    // ✅ Attach Click Events
    function attachEventListeners() {
        document.querySelectorAll(".update-btn-emergency").forEach(btn =>
            btn.onclick = () => openUpdateEmergencyModal(btn.dataset.id));

        document.querySelectorAll(".archive-btn-emergency").forEach(btn =>
            btn.onclick = () => openArchiveEmergencyModal(btn.dataset.id));
    }

    async function openUpdateEmergencyModal(emergencyId) {
        try {
            // Reference to emergency data in Firebase
            const emergencyRef = firebase.database().ref(`emergency_contacts/${emergencyId}`);
            const emergencySnapshot = await emergencyRef.once("value");

            if (!emergencySnapshot.exists()) {
                alert("❌ Emergency number not found!");
                return;
            }

            const emergencyData = emergencySnapshot.val();

            // Populate modal fields with emergency number data
            document.getElementById("updateEmergencyIdEmNumber").value = emergencyId;
            document.getElementById("updateEmergencyNameEmNumber").value = emergencyData.number_name;
            document.getElementById("updateEmergencyNumberEmNumber").value = emergencyData.number;

            // Show Update Emergency Modal
            const updateModalElement = document.getElementById("updateEmergencyModalEmNumber");
            const updateEmergencyModalInstance = new bootstrap.Modal(updateModalElement);
            updateEmergencyModalInstance.show();
        } catch (error) {
            console.error("❌ Error loading emergency number data:", error);
            alert("❌ Failed to load emergency number data.");
        }
    }

    // Handle emergency number update submission
    updateEmergencyForm.addEventListener("submit", async function (event) {
        event.preventDefault();
    
        const emergencyId = document.getElementById("updateEmergencyIdEmNumber").value;
        const updatedName = document.getElementById("updateEmergencyNameEmNumber").value.trim();
        const updatedNumberInput = document.getElementById("updateEmergencyNumberEmNumber");
        const updatedNumberValue = updatedNumberInput.value.trim();
    
        // Clear previous error state
        updatedNumberInput.classList.remove("is-invalid");
    
        if (!updatedName || !updatedNumberValue) {
            alert("❌ Please fill in all required fields.");
            return;
        }
    
        const phoneRegex = /^\+639\d{9}$/;
        if (!phoneRegex.test(updatedNumberValue)) {
            updatedNumberInput.classList.add("is-invalid");
            return;
        }
    
        try {
            const emergencyRef = firebase.database().ref(`emergency_contacts/${emergencyId}`);
            await emergencyRef.update({
                number_name: updatedName,
                number: updatedNumberValue,
                updated_at: new Date().toISOString(),
            });
    
            alert("✅ Emergency number updated successfully!");
    
            const modalElement = document.getElementById("updateEmergencyModalEmNumber");
            const modalInstance = bootstrap.Modal.getInstance(modalElement);
            if (modalInstance) modalInstance.hide();
        } catch (error) {
            console.error("❌ Error updating emergency number:", error);
            alert("❌ Failed to update emergency number. Please try again.");
        }
    });
    
    // Function to open Archive Modal and store emergency number ID
    function openArchiveEmergencyModal(emergencyId) {
        // Select the modals
        const archiveModalElement = document.getElementById("archiveEmergencyModal");
        const emergencyModalElement = document.getElementById("emergencyModalEmNumber"); // Modal to hide
        const archiveEmergencyIdField = document.getElementById("archiveEmergencyIdEmNumber");
    
        console.log("Opening Archive Modal");
        if (!archiveModalElement) {
            console.error("❌ Error: Archive modal element not found!");
            return;
        }
    
        if (!archiveEmergencyIdField) {
            console.error("❌ Error: Archive emergency ID element not found!");
            return;
        }
    
        // Hide the emergency modal if it's open
        let emergencyModalInstance = null;
        if (emergencyModalElement) {
            emergencyModalInstance = bootstrap.Modal.getInstance(emergencyModalElement);
            if (emergencyModalInstance) {
                emergencyModalInstance.hide();
            }
        }
    
        // Store emergency ID in the hidden input field
        archiveEmergencyIdField.value = emergencyId;
    
        // Show the archive modal
        const archiveEmergencyModalInstance = new bootstrap.Modal(archiveModalElement);
        archiveEmergencyModalInstance.show();
    
        // Listen for when the archive modal is closed and reopen emergency modal
        archiveModalElement.addEventListener("hidden.bs.modal", function () {
            if (emergencyModalInstance) {
                emergencyModalInstance.show();
            }
        }, { once: true }); // `once: true` ensures the event listener runs only once
    }
    
    

    // Function to confirm the archive action
    async function confirmArchiveEmergency() {

        const number_ID = document.getElementById("archiveEmergencyIdEmNumber").value;
        
        if (!number_ID) {
            alert("❌ Error: Emergency Number ID is missing!");
            return;
        }

        try {
            // Reference to Firebase hospital record
            const numberRef = firebase.database().ref(`emergency_contacts/${number_ID}`);

            // Update hospital status to "Archived"
            await numberRef.update({
                number_status: "Archived",
                archived_at: new Date().toISOString(),
            });

            // Hide Archive Modal
            const archiveModalElement = document.getElementById("archiveEmergencyModal");
            const archiveModalInstance = bootstrap.Modal.getInstance(archiveModalElement);
            if (archiveModalInstance) archiveModalInstance.hide();

            // Show Success Modal
            const successModalElement = document.getElementById("successArchiveEmergencyIdEmNumber");
            const successModalInstance = new bootstrap.Modal(successModalElement);
            successModalInstance.show();
            
        } catch (error) {
            console.error("❌ Error archiving hospital:", error);
            alert("❌ Failed to archive the hospital. Please try again.");
        }
    }
    
    document.getElementById("confirmArchive-btn-number").addEventListener("click", async function () {
        await confirmArchiveEmergency(); // Call the archive function asynchronously
    });

    addEmNumberModalElement.addEventListener("show.bs.modal", function () {
        emNumberModal.hide();
        removeModalBackdrop(); // 👈 Remove dark background
    });
    
    addEmNumberModalElement.addEventListener("hidden.bs.modal", function () {
        emNumberModal.show();
    });
    
    emNumberArchiveModalElement.addEventListener("show.bs.modal", function () {
        emNumberModal.hide();
        removeModalBackdrop(); // 👈 Remove dark background
    });
    
    emNumberArchiveModalElement.addEventListener("hidden.bs.modal", function () {
        emNumberModal.show();
    });
    
    
    
    function removeModalBackdrop() {
        const backdrop = document.querySelector('.modal-backdrop');
        if (backdrop) {
            backdrop.remove();
        }
    }
    

});
