document.addEventListener("DOMContentLoaded", function () {
    console.log("✅ Approval Advisory Script Loaded!");

    const tableBody = document.getElementById("advisoryApprovalTableBody");
    const searchInput = document.getElementById("searchAdvisoryApproval");

    const confirmApprovalModalElement = document.getElementById("advisoryConfirmApprovalModal");
    const successApprovalModalElement = document.getElementById("advisorySuccessApprovalModal");
    const confirmRejectModalElement = document.getElementById("advisoryConfirmRejectModal");
    const successRejectModalElement = document.getElementById("advisorySuccessRejectModal");

    const confirmApprovalModal = new bootstrap.Modal(confirmApprovalModalElement);
    const successApprovalModal = new bootstrap.Modal(successApprovalModalElement);
    const confirmRejectModal = new bootstrap.Modal(confirmRejectModalElement);
    const successRejectModal = new bootstrap.Modal(successRejectModalElement);

    let pendingAdvisories = [];
    let advisoryToApprove = null;
    let advisoryToReject = null;

    // ✅ Fetch pending advisories from Firebase Realtime Database
    const advisoriesRef = firebase.database().ref('advisories');
    advisoriesRef.on('value', snapshot => {
        const advisoriesData = snapshot.val();
        pendingAdvisories = advisoriesData
            ? Object.entries(advisoriesData).map(([id, advisory]) => ({ id, ...advisory }))
                .filter(a => a.advisory_status === 'Pending')
            : [];
        displayPendingAdvisories(pendingAdvisories);
    });

    // ✅ Function to Fetch User's Full Name
    async function fetchUserName(uid) {
        try {
            const snapshot = await firebase.database().ref(`users/${uid}`).once("value");
            const userData = snapshot.val();
            return userData ? `${userData.f_name} ${userData.l_name}` : "Unknown Creator";
        } catch (error) {
            console.error("❌ Error fetching user data:", error);
            return "Unknown Creator";
        }
    }

    // ✅ Display Pending Advisories
    async function displayPendingAdvisories(advisories, searchQuery = "") {
        tableBody.innerHTML = "";

        const filteredAdvisories = advisories.filter(advisory =>
            advisory.headline.toLowerCase().includes(searchQuery.toLowerCase())
        ).slice(0, 10);

        if (filteredAdvisories.length === 0) {
            tableBody.innerHTML = `<tr><td colspan="5" class="text-center text-danger">No pending advisories.</td></tr>`;
            return;
        }

        for (const advisory of filteredAdvisories) {
            const creatorName = await fetchUserName(advisory.creator); // Fetch user name

            let row = `
                <tr class="border-b">
                    <td class="p-2">${creatorName}</td>
                    <td class="p-2">${advisory.headline}</td>
                    <td class="p-2">${new Date(advisory.created_at).toLocaleString()}</td>
                    <td class="p-2">
                        <div class="d-flex justify-content-start gap-2">
                            <button class="approve-btn btn btn-success btn-sm" data-id="${advisory.id}">Approve</button>
                            <button class="reject-btn btn btn-danger btn-sm" data-id="${advisory.id}">Reject</button>
                        </div>
                    </td>
                </tr>
            `;

            tableBody.insertAdjacentHTML("beforeend", row);
        }

        attachEventListeners();
    }

    function attachEventListeners() {
        document.querySelectorAll(".approve-btn").forEach(btn =>
            btn.onclick = () => openConfirmApprovalModal(btn.dataset.id));

        document.querySelectorAll(".reject-btn").forEach(btn =>
            btn.onclick = () => openConfirmRejectModal(btn.dataset.id));
    }

    function openConfirmApprovalModal(advisoryId) {
        advisoryToApprove = advisoryId;
        confirmApprovalModal.show();
    }

    function openConfirmRejectModal(advisoryId) {
        advisoryToReject = advisoryId;
        confirmRejectModal.show();
    }

    async function approveAdvisory() {
        if (!advisoryToApprove) return;

        try {
            await firebase.database().ref(`advisories/${advisoryToApprove}`).update({ advisory_status: "Approved" });

            confirmApprovalModal.hide();
            successApprovalModal.show();

            setTimeout(() => {
                successApprovalModal.hide();
            }, 2000);
        } catch (error) {
            console.error("❌ Approval failed:", error);
        }
    }

    async function rejectAdvisory() {
        if (!advisoryToReject) return;

        try {
            await firebase.database().ref(`advisories/${advisoryToReject}`).update({ advisory_status: "Rejected" });

            confirmRejectModal.hide();
            successRejectModal.show();

            setTimeout(() => {
                successRejectModal.hide();
            }, 2000);
        } catch (error) {
            console.error("❌ Rejection failed:", error);
        }
    }

    searchInput.oninput = () => displayPendingAdvisories(pendingAdvisories, searchInput.value);

    document.getElementById("confirmActivateBtn-approval").addEventListener("click", approveAdvisory);
    document.getElementById("confirmActivateBtn-reject").addEventListener("click", rejectAdvisory);
});
