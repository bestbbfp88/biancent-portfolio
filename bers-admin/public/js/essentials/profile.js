function cleanNameInput(inputElement) {
  if (inputElement && inputElement.value !== undefined) {
    inputElement.value = inputElement.value
      .replace(/[^a-zA-Z\s\-]/g, "") // Allow only letters, spaces, hyphens
      .replace(/\s{2,}/g, " ")       // Replace multiple spaces with a single space
      .trim();                       // Remove starting/trailing spaces
  }
}

function applyLiveNameValidation(inputElement) {
  if (inputElement) {
    inputElement.addEventListener("input", () => {
      cleanNameInput(inputElement);
    });
  }
}

function applyLiveContactValidation(inputElement) {
  if (inputElement) {
      inputElement.addEventListener("input", () => {
          // Always start with "+63"
          if (!inputElement.value.startsWith("+63")) {
              inputElement.value = "+63";
          }

          // Keep "+63" and allow only digits after
          inputElement.value = "+63" + inputElement.value.substring(3).replace(/[^0-9]/g, "");

          // Limit total length (+63 + 10 numbers = 13 characters)
          if (inputElement.value.length > 13) {
              inputElement.value = inputElement.value.substring(0, 13);
          }
      });
  }
}



function loadDropdownProfile(uid) {
    const userRef = firebase.database().ref("users/" + uid);

    userRef.on("value", snapshot => {
        if (!snapshot.exists()) return;

        const user = snapshot.val();
        document.getElementById("dropdownProfileName").textContent = `${user.f_name} ${user.l_name}`;
        document.getElementById("dropdownProfileRole").textContent = user.user_role || "Unknown";
        document.getElementById("dropdownProfileEmail").textContent = user.email || "N/A";
        document.getElementById("dropdownProfileContact").textContent = user.user_contact || "N/A";
        document.getElementById("dropdownProfileBirthdate").textContent = formatReadableDate(user.birthdate);
        document.getElementById("dropdownProfileGender").textContent = user.gender || "N/A";
    }, error => {
        console.error("❌ Failed to load profile in real-time:", error);
    });
}

// Load on DOM Ready
document.addEventListener("DOMContentLoaded", () => {
    firebase.auth().onAuthStateChanged(user => {
        if (user) {
            loadDropdownProfile(user.uid);
        }
    });
});


function openEditProfileModal() {
    const user = firebase.auth().currentUser;
    if (!user) return;
  
    firebase.database().ref(`users/${user.uid}`).once("value")
      .then(snapshot => {
        const data = snapshot.val();
        if (!data) return;
  
        document.getElementById("editFName").value = data.f_name || "";
        document.getElementById("editLName").value = data.l_name || "";
        document.getElementById("editEmail").value = data.email || user.email || "";
        document.getElementById("editAddress").value = data.address || "";
        document.getElementById("editBirthdate").value = data.birthdate || "";
        document.getElementById("editGender").value = data.gender || "";
        document.getElementById("editContact").value = data.user_contact || "";
  
        applyLiveNameValidation(document.getElementById("editFName"));
        applyLiveNameValidation(document.getElementById("editLName"));
        applyLiveContactValidation(document.getElementById("editContact"));

        const birthdateInput = document.getElementById("editBirthdate");
        if (!birthdateInput.value) {
            const defaultDate = new Date(1990, 0, 1);
            birthdateInput.valueAsDate = defaultDate;
        }

        new bootstrap.Modal(document.getElementById("editProfileModal")).show();
      });
  }
  
  document.addEventListener("DOMContentLoaded", function () {
    const editForm = document.getElementById("editProfileForm");
    if (!editForm) return;
  
    editForm.addEventListener("submit", function (e) {
      e.preventDefault();
      const user = firebase.auth().currentUser;
      if (!user) return;

      let hasError = false;
      
        const birthdateInput = document.getElementById("editBirthdate");
        const birthdateError = document.getElementById("birthdateError");
        birthdateInput.classList.remove("is-invalid");
        birthdateError.style.display = "none";

        // Birthdate validation (18 years old)
        const birthdateValue = birthdateInput.value;
        const birthDateObj = new Date(birthdateValue);
        const today = new Date();
        const age = today.getFullYear() - birthDateObj.getFullYear();
        const monthDiff = today.getMonth() - birthDateObj.getMonth();
        const dayDiff = today.getDate() - birthDateObj.getDate();
        const isOldEnough = age > 18 || (age === 18 && (monthDiff > 0 || (monthDiff === 0 && dayDiff >= 0)));

        if (!birthdateValue || !isOldEnough) {
          birthdateInput.classList.add("is-invalid");
          birthdateError.textContent = "You must be at least 18 years old.";
          birthdateError.style.display = "block";
          return; // stop submission
        }
        
        const contactInput = document.getElementById("editContact");
        const contactError = document.getElementById("contactError");
        contactInput.classList.remove("is-invalid");
        contactError.style.display = "none";

        const contactValue = contactInput.value.trim();
        const contactPattern = /^\+63\d{10}$/;

        if (!contactPattern.test(contactValue)) {
          contactInput.classList.add("is-invalid");
          contactError.textContent = "Contact number must start with +63 followed by 10 digits.";
          contactError.style.display = "block";
          hasError = true;
        }

        if (hasError) return;

      const updates = {
        f_name: document.getElementById("editFName").value,
        l_name: document.getElementById("editLName").value,
        address: document.getElementById("editAddress").value,
        birthdate: document.getElementById("editBirthdate").value,
        gender: document.getElementById("editGender").value,
        user_contact: document.getElementById("editContact").value
      };
  
      firebase.database().ref(`users/${user.uid}`).update(updates)
        .then(() => {
          alert("✅ Profile updated successfully.");
          bootstrap.Modal.getInstance(document.getElementById("editProfileModal")).hide();
        })
        .catch(err => {
          console.error("❌ Error updating profile:", err);
          alert("Error saving profile. Please try again.");
        });
    });
  });
  

