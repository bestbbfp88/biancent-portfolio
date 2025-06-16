document.addEventListener("DOMContentLoaded", function () {
    const tableBody = document.getElementById("deactivatedTableBody");
    const searchInput = document.getElementById("searchDeactivated");

    // ✅ Modal Elements
    const confirmActivateModal = document.getElementById("confirmActivateModal");
    const successActivateModal = document.getElementById("successActivateModal");
    const confirmDeleteModal = document.getElementById("confirmDeleteModal");

    const closeConfirmModal = document.getElementById("close-confirm-modal");
    const cancelConfirmModal = document.getElementById("cancel-confirm-modal");
    const closeSuccessModal = document.getElementById("close-success-modal");
    const confirmActivateBtn = document.getElementById("confirmActivateBtn");

    const closeDeleteModal = document.getElementById("close-delete-modal");
    const cancelDeleteModal = document.getElementById("cancel-delete-modal");
    const closeSuccessDeleteModal = document.getElementById("close-success-delete-modal");

    const confirmDeleteBtn = document.getElementById("confirmDeleteBtn");
    
    if (confirmDeleteBtn) {
        confirmDeleteBtn.addEventListener("click", deleteUser);
    } else {
        console.error("confirmDeleteBtn not found");
    }

    let deactivatedUsers = [];
    let selectedUserKey = null;

    const usersRef = firebase.database().ref("users");

    usersRef.on("value", async (snapshot) => {
        const usersData = snapshot.val();

        deactivatedUsers = usersData
            ? Object.entries(usersData).map(([id, user]) => ({ id, ...user }))
                .filter(user => user.user_status === "Archived")
            : [];

        await loadTable(deactivatedUsers);
    });

    /** ✅ Load Users into Table */
    async function loadTable(users) {
        tableBody.innerHTML = "";
        const currentTime = Date.now();

        for (let user of users) {
            let fullName = `${user.l_name || ""} ${user.f_name || ""}`.trim() || "No Name Provided";

            if (user.user_role === "Emergency Responder Station" && user.station_id) {
                try {
                    const stationSnapshot = await firebase.database().ref(`emergency_responder_station/${user.station_id}`).once("value");
                    const stationData = stationSnapshot.val();
                    if (stationData && stationData.station_name) {
                        fullName = stationData.station_name;
                    }
                } catch (error) {
                    console.error(`Error fetching station name for station_id ${user.station_id}:`, error);
                }
            }
            let isScheduledForDeletion = user.scheduled_delete && user.scheduled_delete > currentTime;

            let actionButtons = isScheduledForDeletion
                ? `<button class="btn btn-warning cancel-delete-btn" data-key="${user.id}">Cancel Delete</button>`
                : `
                    <div class="d-flex gap-2"> 
                        <button class="btn btn-success activate-btn-user" data-key="${user.id}">Activate</button>
                        <button class="btn btn-danger delete-btn-user" data-key="${user.id}">Delete</button>
                    </div>
                `;

            let row = `
                <tr data-user-id="${user.id}">
                    <td>${fullName}</td>
                    <td><a href="mailto:${user.email}">${user.email || "N/A"}</a></td>
                    <td>${user.user_contact || "N/A"}</td>
                    <td>${user.user_role || "N/A"}</td>
                    <td>${actionButtons}</td>
                </tr>
            `;
      
            tableBody.insertAdjacentHTML("beforeend", row);
        }

        document.querySelectorAll(".activate-btn-user").forEach(button => {
            button.addEventListener("click", function () {
                selectedUserKey = this.getAttribute("data-key");
                showConfirmModal();
            });
        });

        document.querySelectorAll(".delete-btn-user").forEach(button => {
            button.addEventListener("click", function () {
                selectedUserKey = this.getAttribute("data-key");
                showDeleteModal();
            });
        });

        document.querySelectorAll(".cancel-delete-btn").forEach(button => {
            button.addEventListener("click", function () {
                selectedUserKey = this.getAttribute("data-key");
                cancelScheduledDeletion();
            });
        });
    }

    /** ✅ Show Confirmation Modal */
    function showConfirmModal() {
        confirmActivateModal.style.display = "flex";
    }

    /** ✅ Hide Confirmation Modal */
    function hideConfirmModal() {
        confirmActivateModal.style.display = "none";
    }

    /** ✅ Show Delete Confirmation Modal */
   /** ✅ Show Delete Confirmation Modal */
    function showDeleteModal() {
        const deleteModal = new bootstrap.Modal(document.getElementById("confirmDeleteModal"));
        deleteModal.show();
    }

    function hideDeleteModal() {
        const deleteModal = bootstrap.Modal.getInstance(document.getElementById("confirmDeleteModal"));
        if (deleteModal) {
            deleteModal.hide();
        }
    

        // ✅ Restore scrolling (Bootstrap disables it when a modal is open)
        document.body.classList.remove('modal-open');
        document.body.style.overflow = '';
    }
    

    /** ✅ Activate User via Firebase */
    async function activateUser() {
        showLoadingModal();
        if (!selectedUserKey) {
            console.error("No user selected for activation.");
            return;
        }

        try {

            const response = await fetch(`/admin/activate-user/${selectedUserKey}`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
                }
            });

            const result = await response.json();

        if (!result.success) {
            console.error("❌ Failed to activate user in Auth:", result.message);
            alert(`❌ Error: ${result.message}`);
            return;  // Stop the process if Auth disabling fails
        }

        console.log("✅ User disabled in Firebase Auth");

            await firebase.database().ref(`users/${selectedUserKey}`).update({ user_status: "Active" });
            hideConfirmModal();
            showSuccessModal("✅ Account Activated!");
        } catch (error) {
        } finally {
            hideLoadingModal();
        }
    }

    async function deleteUser() {
        showLoadingModal();
        if (!selectedUserKey) {
            console.error("No user selected for deletion.");
            return;
        }

        try {
            // ✅ Schedule the deletion for 2 days from now
            const deleteTimestamp = Date.now() + (2 * 24 * 60 * 60 * 1000); // 2 days in milliseconds
            //const deleteTimestamp = Date.now() + (2 * 1000); // ✅ Set deletion time to 2 seconds

            await firebase.database().ref(`users/${selectedUserKey}`).update({
                scheduled_delete: deleteTimestamp
            });

            hideDeleteModal();
            
        } catch (error) {
            console.error("Error scheduling deletion:", error);
            alert("Failed to schedule deletion. Please try again.");
        } finally {
            hideLoadingModal();
        }
    }

    /** ✅ Cancel Scheduled Deletion */
    async function cancelScheduledDeletion() {
        showLoadingModal();
        if (!selectedUserKey) {
            console.error("No user selected for canceling deletion.");
            return;
        }

        try {
            await firebase.database().ref(`users/${selectedUserKey}`).update({
                scheduled_delete: null
            });

            alert("Deletion has been canceled.");
            
        } catch (error) {
            console.error("Error canceling deletion:", error);
            alert("Failed to cancel deletion. Please try again.");
        } finally {
            hideLoadingModal();
        }
    }

  /** ✅ Continuously check for expired deletions */
    async function checkForExpiredDeletions() {
        const currentTime = Date.now();
        const snapshot = await firebase.database().ref("users").once("value");

        if (!snapshot.exists()) {
            return;
        }


        const deletePromises = Object.entries(snapshot.val()).map(async ([userId, user]) => {

            // ✅ Only check users with "Archived" or "Deactivated" status
            if (user.user_status !== "Archived" && user.user_status !== "Deactivated") {
                return;
            }

            if (user.scheduled_delete && user.scheduled_delete <= currentTime) {

                try {
                    // ✅ Delete from Firebase Realtime Database
                    await firebase.database().ref(`users/${userId}`).remove();

                    // ✅ Delete from Firebase Authentication using Admin SDK
                    deleteUserFromAuth(userId);

                } catch (error) {
                    console.error(`Error deleting user ${userId}:`, error);
                }
            }
        });

        await Promise.all(deletePromises);

        // ✅ Keep checking for expired deletions every second
        setTimeout(checkForExpiredDeletions, 1000);
    }

    /** ✅ Delete User from Firebase Authentication using Backend API */
    async function deleteUserFromAuth(userId) {
        try {
            const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

            const response = await fetch('/delete-user/' + userId, {
                method: "DELETE",
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                    "X-CSRF-TOKEN": csrfToken  
                }
            });

            const data = await response.json();
            if (data.success) {
                console.log(`User ${userId} deleted from Firebase Authentication.`);
            } else {
                console.warn(`Failed to delete user ${userId} from Auth:`, data.message);
            }
        } catch (error) {
            console.error(`Error deleting user ${userId} from Auth:`, error);
        }
    }


    function showLoadingModal() {
        document.getElementById('loadingModal').style.display = 'block';
    }

    function hideLoadingModal() {
        document.getElementById('loadingModal').style.display = 'none';
    }

    confirmActivateBtn.addEventListener("click", activateUser);
    confirmDeleteBtn.addEventListener("click", deleteUser);

    cancelConfirmModal.addEventListener("click", hideConfirmModal);
    closeConfirmModal.addEventListener("click", hideConfirmModal);

    cancelDeleteModal.addEventListener("click", hideDeleteModal);
    closeDeleteModal.addEventListener("click", hideDeleteModal);

    closeSuccessModal.addEventListener("click", () => successActivateModal.style.display = "none");

    checkForExpiredDeletions();
});
