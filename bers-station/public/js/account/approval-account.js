document.addEventListener("DOMContentLoaded", function () {
    const tableBody = document.getElementById("approvalTableBody");
    const searchInput = document.getElementById("searchApproval");

    // ✅ Modal Elements
    const confirmApprovalModal = document.getElementById("confirmApprovalModal");
    const successApprovalModal = document.getElementById("successApprovalModal");
    const confirmRejectModal = document.getElementById("confirmRejectModal");
    const successRejectModal = document.getElementById("successRejectModal");

    const closeConfirmModalApproval = document.getElementById("close-confirm-modal-approval");
    const cancelConfirmModalApproval = document.getElementById("cancel-confirm-modal-approval");
    const closeSuccessModalApproval = document.getElementById("close-success-modal-approval");
    const confirmActivateBtnApproval = document.getElementById("confirmActivateBtn-approval");

    const closeConfirmModalReject = document.getElementById("close-confirm-modal-reject");
    const cancelConfirmModalReject = document.getElementById("cancel-confirm-modal-reject");
    const closeSuccessModalReject = document.getElementById("close-success-modal-reject");
    const confirmActivateBtnReject = document.getElementById("confirmActivateBtn-reject");

    let approvalUsers = [];
    let selectedUserKey = null;

    const usersRef = firebase.database().ref("users");

    usersRef.on("value", async snapshot => {
        const usersData = snapshot.val();
    
        approvalUsers = usersData
            ? Object.entries(usersData).map(([id, user]) => ({ id, ...user }))
                .filter(user => user.user_status === "Pending")
            : [];
    
        await loadTable(approvalUsers);
    });
    
    /** ✅ Load Users into Table */
    async function loadTable(users) {
        tableBody.innerHTML = "";
    
        // Fetch all emergency responder stations
        const stationsRef = firebase.database().ref("emergency_responder_station");
        const stationsSnapshot = await stationsRef.once("value");
        const stationsData = stationsSnapshot.val() || {}; // Convert to object
        console.log("📌 Fetched Stations Data:", stationsData); // Debugging station data
    
        // ✅ Fetch all users again to ensure we have the full list
        const allUsersRef = firebase.database().ref("users");
        const allUsersSnapshot = await allUsersRef.once("value");
        const allUsersData = allUsersSnapshot.val() || {};
    
        // ✅ Convert all users into a dictionary for quick lookup by user ID
        const usersMap = Object.entries(allUsersData).reduce((acc, [id, user]) => {
            acc[id] = { id, ...user };
            return acc;
        }, {});
    
        users.forEach(user => {
            let stationName = "Unknown Station";
    
            const creatorId = user.created_by;
    
            if (creatorId && usersMap.hasOwnProperty(creatorId)) {
                const creatorStationId = usersMap[creatorId].station_id; 

                if (creatorStationId && stationsData[creatorStationId]) {
                    stationName = stationsData[creatorStationId].station_name;
                    console.log("✅ Matched Station Name:", stationName); 
                } else {

                }
            } else {

            }
    
            let row = `
                <tr data-user-id="${user.id}">
                    <td>${user.f_name} ${user.l_name}</td>
                    <td><a href="mailto:${user.email}">${user.email}</a></td>
                    <td>${user.user_contact}</td>
                    <td>${user.user_role}</td>
                    <td>${stationName}</td>
                    <td style="display: flex; gap: 10px; ">
                        <span class="text-default fw-semibold">Pending for Approval</span>
                    </td>
                </tr>
            `;
            tableBody.insertAdjacentHTML("beforeend", row);
        });
    
        document.querySelectorAll(".approval-btn-user").forEach(button => {
            button.addEventListener("click", function () {
                selectedUserKey = this.getAttribute("data-key");
                showConfirmModalApproval();
            });
        });
    
        document.querySelectorAll(".reject-btn-user").forEach(button => {
            button.addEventListener("click", function () {
                selectedUserKey = this.getAttribute("data-key");
                showConfirmModalReject();
            });
        });
    }
    

    /** ✅ Search Functionality */
    function searchUsers() {
        const searchText = searchInput.value.toLowerCase();

        // ✅ Filter deactivatedUsers based on search query
        const filteredUsers = deactivatedUsers.filter(user => 
            user.fullname.toLowerCase().includes(searchText) ||
            user.email.toLowerCase().includes(searchText) ||
            user.phone.includes(searchText) ||
            user.user_role.toLowerCase().includes(searchText)
        );

        // ✅ Refresh the table with the filtered users
        loadTable(filteredUsers);
    }

    // ✅ Listen for search input changes
    searchInput.addEventListener("input", searchUsers);

    /** ✅ Show Confirmation Modal */
    function showConfirmModalApproval() {
        confirmApprovalModal.style.display = "flex";
    }

    /** ✅ Hide Confirmation Modal */
    function hideConfirmModalApproval() {
        confirmApprovalModal.style.display = "none";
    }

    function showConfirmModalReject() {
        confirmRejectModal.style.display = "flex";
    }

    /** ✅ Hide Confirmation Modal */
    function hideConfirmModalReject() {
        confirmRejectModal.style.display = "none";
    }

    /** ✅ Activate User via Firebase */
    async function approvalUser() {
        showLoadingModal();
        if (!selectedUserKey) {
            console.error("No user selected for approval.");
            return;
        }

        try {
            await firebase.database().ref(`users/${selectedUserKey}`).update({ user_status: "Active" });
            hideConfirmModalApproval();
            showSuccessModalApproval();
        } catch (error) {
            console.error("Error approving user:", error);
            alert("Approval failed. Please try again.");
        } finally {
            hideLoadingModal();
        }
    }

    async function rejectUser() {
        showLoadingModal();
    
        if (!selectedUserKey) {
            console.error("No user selected for rejection.");
            hideLoadingModal();
            return;
        }
    
        try {
            // Get user data from Firebase Realtime Database
            const userSnapshot = await firebase.database().ref(`users/${selectedUserKey}`).once("value");
            const userData = userSnapshot.val();
    
            if (!userData) {
                throw new Error("User not found in database.");
            }
    
            // Update user_status to "Archive"
            await firebase.database().ref(`users/${selectedUserKey}`).update({ user_status: "Archived" });
    
            hideConfirmModalReject();
            showRejectModal();
        } catch (error) {
            console.error("Error rejecting user:", error);
            alert("Rejection failed. Please try again.");
        } finally {
            hideLoadingModal();
        }
    }
    
    

    /** ✅ Show Success Modal */
    function showSuccessModalApproval() {
        successApprovalModal.style.display = "flex";
        setTimeout(() => {
            successApprovalModal.style.display = "none";
        }, 2000);
    }

    function showRejectModal() {
        successRejectModal.style.display = "flex";
        setTimeout(() => {
            successApprovalModal.style.display = "none";
        }, 2000);
    }
    function showLoadingModal() {
        document.getElementById('loadingModal').style.display = 'block';
    }

    function hideLoadingModal() {
        document.getElementById('loadingModal').style.display = 'none';
    }

    /** ✅ Assign Click Event to "Yes" Button in Modal */
    confirmActivateBtnApproval.addEventListener("click", approvalUser);
    confirmActivateBtnReject.addEventListener("click", rejectUser);

    /** ✅ Close Confirmation Modal */
    cancelConfirmModalApproval.addEventListener("click", hideConfirmModalApproval);
    closeConfirmModalApproval.addEventListener("click", hideConfirmModalApproval);
    cancelConfirmModalReject.addEventListener("click", hideConfirmModalReject);
    closeConfirmModalReject.addEventListener("click", hideConfirmModalReject);

    /** ✅ Close Success Modal */
    closeSuccessModalApproval.addEventListener("click", () => successApprovalModal.style.display = "none");
    closeSuccessModalReject.addEventListener("click", () => successRejectModal.style.display = "none");
});