function formatReadableDate(isoDate) {
    if (!isoDate) return "N/A";
    const date = new Date(isoDate);
    const options = { year: "numeric", month: "long", day: "numeric" };
    return date.toLocaleDateString("en-US", options); // e.g., May 7, 2003
}

document.addEventListener("DOMContentLoaded", function () {
    const form = document.getElementById("updatePasswordForm");
  
    form.addEventListener("submit", async function (e) {
      e.preventDefault();
  
      const oldPassword = document.getElementById("oldPassword");
      const newPassword = document.getElementById("newPassword");
      const confirmPassword = document.getElementById("confirmPassword");
  
      const oldError = document.getElementById("oldPasswordError");
      const newError = document.getElementById("newPasswordError");
      const confirmError = document.getElementById("confirmPasswordError");
  
      // Reset
      [oldPassword, newPassword, confirmPassword].forEach(input => input.classList.remove("is-invalid"));
      [oldError, newError, confirmError].forEach(err => err.style.display = "none");
  
      let hasError = false;
  
      // Validate
      if (!oldPassword.value.trim()) {
        oldPassword.classList.add("is-invalid");
        oldError.textContent = "Old password is required.";
        oldError.style.display = "block";
        hasError = true;
      }
  
      if (!newPassword.value.trim()) {
        newPassword.classList.add("is-invalid");
        newError.textContent = "New password is required.";
        newError.style.display = "block";
        hasError = true;
      } else if (newPassword.value.length < 6) {
        newPassword.classList.add("is-invalid");
        newError.textContent = "New password must be at least 6 characters.";
        newError.style.display = "block";
        hasError = true;
      } else if (newPassword.value === oldPassword.value) {
        newPassword.classList.add("is-invalid");
        newError.textContent = "New password cannot be the same as old password.";
        newError.style.display = "block";
        hasError = true;
      }
  
      if (!confirmPassword.value.trim()) {
        confirmPassword.classList.add("is-invalid");
        confirmError.textContent = "Please confirm your new password.";
        confirmError.style.display = "block";
        hasError = true;
      } else if (confirmPassword.value !== newPassword.value) {
        confirmPassword.classList.add("is-invalid");
        confirmError.textContent = "New passwords do not match.";
        confirmError.style.display = "block";
        hasError = true;
      }
  
      if (hasError) return;
  
      // Firebase update
      try {
        const user = firebase.auth().currentUser;
        const credential = firebase.auth.EmailAuthProvider.credential(user.email, oldPassword.value);
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword.value);
  
        alert("✅ Password updated successfully.");
        bootstrap.Modal.getInstance(document.getElementById("updatePasswordModal")).hide();
        form.reset();
      } catch (error) {
        console.error("❌ Error updating password:", error);
  
        if (error.code === "auth/wrong-password") {
          oldPassword.classList.add("is-invalid");
          oldError.textContent = "Old password is incorrect.";
          oldError.style.display = "block";
        } else {
          newPassword.classList.add("is-invalid");
          newError.textContent = "An unexpected error occurred. Try again.";
          newError.style.display = "block";
        }
      }
    });
  });
  
  function openUpdatePasswordModal() {
    const modal = new bootstrap.Modal(document.getElementById("updatePasswordModal"));
    modal.show();
  }
  
function logout() {
    firebase.auth().signOut().then(() => {
        fetch("/admin/logout", {
            method: "POST",
            headers: {
                "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
                "Content-Type": "application/json"
            }
        }).then(response => {
            if (response.redirected) {
                window.location.href = response.url; // Redirect to /
            } else {
                alert("Logout failed.");
            }
        }).catch(error => {
            console.error("Logout error:", error);
            alert("An error occurred during logout.");
        });
    }).catch((error) => {
        console.error("Firebase sign-out failed:", error);
    });
}

