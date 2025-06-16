function loadDropdownProfile(uid) {
  const userRef = firebase.database().ref("users/" + uid);

  userRef.once("value").then(snapshot => {
      if (!snapshot.exists()) return;

      const user = snapshot.val();
      
      // Fetch station name using station_ID
      if (user.station_id) {
          const stationRef = firebase.database().ref("emergency_responder_station/" + user.station_id);
          stationRef.once("value").then(stationSnapshot => {
              if (stationSnapshot.exists()) {
                  document.getElementById("dropdownProfileName").textContent = stationSnapshot.val().station_name;
              } else {
                  document.getElementById("dropdownProfileName").textContent = "Unknown Station";
              }
          }).catch(error => {
              console.error("❌ Failed to load station data:", error);
              document.getElementById("dropdownProfileName").textContent = "Unknown Station";
          });
      } else {
          document.getElementById("dropdownProfileName").textContent = "Unknown Station";
      }

      // Other profile details
      document.getElementById("dropdownProfileRole").textContent = user.user_role || "Unknown";
      document.getElementById("dropdownProfileEmail").textContent = user.email || "N/A";
      document.getElementById("dropdownProfileContact").textContent = user.user_contact || "N/A";

  }).catch(error => {
      console.error("❌ Failed to load profile:", error);
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
      .then(async snapshot => {
        const data = snapshot.val();
        if (!data) return;

        document.getElementById("editEmail").value = data.email || user.email || "";
        document.getElementById("editContact").value = data.user_contact || "";

        // ✅ Fetch station_name using station_id
        if (data.station_id) {
          try {
            const stationSnap = await firebase.database().ref(`emergency_responder_station/${data.station_id}`).once("value");
            const stationData = stationSnap.val();

            if (stationData && stationData.station_name) {
              document.getElementById("station_name").value = stationData.station_name;
            } else {
              document.getElementById("station_name").value = "Station name not found";
              console.warn("⚠️ station_name not found in emergency_responder_station.");
            }
          } catch (err) {
            console.error("❌ Error fetching station info:", err);
            document.getElementById("station_name").value = "Error loading station";
          }
        } else {
          document.getElementById("station_name").value = "No station assigned";
        }

        // ✅ Show modal after all values are loaded
        new bootstrap.Modal(document.getElementById("editProfileModal")).show();
      })
      .catch(error => {
        console.error("❌ Error fetching user data:", error);
      });

  }
  
  document.addEventListener("DOMContentLoaded", function () {
 
    const editForm = document.getElementById("editProfileForm"); 
    if (!editForm) {
      console.warn("⚠️ Edit form not found in DOM.");
      return;
    }
   
    editForm.addEventListener("submit", function (e) {
      
      e.preventDefault();
  
      const user = firebase.auth().currentUser;
      if (!user) {
        console.error("❌ No authenticated user found.");
        return;
      }
      const contact = document.getElementById("editContact").value;
      const newStationName = document.getElementById("station_name").value;
  
      const userRef = firebase.database().ref(`users/${user.uid}`);
  
      userRef.once("value").then(snapshot => {
        const userData = snapshot.val();
  
        if (!userData) {
          alert("⚠️ User data not found.");
          return;
        }
  
        console.log("✅ User data retrieved:", userData);
  
        const stationId = userData.station_id;
  
        if (!stationId) {
          console.warn("⚠️ No station_id in user profile.");
          alert("⚠️ Station ID not found in user data.");
          return;
        }

        let hasError = false;
        
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
  
        // ✅ Fields to update
        const updates = {
          user_contact: contact
        };
  
        const updateUserRef = userRef.update(updates);
        const updateStationRef = firebase.database().ref(`emergency_responder_station/${stationId}/station_name`).set(newStationName);
  
        Promise.all([updateUserRef, updateStationRef])
          .then(() => {
            console.log("✅ User and station updates successful.");
            alert("✅ Profile updated successfully.");
            bootstrap.Modal.getInstance(document.getElementById("editProfileModal")).hide();
          })
          .catch(err => {
            console.error("❌ Error updating profile or station:", err);
            alert("❌ Error saving profile. Please try again.");
          });
  
      }).catch(err => {
        console.error("❌ Error fetching user data from RTDB:", err);
        alert("❌ Error loading profile.");
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
  
        showSuccessModal("✅ Password updated successfully.");
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

document.addEventListener("DOMContentLoaded", () => {
  const resetLink = document.getElementById("sendResetLinkBtn");

  resetLink.addEventListener("click", async (e) => {
    e.preventDefault();

    const user = firebase.auth().currentUser;
    if (!user || !user.email) {
      alert("⚠️ You must be signed in to reset your password.");
      return;
    }

    try {
      await firebase.auth().sendPasswordResetEmail(user.email);
      alert("✅ Reset link sent to your email.");
      console.log(`📧 Reset email sent to: ${user.email}`);
    } catch (error) {
      console.error("❌ Error sending reset email:", error);
      alert("❌ " + error.message);
    }
  });
});
