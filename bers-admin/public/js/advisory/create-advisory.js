document.addEventListener("DOMContentLoaded", function () {

    const advisoryRef = firebase.database().ref("advisories");
    const storageRef = firebase.storage().ref();
    const auth = firebase.auth();

    const advisoryForm = document.getElementById("advisoryForm");
    const submitButton = document.getElementById("submitAdvisoryButton"); // ✅ Ensure your button has this ID
    const advisoryModal = new bootstrap.Modal(document.getElementById("advisoryModal"));
    const successModal = document.getElementById("successAdvisoryModal");
    const endDateInput = document.getElementById("advisoryEndDate"); // 👉 ID of your end date input

    if (endDateInput) {
        const today = new Date().toISOString().split("T")[0];
        endDateInput.setAttribute("min", today);
    }


    const loadingModal = document.getElementById("loadingModal");

    // ✅ Add Event Listener to Submit Button
    if (submitButton) {
        submitButton.addEventListener("click", async function (event) {
            event.preventDefault(); // Prevent form submission from refreshing page
            submitAdvisory(); // Call the function
        });
    } else {
        console.error("❌ Submit button not found! Make sure your button has the correct ID.");
    }

    async function submitAdvisory() {
        showLoadingModal();

        let formData = new FormData(advisoryForm);
        let user = firebase.auth().currentUser;

        if (!user) {
            hideLoadingModal();
            displayErrorsInModal(["You must be logged in to submit an advisory."]);
            return;
        }

        let advisoryData = {
            headline: formData.get("headline").trim(),
            message: formData.get("message").trim(),
            creator: user.uid,
            created_at: new Date().toISOString(),
            end_date: formData.get("end_date"),  // << ADD THIS
            advisory_status: "Active",
            image_url: null,
            file_url: null,
        };
        

        let errors = [];
        if (!advisoryData.headline) errors.push("Headline is required.");
        if (!advisoryData.message) errors.push("Message is required.");
        let imageFile = document.getElementById("advisoryImageInput").files[0];
        if (!imageFile) {
            errors.push("Image is required.");
        }

        if (errors.length > 0) {
            displayErrorsInModal(errors);
            hideLoadingModal();
            return;
        }

        try {
            // ✅ Upload image if selected
            let imageFile = document.getElementById("advisoryImageInput").files[0];
            if (imageFile) {
                const imageRef = storageRef.child(`advisories/images/${Date.now()}_${imageFile.name}`);
                const snapshot = await imageRef.put(imageFile);
                advisoryData.image_url = await snapshot.ref.getDownloadURL();
            }

            // ✅ Upload file if selected
            let file = document.getElementById("advisoryFileInput").files[0];
            if (file) {
                const fileRef = storageRef.child(`advisories/files/${Date.now()}_${file.name}`);
                const snapshot = await fileRef.put(file);
                advisoryData.file_url = await snapshot.ref.getDownloadURL();
            }

            await advisoryRef.push(advisoryData);

            advisoryModal.hide();
            successModal.style.display = "flex";
        
            setTimeout(() => {
                successModal.style.display = "none";
            }, 2000);
            advisoryForm.reset();

        } catch (error) {
            console.error("❌ Error submitting advisory:", error);
            displayErrorsInModal(["Failed to submit advisory. Please try again."]);
        } finally {
            hideLoadingModal();
        }
    }

    function showLoadingModal() {
        if (loadingModal) loadingModal.style.display = 'block';
    }

    function hideLoadingModal() {
        if (loadingModal) loadingModal.style.display = 'none';
    }

    function displayErrorsInModal(errors) {
        let errorContainer = document.getElementById("advisoryErrorContainer");
        let errorList = document.getElementById("advisoryErrorList");

        errorContainer.classList.remove("d-none");
        errorList.innerHTML = "";

        errors.forEach(error => {
            let li = document.createElement("li");
            li.innerText = error;
            errorList.appendChild(li);
        });
    }

    auth.onAuthStateChanged(user => {
        if (user) {
            console.log("✅ Logged in as:", user.email);
        } else {
            console.log("❌ No user is signed in.");
        }
    });
});


document.addEventListener("DOMContentLoaded", function () {
    // Max File Size Limit (5MB)
    const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB

    // Trigger file input when "Picture/Video" button is clicked
    document.getElementById("advisoryImageButton").addEventListener("click", function () {
        document.getElementById("advisoryImageInput").click();
    });

    // Trigger file input when "Attachments" button is clicked
    document.getElementById("advisoryFileButton").addEventListener("click", function () {
        document.getElementById("advisoryFileInput").click();
    });

    // Handle image preview with validation and remove button
    document.getElementById("advisoryImageInput").addEventListener("change", function (event) {
        const previewContainer = document.getElementById("imagePreviewContainer");
        const errorContainer = document.getElementById("advisoryErrorContainer");
        const errorList = document.getElementById("advisoryErrorList");

        previewContainer.innerHTML = ""; // Clear previous previews
        errorContainer.classList.add("d-none"); // Hide previous error messages
        errorList.innerHTML = ""; // Clear error messages

        const files = event.target.files;
        for (let i = 0; i < files.length; i++) {
            const file = files[i];

            // Validate file type (Must be an image)
            if (!file.type.startsWith("image/")) {
                showError("Invalid file format. Please upload an image.");
                continue;
            }

            // Validate file size
            if (file.size > MAX_FILE_SIZE) {
                showError(`"${file.name}" is too large. Max size is 5MB.`);
                continue;
            }

            // If valid, preview the image
            const reader = new FileReader();
            reader.onload = function (e) {
                const imgContainer = document.createElement("div");
                imgContainer.classList.add("position-relative", "d-inline-block");

                const img = document.createElement("img");
                img.src = e.target.result;
                img.classList.add("rounded", "shadow-sm", "me-2");
                img.width = 100;
                img.height = 100;

                // Remove button (without background)
                const removeBtn = document.createElement("button");
                removeBtn.classList.add("btn-close", "position-absolute", "top-0", "end-0");
                removeBtn.onclick = function () {
                    imgContainer.remove();
                };

                imgContainer.appendChild(img);
                imgContainer.appendChild(removeBtn);
                previewContainer.appendChild(imgContainer);
            };
            reader.readAsDataURL(file);
        }
    });

    // Handle file preview with remove button
    document.getElementById("advisoryFileInput").addEventListener("change", function (event) {
        const filePreviewContainer = document.getElementById("filePreviewContainer");
        filePreviewContainer.innerHTML = ""; // Clear previous previews

        const files = event.target.files;
        for (let i = 0; i < files.length; i++) {
            const file = files[i];

            const fileItem = document.createElement("div");
            fileItem.classList.add("d-flex", "align-items-center", "mb-2", "p-2", "border", "rounded");

            const fileName = document.createElement("span");
            fileName.textContent = file.name;
            fileName.classList.add("me-2");

            // Remove button (without background)
            const removeBtn = document.createElement("button");
            removeBtn.classList.add("btn-close");
            removeBtn.onclick = function () {
                fileItem.remove();
            };

            fileItem.appendChild(fileName);
            fileItem.appendChild(removeBtn);
            filePreviewContainer.appendChild(fileItem);
        }
    });

    // Show error message
    function showError(message) {
        const errorContainer = document.getElementById("advisoryErrorContainer");
        const errorList = document.getElementById("advisoryErrorList");
        
        const errorItem = document.createElement("li");
        errorItem.textContent = message;
        errorList.appendChild(errorItem);

        errorContainer.classList.remove("d-none"); // Show error container
    }
});



