document.addEventListener("DOMContentLoaded", function () {
    console.log("✅ Firebase Hospital Management Script Loaded!");

    const tableBody = document.getElementById("hospitalList");
    const searchInput = document.getElementById("searchHospital");

    const updateHospitalForm = document.getElementById("updateHospitalForm");
    const updateHospitalModal = document.getElementById("updateHospitalModal");

    const confirmArchiveModal = document.getElementById("confirmArchiveModal");
    const successArchiveModal = document.getElementById("successArchiveModal");

    const closeConfirmModal = document.getElementById("close-confirm-modal-archive");
    const cancelConfirmModal = document.getElementById("cancel-confirm-modal-archive");
    const closeSuccessModal = document.getElementById("close-success-modal-archive");
    const confirmArchiveBtn = document.getElementById("confirmArchiveBtn");

    const hospitalModalElement = document.getElementById("hospitalModal");
    const addHospitalModalElement = document.getElementById("addHospitalModal");

    const hospitalModal = new bootstrap.Modal(hospitalModalElement);
    const addHospitalModal = new bootstrap.Modal(addHospitalModalElement);
    let addHospitalModalInstance;
    let updateHospitalModalInstance; 
    let archiveHospitalModalInstance; 

    let activeHospitals = [];
    let hospitalToArchive = null;

    const db = firebase.database();
    const hospitalRef = db.ref("hospitals");

    // ✅ Fetch and listen for real-time hospital updates
    hospitalRef.on("value", snapshot => {
        if (!snapshot.exists()) {
            tableBody.innerHTML = `<tr><td colspan="3" class="text-center text-danger">No active hospitals available.</td></tr>`;
            return;
        }

        const hospitalsData = snapshot.val();

        activeHospitals = Object.entries(hospitalsData)
            .map(([id, hospital]) => ({ id, ...hospital }))
            .filter(hospital => hospital.hospital_status === "Active");

        console.log("Active Hospitals:", activeHospitals);
        displayHospitals(activeHospitals);
    }, error => {
        console.error("❌ Firebase Listener Error:", error);
    });


    // ✅ Display Hospitals in Table
    function displayHospitals(hospitals) {
        if (!tableBody) return;

        tableBody.innerHTML = "";

        if (hospitals.length === 0) {
            tableBody.innerHTML = `<tr><td colspan="3" class="text-center text-danger">No active hospitals available.</td></tr>`;
            return;
        }

        console.log("Active Hospitals:", hospitals);
        hospitals.forEach(hospital => {
            let row = `
                <tr>
                    <td>${hospital.name || "Unknown"}</td>
                    <td>${hospital.address || "N/A"}</td>
                    <td class="d-flex gap-2">
                        <button class="btn btn-primary view-btn-hospital" data-id="${hospital.id}">View</button>
                        <button class="btn btn-warning update-btn-hospital" data-id="${hospital.id}">Update</button>
                        <button class="btn btn-danger archive-btn-hospital" data-id="${hospital.id}">Archive</button>
                    </td>

                </tr>
            `;
            tableBody.insertAdjacentHTML("beforeend", row);
        });

        attachEventListeners();
    }

    // ✅ Attach Click Events
    function attachEventListeners() {
        document.querySelectorAll(".update-btn-hospital").forEach(btn =>
            btn.onclick = () => openUpdateHospitalModal(btn.dataset.id));

        document.querySelectorAll(".archive-btn-hospital").forEach(btn =>
            btn.onclick = () => openArchiveHospitalModal(btn.dataset.id));

        document.querySelectorAll(".view-btn-hospital").forEach(btn =>
            btn.onclick = () => viewHospital(btn.dataset.id));
    }

    async function openUpdateHospitalModal(hospitalId) {
        try {
            // Close Add Hospital Modal if open
            const addHospitalModalElement = document.getElementById("hospitalModal");
            addHospitalModalInstance = bootstrap.Modal.getInstance(addHospitalModalElement);
            if (addHospitalModalInstance) addHospitalModalInstance.hide();

            // Reference to hospital data in Firebase
            const hospitalRef = firebase.database().ref(`hospitals/${hospitalId}`);
            const hospitalSnapshot = await hospitalRef.once("value");

            if (!hospitalSnapshot.exists()) {
                alert("❌ Hospital not found!");
                return;
            }

            const hospitalData = hospitalSnapshot.val();

            // Populate modal fields with hospital data
            document.getElementById("updateHospitalId").value = hospitalId;
            document.getElementById("updateHospitalName").value = hospitalData.name;
            document.getElementById("updateHospitalAddress").value = hospitalData.address;
            
            // Fetch contact numbers
            const contactNumbersRef = firebase.database().ref("hospital_contact_number");
            const contactSnapshot = await contactNumbersRef
                .orderByChild("hospital_id")
                .equalTo(hospitalId)
                .once("value");

            const contactContainer = document.getElementById("updateContactNumbersContainer");
            contactContainer.innerHTML = ""; // Clear previous data

            if (contactSnapshot.exists()) {
                contactSnapshot.forEach(childSnapshot => {
                    const contactData = childSnapshot.val();
                    const contactId = childSnapshot.key;

                    const div = document.createElement("div");
                    div.classList.add("input-group", "mb-2");
                    div.innerHTML = `
                        <input type="text" class="form-control update-contact-number" data-contact-id="${contactId}" value="${contactData.contact_number}" required>
                    `;
                    contactContainer.appendChild(div);
                });
            }

            // Show Update Hospital Modal
            const updateModalElement = document.getElementById("updateHospitalModal");
            updateHospitalModalInstance = new bootstrap.Modal(updateModalElement);
            updateHospitalModalInstance.show();

            // When Update Modal is closed, reopen Add Hospital Modal
            updateModalElement.addEventListener("hidden.bs.modal", function () {
                if (addHospitalModalInstance) {
                    addHospitalModalInstance.show();
                }
            });

        } catch (error) {
            console.error("❌ Error loading hospital data:", error);
            alert("❌ Failed to load hospital data.");
        }
    }

    // Handle hospital update submission
    document.getElementById("updateHospitalForm").addEventListener("submit", async function (event) {
        event.preventDefault();

        const hospitalId = document.getElementById("updateHospitalId").value;
        const updatedName = document.getElementById("updateHospitalName").value.trim();
        const updatedAddress = document.getElementById("updateHospitalAddress").value.trim();
        const updatedContacts = document.querySelectorAll(".update-contact-number");

        if (!updatedName || !updatedAddress || updatedContacts.length === 0) {
            alert("❌ Please fill in all required fields and add at least one contact number.");
            return;
        }

        try {
            // Update hospital data in Firebase
            const hospitalRef = firebase.database().ref(`hospitals/${hospitalId}`);
            await hospitalRef.update({
                name: updatedName,
                address: updatedAddress,
                updated_at: new Date().toISOString(),
            });

            // Update contact numbers
            const contactNumbersRef = firebase.database().ref("hospital_contact_number");

            for (const input of updatedContacts) {
                const contactId = input.getAttribute("data-contact-id");
                const newContactNumber = input.value.trim();

                if (newContactNumber) {
                    await contactNumbersRef.child(contactId).update({
                        contact_number: newContactNumber,
                        updated_at: new Date().toISOString(),
                    });
                }
            }

            alert("✅ Hospital updated successfully!");

            // Hide modal after submission
            if (updateHospitalModalInstance) {
                updateHospitalModalInstance.hide();
            }
        } catch (error) {
            console.error("❌ Error updating hospital:", error);
            alert("❌ Failed to update hospital. Please try again.");
        }
    });

    
    // Handle adding new contact fields dynamically
    document.getElementById("addUpdateContactNumber").addEventListener("click", function () {
        const contactContainer = document.getElementById("updateContactNumbersContainer");

        const div = document.createElement("div");
        div.classList.add("input-group", "mb-2");

        div.innerHTML = `
            <input type="text" class="form-control update-contact-number" required>
            <button type="button" class="btn btn-danger remove-update-contact">&times;</button>
        `;

        contactContainer.appendChild(div);
    });
    
    // Handle removing contact fields dynamically
    document.getElementById("updateContactNumbersContainer").addEventListener("click", function (e) {
        if (e.target.classList.contains("remove-update-contact")) {
            e.target.parentElement.remove();
        }
    });
    
    // Function to open Archive Modal and store hospital ID
    function openArchiveHospitalModal(hospitalId) {
        // Close the Add Hospital Modal if open
        const addHospitalModalElement = document.getElementById("hospitalModal");
        addHospitalModalInstance = bootstrap.Modal.getInstance(addHospitalModalElement);
        if (addHospitalModalInstance) {
            addHospitalModalInstance.hide();
        }
    
        document.getElementById("archiveHospitalId").value = hospitalId;
        
        // Show Archive Modal
        const archiveModalElement = document.getElementById("archiveHospitalModal");
        archiveHospitalModalInstance = new bootstrap.Modal(archiveModalElement);
        archiveHospitalModalInstance.show();
    
        // When Archive Modal is closed, reopen Add Hospital Modal
        archiveModalElement.addEventListener("hidden.bs.modal", function () {
            if (addHospitalModalInstance) {
                addHospitalModalInstance.show();
            }
        });
    }
    // Function to archive the hospital
    window.confirmArchiveHospital = async function() {
        const hospitalId = document.getElementById("archiveHospitalId").value;
        console.log("Attempting to archive...");
        if (!hospitalId) {
            alert("❌ Error: Hospital ID is missing!");
            return;
        }
    
        try {
            // Correct the template literal syntax for referencing Firebase
            const hospitalRef = firebase.database().ref(`hospitals/${hospitalId}`);
    
            // Update hospital status to "Archived"
            await hospitalRef.update({
                hospital_status: "Archived",
                archived_at: new Date().toISOString(),
            });
    
            // Hide Archive Modal
            const archiveModalElement = document.getElementById("archiveHospitalModal");
            const archiveModalInstance = bootstrap.Modal.getInstance(archiveModalElement);
            if (archiveModalInstance) archiveModalInstance.hide();
    
            // Show Success Modal
            const successModalElement = document.getElementById("successModal");
            const successModalInstance = new bootstrap.Modal(successModalElement);
            successModalInstance.show();
            
        } catch (error) {
            console.error("❌ Error archiving hospital:", error);
            alert("❌ Failed to archive the hospital. Please try again.");
        }
    };
    

   // Function to open View Hospital Modal and close Add Hospital Modal
   async function viewHospital(hospitalId) {
       try {
           // Close Add Hospital Modal if open
           const addHospitalModalElement = document.getElementById("hospitalModal");
           addHospitalModalInstance = bootstrap.Modal.getInstance(addHospitalModalElement);
           if (addHospitalModalInstance) {
               addHospitalModalInstance.hide();
           }
   
           // Reference to hospital data in Firebase
           const hospitalRef = firebase.database().ref(`hospitals/${hospitalId}`);
           const hospitalSnapshot = await hospitalRef.once("value");
   
           if (!hospitalSnapshot.exists()) {
               alert("❌ Hospital not found!");
               return;
           }
   
           const hospitalData = hospitalSnapshot.val();
   
           // Set hospital details in modal
           document.getElementById("viewHospitalName").innerText = hospitalData.name;
           document.getElementById("viewHospitalAddress").innerText = hospitalData.address;
   
           // Reference to contact numbers collection
           const contactNumbersRef = firebase.database().ref("hospital_contact_number");
           const contactSnapshot = await contactNumbersRef
               .orderByChild("hospital_id")
               .equalTo(hospitalId)
               .once("value");
   
           const contactList = document.getElementById("viewHospitalContacts");
           contactList.innerHTML = ""; // Clear previous data
   
           if (contactSnapshot.exists()) {
               contactSnapshot.forEach(childSnapshot => {
                   const contactData = childSnapshot.val();
                   const li = document.createElement("li");
                   li.classList.add("list-group-item");
                   li.innerText = contactData.contact_number;
                   contactList.appendChild(li);
               });
           } else {
               const li = document.createElement("li");
               li.classList.add("list-group-item", "text-muted");
               li.innerText = "No contact numbers available.";
               contactList.appendChild(li);
           }
   
           // Show View Hospital Modal
           const viewModalElement = document.getElementById("viewHospitalModal");
           const viewModalInstance = new bootstrap.Modal(viewModalElement);
           viewModalInstance.show();
   
           // When View Hospital Modal is closed, reopen Add Hospital Modal
           viewModalElement.addEventListener("hidden.bs.modal", function () {
               if (addHospitalModalInstance) {
                   addHospitalModalInstance.show();
               }
           });
   
       } catch (error) {
           console.error("❌ Error fetching hospital details:", error);
           alert("❌ Failed to load hospital details. Please try again.");
       }
   }
   

    // ✅ Safe event listener assignments
    if (confirmArchiveBtn) confirmArchiveBtn.addEventListener("click", archiveHospital);
    if (cancelConfirmModal) cancelConfirmModal.addEventListener("click", () => confirmArchiveModal.style.display = "none");
    if (closeConfirmModal) closeConfirmModal.addEventListener("click", () => confirmArchiveModal.style.display = "none");
    if (closeSuccessModal) closeSuccessModal.addEventListener("click", () => successArchiveModal.style.display = "none");

    function showLoadingModal() {
        const loadingModal = document.getElementById('loadingModal');
        if (loadingModal) loadingModal.style.display = 'block';
    }

    function hideLoadingModal() {
        const loadingModal = document.getElementById('loadingModal');
        if (loadingModal) loadingModal.style.display = 'none';
    }

      // Hide hospital modal when "Add Hospital" modal is opened
      addHospitalModalElement.addEventListener("show.bs.modal", function () {
        hospitalModal.hide();
    });

    // Show hospital modal again when "Add Hospital" modal is closed
    addHospitalModalElement.addEventListener("hidden.bs.modal", function () {
        hospitalModal.show();
    });


});

document.addEventListener("DOMContentLoaded", function () {
    const archiveButton = document.getElementById("confirmHospitalArchivebtn");
    console.log("Archive Button: ", archiveButton);  // This should not log `null` if the button exists
    if (archiveButton) {
        archiveButton.addEventListener("click", async function () {
            console.log("Button was clicked!");  // Check if this logs when clicking the button
            await confirmArchiveHospital();
        });
    } else {
        console.error("The archive button was not found!");
    }
});

