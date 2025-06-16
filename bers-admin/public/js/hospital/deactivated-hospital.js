let addHospitalModalInstance; // Store instance of Add Hospital Modal
let archiveHospitalModalInstance; // Store instance of Archive Modal

document.addEventListener("DOMContentLoaded", function () {
    // Attach event listener to open archived hospitals list
    document.querySelector(".hospital-archive-btn").addEventListener("click", function () {
        openArchiveHospitalModal();
    });
});

// Function to Open Archive Hospitals Modal and Hide Add Hospital Modal
async function openArchiveHospitalModal() {
    // Hide Add Hospital Modal if open
    const addHospitalModalElement = document.getElementById("hospitalModal");
    addHospitalModalInstance = bootstrap.Modal.getInstance(addHospitalModalElement);

    if (addHospitalModalInstance) {
        addHospitalModalInstance.hide();
    }

    // Load archived hospitals
    await loadArchivedHospitals();

    // Show Archive Hospitals Modal
    const archiveModalElement = document.getElementById("archivedHospitalsModal");
    archiveHospitalModalInstance = new bootstrap.Modal(archiveModalElement);
    archiveHospitalModalInstance.show();

    // When Archive Modal is closed, reopen Add Hospital Modal
    archiveModalElement.addEventListener("hidden.bs.modal", function () {
        if (addHospitalModalInstance) {
            addHospitalModalInstance.show();
        }
    });
}

// Function to Load Archived Hospitals
async function loadArchivedHospitals() {
    try {
        const hospitalsRef = firebase.database().ref("hospitals");
        const snapshot = await hospitalsRef.orderByChild("hospital_status").equalTo("Archived").once("value");

        const tableBody = document.getElementById("archivedHospitalsTable");
        tableBody.innerHTML = ""; // Clear previous data

        if (!snapshot.exists()) {
            tableBody.innerHTML = `<tr><td colspan="3" class="text-center text-muted">No archived hospitals found.</td></tr>`;
            return;
        }

        snapshot.forEach(childSnapshot => {
            const hospital = childSnapshot.val();
            const hospitalId = childSnapshot.key;
        
            let actionButtons = `
                <div class="d-flex gap-2">
                    <button class="btn btn-success btn-sm" onclick="activateHospital('${hospitalId}')">Activate</button>
                    <button class="btn btn-danger btn-sm" onclick="deleteHospital('${hospitalId}')">Delete</button>
                </div>
            `;
        
            if (hospital.scheduled_delete_at) {
                actionButtons = `
                    <div class="d-flex gap-2">
                        <button class="btn btn-warning btn-sm" onclick="cancelDeleteHospital('${hospitalId}')">Cancel Delete</button>
                    </div>
                `;
            }
        
            const row = `
                <tr>
                    <td>${hospital.name}</td>
                    <td>${hospital.address}</td>
                    <td>${actionButtons}</td>
                </tr>
            `;
        
            tableBody.innerHTML += row;
        });

    } catch (error) {
        console.error("❌ Error loading archived hospitals:", error);
        alert("❌ Failed to load archived hospitals.");
    }
}

// Function to Activate an Archived Hospital
async function activateHospital(hospitalId) {
    try {
        const hospitalRef = firebase.database().ref(`hospitals/${hospitalId}`);
        await hospitalRef.update({
            hospital_status: "Active",
            activated_at: new Date().toISOString(),
        });

        alert("✅ Hospital is now Active!");
        loadArchivedHospitals(); // Refresh the archived list
    } catch (error) {
        console.error("❌ Error activating hospital:", error);
        alert("❌ Failed to activate hospital.");
    }
}

// Function to Schedule a Hospital for Deletion in 2 Days
async function deleteHospital(hospitalId) {
    try {
        const deletionDate = new Date();
        deletionDate.setDate(deletionDate.getDate() + 2); // Schedule for deletion in 2 days

        const hospitalRef = firebase.database().ref(`hospitals/${hospitalId}`);
        await hospitalRef.update({
            scheduled_delete_at: deletionDate.toISOString(),
        });

        alert("⚠️ Hospital is scheduled for deletion in 2 days.");
        loadArchivedHospitals(); // Refresh the archived list
    } catch (error) {
        console.error("❌ Error scheduling hospital deletion:", error);
        alert("❌ Failed to schedule hospital deletion.");
    }
}

// Function to Cancel Scheduled Deletion
async function cancelDeleteHospital(hospitalId) {
    try {
        const hospitalRef = firebase.database().ref(`hospitals/${hospitalId}`);
        await hospitalRef.update({
            scheduled_delete_at: null, // Remove scheduled deletion
        });

        alert("✅ Hospital deletion has been canceled!");
        loadArchivedHospitals(); // Refresh the archived list
    } catch (error) {
        console.error("❌ Error canceling hospital deletion:", error);
        alert("❌ Failed to cancel hospital deletion.");
    }
}

// Function to Auto Delete Hospitals After 2 Days
async function deleteExpiredHospitals() {
    try {
        const now = new Date().toISOString();
        const hospitalsRef = firebase.database().ref("hospitals");

        const snapshot = await hospitalsRef.once("value");

        snapshot.forEach(async (childSnapshot) => {
            const hospital = childSnapshot.val();
            const hospitalId = childSnapshot.key;

            if (hospital.scheduled_delete_at && hospital.scheduled_delete_at <= now) {
                await hospitalsRef.child(hospitalId).remove();
                console.log(`✅ Hospital ${hospital.name} permanently deleted.`);
            }
        });

    } catch (error) {
        console.error("❌ Error deleting expired hospitals:", error);
    }
}

// Run this function periodically (e.g., every 24 hours)
setInterval(deleteExpiredHospitals, 24 * 60 * 60 * 1000); // Runs once a day
