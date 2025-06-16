document.addEventListener("DOMContentLoaded", function () {
    const tableBody = document.getElementById("deactivatedAdvisoryTableBody");
    const searchInput = document.getElementById("searchAdvisoryDeactivated");

    var modal = document.getElementById('deactivatedAdvisoryModal');

    // ✅ Modal Elements
    const confirmActivateModal = document.getElementById("confirmAdvisoryActivateModal");
    const successActivateModal = document.getElementById("successAdvisoryActivateModal");

    const closeConfirmModal = document.getElementById("close-confirm-modal-advisory");
    const cancelConfirmModal = document.getElementById("cancel-confirm-modal-advisory");
    const closeSuccessModal = document.getElementById("close-success-modal-advisory");
    const confirmActivateBtn = document.getElementById("confirmActivateBtn-advisory");

    const closeDeleteModal = document.getElementById("close-delete-modal-advisory");
    const cancelDeleteModal = document.getElementById("cancel-delete-modal-advisory");
    
    const confirmDeleteBtn = document.getElementById("confirmDeleteBtn-advisory");

    if (confirmDeleteBtn) {
        confirmDeleteBtn.addEventListener("click", deleteAdvisory);
    } else {
        console.error("confirmDeleteBtn not found");
    }

   
    modal.addEventListener('click', function(event) {
        if (event.target === this) {
            bootstrap.Modal.getInstance(this).hide();
        }
    });

    let deactivatedAdvisory = [];
    let selectedAdvisoryKey = null;

        const advisoryRef = firebase.database().ref("advisories");

        advisoryRef.on("value", async (snapshot) => {
            const usersData = snapshot.val();
    
            deactivatedAdvisory = usersData
                ? Object.entries(usersData).map(([id, advisory]) => ({ id, ...advisory }))
                    .filter(advisory => advisory.advisory_status === "Archived")
                : [];
    
            await loadDeactivatedAdvisoryTable(deactivatedAdvisory);
        });

    /** ✅ Load Advisories into Table */
    async function loadDeactivatedAdvisoryTable(advisories) {
        tableBody.innerHTML = "";
        const currentTime = Date.now();

        for (let advisory of advisories) {
            

            let isScheduledForDeletion = advisory.scheduled_delete && advisory.scheduled_delete > currentTime;

            let actionButtons = isScheduledForDeletion
                ? `<button class="btn btn-warning cancel-delete-btn-advisory" data-key="${advisory.id}">Cancel Delete</button>`
                : `
                    <div class="d-flex gap-2"> 
                        <button class="btn btn-success activate-btn-advisory" data-key="${advisory.id}">Activate</button>
                        <button class="btn btn-danger delete-btn-advisory" data-key="${advisory.id}">Delete</button>
                    </div>
                `;

            let row = `
                <tr data-advisory-id="${advisory.id}">
                    <td>${advisory.headline}</td>
                    <td>${advisory.created_at}</td>
                    <td>${actionButtons}</td>
                </tr>
            `;
            tableBody.insertAdjacentHTML("beforeend", row);
        }

        // ✅ Add Click Event to "Activate" Buttons
        document.querySelectorAll(".activate-btn-advisory").forEach(button => {
            button.addEventListener("click", function () {
                selectedAdvisoryKey = this.getAttribute("data-key");
                showConfirmModal();
            });
        });

        document.querySelectorAll(".delete-btn-advisory").forEach(button => {
            button.addEventListener("click", function () {
                selectedAdvisoryKey = this.getAttribute("data-key");
        
                console.log("✅ Selected Advisory Key for Deletion (before modal opens):", selectedAdvisoryKey);
        
                if (!selectedAdvisoryKey) {
                    alert("Error: No advisory selected for deletion.");
                    return;
                }
        
                showDeleteModalAdvisory();
            });
        });
        

        document.querySelectorAll(".cancel-delete-btn-advisory").forEach(button => {
            button.addEventListener("click", function () {
                selectedAdvisoryKey = this.getAttribute("data-key");
                cancelScheduledDeletionAdvisory();
            });
        });
    }

    /** ✅ Search Functionality */
    function searchDeactivatedAdvisory() {
        const searchText = searchInput.value.toLowerCase();

        const filteredAdvisory = deactivatedAdvisory.filter(advisory => 
            advisory.headline.toLowerCase().includes(searchText) ||
            advisory.creator.toLowerCase().includes(searchText) ||
            advisory.created_at.includes(searchText) 
        );

        loadDeactivatedAdvisoryTable(filteredAdvisory);
    }

    // ✅ Listen for search input changes
    searchInput.addEventListener("input", searchDeactivatedAdvisory);

    /** ✅ Show Confirmation Modal */
    function showConfirmModal() {
        confirmActivateModal.style.display = "flex";
    }

    /** ✅ Hide Confirmation Modal */
    function hideConfirmModal() {
        confirmActivateModal.style.display = "none";
    }

    function showDeleteModalAdvisory() {
        const deleteModal = new bootstrap.Modal(document.getElementById("confirmDeleteModalAdvisory"));
        deleteModal.show();
    }

    function hideDeleteModal() {
    const deleteModal = bootstrap.Modal.getInstance(document.getElementById("confirmDeleteModalAdvisory"));
    if (deleteModal) {
        deleteModal.hide();
    }

    // ✅ Do NOT reset `selectedAdvisoryKey` here
    console.log("🟠 Hiding delete modal. Keeping selectedAdvisoryKey:", selectedAdvisoryKey);

    // ✅ Restore scrolling (Bootstrap disables it when a modal is open)
    document.body.classList.remove('modal-open');
    document.body.style.overflow = '';
}


    /** ✅ Activate Advisory via Firebase */
    async function activateAdvisory() {
        showLoadingModal();
        if (!selectedAdvisoryKey) {
            console.error("No Advisory selected for activation.");
            return;
        }

        try {
            await firebase.database().ref(`advisories/${selectedAdvisoryKey}`).update({ advisory_status: "Active" });

            hideConfirmModal();
            showSuccessModaldeactivate();
        } catch (error) {
            console.error("Activation failed:", error);
            alert("Activation failed. Please try again.");
        } finally {
            hideLoadingModal();
        }
    }

    async function deleteAdvisory() {
        showLoadingModal();

        try {
            const deleteTimestamp = Date.now() + (2 * 24 * 60 * 60 * 1000); // 2 days in milliseconds
            await firebase.database().ref(`advisories/${selectedAdvisoryKey}`).update({
                scheduled_delete: deleteTimestamp
            });
    
            hideDeleteModal();
        } catch (error) {
            console.error("❌ Error scheduling deletion:", error);
            alert("Failed to schedule deletion. Please try again.");
        } finally {
            hideLoadingModal();
        }
    }
    
    
    /** ✅ Cancel Scheduled Deletion */
    async function cancelScheduledDeletionAdvisory() {
        showLoadingModal();
      
        try {
            await firebase.database().ref(`advisories/${selectedAdvisoryKey}`).update({
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
        const snapshot = await firebase.database().ref("advisories").once("value");

        if (!snapshot.exists()) {
            return;
        }

        const deletePromises = Object.entries(snapshot.val()).map(async ([advisoryId, advisory]) => {

            // ✅ Only check users with "Archived" or "Deactivated" status
            if (advisory.advisory_status !== "Archived" && advisory.advisory_status !== "Deactivated") {
                return;
            }

            if (advisory.scheduled_delete && advisory.scheduled_delete <= currentTime) {

                try {
                    // ✅ Delete from Firebase Realtime Database
                    await firebase.database().ref(`advisories/${advisoryId}`).remove();

                } catch (error) {
                    console.error(`Error deleting user ${advisoryId}:`, error);
                }
            }
        });

        await Promise.all(deletePromises); // ✅ Wait until all users are checked

        console.log(`Total users processed in this cycle: ${deletePromises.length}`);

        // ✅ Keep checking for expired deletions every second
        setTimeout(checkForExpiredDeletions, 1000);
    }

    /** ✅ Show Success Modal */
    function showSuccessModaldeactivate() {
        successActivateModal.style.display = "flex";
        setTimeout(() => {
            successActivateModal.style.display = "none";
        }, 2000);
    }

    function showLoadingModal() {
        document.getElementById('loadingModal').style.display = 'block';
    }

    function hideLoadingModal() {
        document.getElementById('loadingModal').style.display = 'none';
    }

    /** ✅ Assign Click Event to "Yes" Button in Modal */
    confirmActivateBtn.addEventListener("click", activateAdvisory);
    

    /** ✅ Close Confirmation Modal */
    cancelConfirmModal.addEventListener("click", hideConfirmModal);
    closeConfirmModal.addEventListener("click", hideConfirmModal);

    cancelDeleteModal.addEventListener("click", hideDeleteModal);
    closeDeleteModal.addEventListener("click", hideDeleteModal);

    /** ✅ Close Success Modal */
    closeSuccessModal.addEventListener("click", () => successActivateModal.style.display = "none");

    var modalContent = document.querySelector('#deactivatedAdvisoryModal .modal-dialog');
    modalContent.addEventListener('click', function(event) {
        event.stopPropagation();
    });

    checkForExpiredDeletions();
});
