let archiveEmergencyModalInstance;
let confirmActionModalInstance;

document.addEventListener("DOMContentLoaded", function () {
    // Attach event listener to open archived emergency numbers modal
    document.querySelector(".emergency-archive-btn").addEventListener("click", function () {
        openArchivedEmergencyModal();
    });
});

// Function to Open Archived Emergency Numbers Modal
async function openArchivedEmergencyModal() {
    // Load archived emergency numbers
    await loadArchivedEmergencyNumbers();

    // Show Archived Emergency Numbers Modal
    const archiveModalElement = document.getElementById("archivedEmergencyModalEmNumber");
    archiveEmergencyModalInstance = new bootstrap.Modal(archiveModalElement);
    archiveEmergencyModalInstance.show();
}

// Function to Load Archived Emergency Numbers from Firebase
async function loadArchivedEmergencyNumbers() {
    try {
        const emergencyRef = firebase.database().ref("emergency_contacts");
        const snapshot = await emergencyRef.orderByChild("number_status").equalTo("Archived").once("value");

        const tableBody = document.getElementById("archivedEmergencyListEmNumber");
        tableBody.innerHTML = ""; // Clear previous data

        if (!snapshot.exists()) {
            tableBody.innerHTML = `<tr><td colspan="3" class="text-center text-muted">No archived emergency numbers found.</td></tr>`;
            return;
        }

        snapshot.forEach(childSnapshot => {
            const emergency = childSnapshot.val();
            const emergencyId = childSnapshot.key;
        
            let actionButtons = `
                <div class="d-flex gap-2">
                    <button class="btn btn-success btn-sm" onclick="confirmAction('activate', '${emergencyId}')">Activate</button>
                    <button class="btn btn-danger btn-sm" onclick="confirmAction('delete', '${emergencyId}')">Delete</button>
                </div>
            `;
        
            if (emergency.scheduled_delete_at) {
                actionButtons = `
                    <div class="d-flex gap-2">
                        <button class="btn btn-warning btn-sm" onclick="cancelDeleteEmergency('${emergencyId}')">Cancel Delete</button>
                    </div>
                `;
            }
        
            const row = `
                <tr>
                    <td>${emergency.number_name}</td>
                    <td>${emergency.number}</td>
                    <td>${actionButtons}</td>
                </tr>
            `;
        
            tableBody.innerHTML += row;
        });

    } catch (error) {
        console.error("❌ Error loading archived emergency numbers:", error);
        alert("❌ Failed to load archived emergency numbers.");
    }
}

// Function to Show Confirmation Modal (for Activation or Deletion)
function confirmAction(action, emergencyId) {
    const modalTitle = document.getElementById("confirmActionModalLabel");
    const modalBody = document.getElementById("confirmActionModalBody");
    const confirmBtn = document.getElementById("confirmActionBtn");

    modalTitle.textContent = action === "activate" ? "Activate Emergency Number" : "Delete Emergency Number";
    modalBody.textContent = action === "activate" ?
        "Are you sure you want to activate this emergency number?" :
        "Are you sure you want to delete this emergency number? This will be scheduled for deletion in 2 days.";

    confirmBtn.onclick = function() {
        if (action === "activate") {
            activateEmergency(emergencyId);
        } else if (action === "delete") {
            deleteEmergency(emergencyId);
        }
    };

    // Show modal
    const confirmModalElement = document.getElementById("confirmActionModal");
    confirmActionModalInstance = new bootstrap.Modal(confirmModalElement);
    confirmActionModalInstance.show();
}

// Function to Activate an Archived Emergency Number
async function activateEmergency(emergencyId) {
    try {
        const emergencyRef = firebase.database().ref(`emergency_contacts/${emergencyId}`);
        await emergencyRef.update({
            number_status: "Active",
            activated_at: new Date().toISOString(),
        });

        alert("✅ Emergency number is now Active!");
        confirmActionModalInstance.hide();
        loadArchivedEmergencyNumbers(); // Refresh the archived list
    } catch (error) {
        console.error("❌ Error activating emergency number:", error);
        alert("❌ Failed to activate emergency number.");
    }
}

// Function to Schedule an Emergency Number for Deletion in 2 Days
async function deleteEmergency(emergencyId) {
    try {
        const deletionDate = new Date();
        deletionDate.setDate(deletionDate.getDate() + 2); // Schedule for deletion in 2 days

        const emergencyRef = firebase.database().ref(`emergency_contacts/${emergencyId}`);
        await emergencyRef.update({
            scheduled_delete_at: deletionDate.toISOString(),
        });

        alert("⚠️ Emergency number is scheduled for deletion in 2 days.");
        confirmActionModalInstance.hide();
        loadArchivedEmergencyNumbers(); // Refresh the archived list
    } catch (error) {
        console.error("❌ Error scheduling emergency number deletion:", error);
        alert("❌ Failed to schedule emergency number deletion.");
    }
}

// Function to Cancel Scheduled Deletion
async function cancelDeleteEmergency(emergencyId) {
    try {
        const emergencyRef = firebase.database().ref(`emergency_contacts/${emergencyId}`);
        await emergencyRef.update({
            scheduled_delete_at: null, // Remove scheduled deletion
        });

        alert("✅ Emergency number deletion has been canceled!");
        loadArchivedEmergencyNumbers(); // Refresh the archived list
    } catch (error) {
        console.error("❌ Error canceling emergency number deletion:", error);
        alert("❌ Failed to cancel emergency number deletion.");
    }
}

// Function to Auto Delete Emergency Numbers After 2 Days
async function deleteExpiredEmergencies() {
    try {
        const now = new Date().toISOString();
        const emergencyRef = firebase.database().ref("emergency_contacts");

        const snapshot = await emergencyRef.once("value");

        snapshot.forEach(async (childSnapshot) => {
            const emergency = childSnapshot.val();
            const emergencyId = childSnapshot.key;

            if (emergency.scheduled_delete_at && emergency.scheduled_delete_at <= now) {
                await emergencyRef.child(emergencyId).remove();
                console.log(`✅ Emergency number ${emergency.number_name} permanently deleted.`);
            }
        });

    } catch (error) {
        console.error("❌ Error deleting expired emergency numbers:", error);
    }
}

// Run this function periodically (e.g., every 24 hours)
setInterval(deleteExpiredEmergencies, 24 * 60 * 60 * 1000); // Runs once a day
