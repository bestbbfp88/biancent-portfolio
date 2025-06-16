document.addEventListener("DOMContentLoaded", async function () {
    
    checkAndArchiveAdvisories();

    const tableBody = document.getElementById("activeAdvisoryList");
    const searchInput = document.getElementById("searchAdvisories");
    const viewAdvisoryModal = document.getElementById("viewAdvisoryModal");
    const activeAdvisoryModal = document.getElementById("activeAdvisoryModal");
    const openUpdateAdvisoryModal = document.getElementById("updateAdvisoryModal");
    const confirmArchivebtn = document.getElementById("confirmArchive-btn");
    const closeConfirmArchivebtn = document.getElementById("closeConfirmArchive-btn");
    
    const confirmArchiveModalElement = document.getElementById("confirmArchiveModal");
    const successArchiveModalElement = document.getElementById("successArchiveModal");

    const confirmArchiveModal = new bootstrap.Modal(confirmArchiveModalElement);
    const successArchiveModal = new bootstrap.Modal(successArchiveModalElement);

    const updateEndDateInput = document.getElementById("updateAdvisoryEndDate");

    if (updateEndDateInput) {
        const today = new Date().toISOString().split("T")[0];
        updateEndDateInput.setAttribute("min", today);
    }


    const confirmArchiveBtn = document.getElementById("confirmArchive-btn");

    const successAdvisoryUpdate = document.getElementById("successAdvisoryUpdateModal");
    const submitUpdateBtn = document.getElementById("submitUpdatebtnAdvisory");
    var closeButton = document.getElementById('closeButton');

    const imageInput = document.getElementById("updateAdvisoryImage");
    const fileInput = document.getElementById("updateAdvisoryFile");
    const imagePreviewContainer = document.getElementById("updateImagePreviewContainer");
    const filePreviewContainer = document.getElementById("updateFilePreviewContainer");

    const imagePreview = document.createElement("img");
    imagePreview.style.maxWidth = "150px";
    imagePreview.style.maxHeight = "150px";
    imagePreview.style.borderRadius = "5px";
    imagePreviewContainer.appendChild(imagePreview);

    const filePreviewText = document.createElement("p");
    filePreviewText.style.color = "blue";
    filePreviewContainer.appendChild(filePreviewText);


    let activeAdvisories = [];
    let advisoryToArchive = null;

    const advisoriesRefActive = firebase.database().ref('advisories');
    advisoriesRefActive.on('value', snapshot => {
        const advisoriesData = snapshot.val();

        activeAdvisories = advisoriesData
            ? Object.entries(advisoriesData).map(([id, advisory]) => ({ id, ...advisory }))
                .filter(a => a.advisory_status === 'Active')
            : [];

        displayAdvisories(activeAdvisories);
    });

    async function fetchUserName(uid) {
        try {
            const userSnap = await firebase.database().ref(`users/${uid}`).once("value");
            const userData = userSnap.val();
    
            if (!userData) return "Unknown Creator";
    
            // ✅ Check user role
            if (userData.user_role === "Emergency Responder Station" && userData.station_id) {
                // Fetch station name
                const stationSnap = await firebase.database().ref(`emergency_responder_station/${userData.station_id}`).once("value");
                const stationData = stationSnap.val();
                if (stationData) {
                    return stationData.station_name;
                } else {
                    return "Unknown Station";
                }
            } else {
                // Fallback to f_name + l_name
                return `${userData.f_name || ""} ${userData.l_name || ""}`.trim() || "Unknown Creator";
            }
    
        } catch (error) {
            console.error("❌ Error fetching user data:", error);
            return "Unknown Creator";
        }
    }
    
    
    async function displayAdvisories(advisories, searchQuery = "") {
        tableBody.innerHTML = "";
    
        const filteredAdvisories = advisories.filter(advisory =>
            advisory.headline.toLowerCase().includes(searchQuery.toLowerCase()) ||
            advisory.creator.toLowerCase().includes(searchQuery.toLowerCase())
        ).slice(0, 10);
    
        if (filteredAdvisories.length === 0) {
            tableBody.innerHTML = `<tr><td colspan="4" class="text-center text-danger">No advisories match your search.</td></tr>`;
            return;
        }
    
        for (const advisory of filteredAdvisories) {
            const creatorName = await fetchUserName(advisory.creator);
        
            // 🔥 Calculate Days Left
            let daysLeft = "";
            if (advisory.end_date) {
                const today = new Date();
                const endDate = new Date(advisory.end_date);
                const timeDiff = endDate - today;
                daysLeft = Math.ceil(timeDiff / (1000 * 60 * 60 * 24)); // convert ms to days
        
                if (daysLeft < 0) {
                    daysLeft = "Expired";
                } else {
                    daysLeft = `${daysLeft} day(s) left`;
                }
            } else {
                daysLeft = "No End Date";
            }
        
            let row = `
                <tr class="border-b">
                    <td class="p-2">${advisory.headline}</td>
                    <td class="p-2">${creatorName}</td>
                    <td class="p-2">${new Date(advisory.created_at).toLocaleString()}</td>
                    <td class="p-2">${daysLeft}</td> 
                    <td class="p-2">
                        <div class="d-flex justify-content-start gap-2">
                            <button class="advisory-view-btn btn btn-primary btn-sm" data-id="${advisory.id}">View</button>
                            <button class="advisory-update-btn btn btn-warning btn-sm" data-id="${advisory.id}">Update</button>
                            <button class="advisory-archive-btn btn btn-danger btn-sm" data-id="${advisory.id}">Deactivate</button>
                        </div>
                    </td>
                </tr>
            `;
        
            tableBody.insertAdjacentHTML("beforeend", row);
        }
        
        attachEventListeners(); // Ensure event listeners are attached after rendering
    }
    

    function attachEventListeners() {
        document.querySelectorAll(".advisory-view-btn").forEach(btn =>
            btn.onclick = () => openViewModal(btn.dataset.id));

        document.querySelectorAll(".advisory-update-btn").forEach(btn =>
            btn.onclick = () => openUpdateModal(btn.dataset.id));

        document.querySelectorAll(".advisory-archive-btn").forEach(btn =>
            btn.onclick = () => openConfirmArchiveModal(btn.dataset.id));
    }

    function openViewModal(advisoryId) {
        const advisory = activeAdvisories.find(a => a.id === advisoryId);
        if (!advisory) return alert("❌ Advisory not found!");
    
        document.getElementById("viewModalHeadline").textContent = advisory.headline;
        document.getElementById("viewModalMessage").textContent = advisory.message;
        document.getElementById("viewModalCreation").textContent = advisory.created_at;
    
        const img = document.getElementById("viewModalImage");
        img.src = advisory.image_url || '';
    
        const creatorTextEl = document.getElementById("viewModalCreator");
        creatorTextEl.textContent = "Loading...";
    
        const userRef = firebase.database().ref(`users/${advisory.creator}`);
        userRef.once("value")
        .then(async snapshot => {
            const userData = snapshot.val();
    
            if (!userData) {
                creatorTextEl.textContent = "Unknown Creator";
                return;
            }
    
            // ✅ If Emergency Responder Station, get station name
            if (userData.user_role === "Emergency Responder Station" && userData.station_id) {
                const stationSnap = await firebase.database().ref(`emergency_responder_station/${userData.station_id}`).once("value");
                const stationData = stationSnap.val();
    
                creatorTextEl.textContent = stationData ? stationData.station_name : "Unknown Station";
            } else {
                // ✅ Otherwise use f_name + l_name
                creatorTextEl.textContent = `${userData.f_name || ""} ${userData.l_name || ""}`.trim() || "Unknown Creator";
            }
        })
        .catch(error => {
            console.error("❌ Error fetching user data:", error);
            creatorTextEl.textContent = "Unknown Creator";
        });
    
        toggleModal(viewAdvisoryModal, true);
    }
    

    imageInput.addEventListener("change", function () {
        if (this.files.length > 0) {
            const reader = new FileReader();
            reader.onload = function (e) {
                imagePreview.src = e.target.result;
                imagePreviewContainer.classList.remove("d-none");
            };
            reader.readAsDataURL(this.files[0]);
        }
    });

    // Display file name preview when user selects a file
    fileInput.addEventListener("change", function () {
        if (this.files.length > 0) {
            filePreviewText.textContent = this.files[0].name;
            filePreviewContainer.classList.remove("d-none");
        }
    });

    function openUpdateModal(advisoryId) {
        console.log('Opening Update Modal');
        const advisory = activeAdvisories.find(a => a.id === advisoryId);
        if (!advisory) return alert("❌ Advisory not found!");

        document.getElementById("updateAdvisoryId").value = advisory.id;
        document.getElementById("updateAdvisoryHeadline").value = advisory.headline || "";
        document.getElementById("updateAdvisoryMessage").value = advisory.message || "";

        // Clear previous previews
        imagePreviewContainer.classList.add("d-none");
        filePreviewContainer.classList.add("d-none");
        imagePreview.src = "";
        filePreviewText.textContent = "";

        // Show existing image if available
        if (advisory.image_url) {
            imagePreview.src = advisory.image_url;
            imagePreviewContainer.classList.remove("d-none");
        }

        // Show existing file if available
        if (advisory.file_url) {
            const fileName = advisory.file_url.split('/').pop(); // Extract file name from URL
            filePreviewText.textContent = fileName;
            filePreviewContainer.classList.remove("d-none");
        }

        const updateAdvisoryModal = new bootstrap.Modal(document.getElementById("updateAdvisoryModal"));
        updateAdvisoryModal.show();
    }

    function showSuccessAdvisoryUpdateModal() {
        const successModalElement = document.getElementById("successAdvisoryUpdateModal");
        const successModal = new bootstrap.Modal(successModalElement);
    
        successModal.show();
    
        setTimeout(() => {
            successModal.hide();
        }, 2000);
    }
    
    function showSuccessAdvisoryArchiveModal() {
  
        // Perform archive operation (You can add your Firebase archive logic here)
        setTimeout(() => {
            successArchiveModal.show(); // Show success modal
        }, 500); // Delay to ensure smooth transition

        // Auto-close the success modal after 3 seconds
        setTimeout(() => {
            successArchiveModal.hide();
        }, 3000);
    };
    

    function hideViewModal() {
        toggleModal(viewAdvisoryModal, false);
    }


    function hideConfirmArchiveModal() {
        toggleModal(confirmArchiveModal, false);
    }

    function toggleModal(modal, show = true) {
        modal.classList.toggle("hidden", !show);
    }


    async function updateAdvisory() {
        // Initial log to indicate function execution
        console.log("Starting to update advisory...");
    
        // Extract values from input fields
        const id = document.getElementById("updateAdvisoryId").value;
        console.log("ID", id);
     //   const creator = document.getElementById("updateAdvisoryCreator").value.trim();
    //    console.log("creator", creator);
        const headline = document.getElementById("updateAdvisoryHeadline").value.trim();
        console.log("headline", headline);
        const message = document.getElementById("updateAdvisoryMessage").value.trim();
        console.log("message", message);
        // Log extracted values to debug potential issues with form inputs
        console.log(`Advisory Details: ID=${id}, Headline=${headline}, Message=${message}`);
    
        // Validate required fields
        if (!headline || !message) {
            console.log("Validation failed: Missing required fields.");
            alert("❌ Please fill in all required fields.");
            return;
        }
    
        try {
            const endDate = document.getElementById("updateAdvisoryEndDate").value.trim();
            const updatedData = { headline, message, end_date: endDate };

    
            // Get the file input references
            const imageInput = document.getElementById("updateAdvisoryImage");
            const fileInput = document.getElementById("updateAdvisoryFile");
    
            // Process image upload if applicable
            if (imageInput && imageInput.files.length > 0) {
                console.log("Uploading image...");
                updatedData.image_url = await uploadFile(imageInput.files[0], `advisories/${id}/image`);
                console.log("Image uploaded: URL=", updatedData.image_url);
            }
    
            // Process file upload if applicable
            if (fileInput && fileInput.files.length > 0) {
                console.log("Uploading file...");
                updatedData.file_url = await uploadFile(fileInput.files[0], `advisories/${id}/file`);
                console.log("File uploaded: URL=", updatedData.file_url);
            }
    
            // Log the data that will be updated in Firebase
            console.log("Updating Firebase with data: ", updatedData);
    
            // Update the advisory in Firebase
            await firebase.database().ref(`advisories/${id}`).update(updatedData);
            console.log("Advisory updated successfully.");
    
            // Show success message
            showSuccessAdvisoryUpdateModal();
            console.log("Displayed success modal.");
    
            // Hide the update modal
            const updateAdvisoryModalElement = document.getElementById("updateAdvisoryModal");
            const updateAdvisoryModal = bootstrap.Modal.getInstance(updateAdvisoryModalElement);
            if (updateAdvisoryModal) {
                updateAdvisoryModal.hide();
                console.log("Update advisory modal hidden.");
            }
        } catch (error) {
            // Log detailed error if update fails
            console.error("❌ Update failed:", error);
            alert("❌ Update failed. Please try again.");
        }
    }
    

    async function uploadFile(file, path) {
        const storageRef = firebase.storage().ref(path);
        const uploadTask = storageRef.put(file);

        return new Promise((resolve, reject) => {
            uploadTask.on("state_changed",
                snapshot => {},
                error => reject(error),
                async () => {
                    const downloadURL = await uploadTask.snapshot.ref.getDownloadURL();
                    resolve(downloadURL);
                }
            );
        });
    }

    function openConfirmArchiveModal(advisoryId) {
        advisoryToArchive = advisoryId;
        confirmArchiveModal.show();
    }

    async function confirmArchive() {
        if (!advisoryToArchive) return;
    
        try {
            const snapshot = await firebase.database().ref(`advisories/${advisoryToArchive}`).once("value");
            const advisory = snapshot.val();
            
            if (!advisory) {
                alert("❌ Advisory not found.");
                return;
            }
    
            const today = new Date().toISOString().split("T")[0];
            const endDate = advisory.end_date || today;
    
            if (today < endDate) {
                alert(`⚠️ You cannot deactivate this advisory yet.\nThe end date is ${endDate}.`);
                return;
            }
    
            await firebase.database().ref(`advisories/${advisoryToArchive}`).update({
                advisory_status: "Archived",
                archived_at: new Date().toISOString()
            });
    
            confirmArchiveModal.hide();
            showSuccessAdvisoryArchiveModal();
    
        } catch (error) {
            console.error("❌ Archive failed:", error);
            alert("❌ Failed to archive advisory.");
        }
    }
    

    searchInput.oninput = () => displayAdvisories(activeAdvisories, searchInput.value);
    closeButton.addEventListener('click', hideViewModal);
    submitUpdateBtn.addEventListener("click", updateAdvisory);
    confirmArchivebtn.addEventListener("click", confirmArchive);
  //  closeConfirmArchivebtn.addEventListener("click", hideConfirmArchiveModal);

    document.getElementById("updateAdvisoryImageButton").addEventListener("click", function () {
        imageInput.click();
    });

    document.getElementById("updateAdvisoryFileButton").addEventListener("click", function () {
        fileInput.click();
    });

});

async function checkAndArchiveAdvisories() {
    const snapshot = await firebase.database().ref("advisories").once("value");
    const advisories = snapshot.val();

    if (!advisories) return;

    const today = new Date().toISOString().split("T")[0]; // Get today's date only (YYYY-MM-DD)

    for (let [id, advisory] of Object.entries(advisories)) {
        if (advisory.end_date && advisory.advisory_status === "Active") {
            if (today > advisory.end_date) {
                // ✅ Archive the advisory
                await firebase.database().ref(`advisories/${id}`).update({
                    advisory_status: "Archived",
                    archived_at: new Date().toISOString()
                });
                console.log(`📦 Advisory ${id} moved to Archived.`);
            }
        }
    }
}
