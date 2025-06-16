// ✅ Ensure the DOM is fully loaded before running the script
document.addEventListener("DOMContentLoaded", () => {
  console.log("🌐 DOM fully loaded.");

  // ✅ DOM references
  const addResponderUnitForm = document.getElementById("addResponderUnitForm");
  const editResponderUnitForm = document.getElementById("editResponderUnitForm");
  const addResponderUnitModal = document.getElementById("addResponderUnitModal");
  const assignPersonnelModalEl = document.getElementById("assignResponderPersonnelModal");
  const assignResponderModalEl = document.getElementById("assignResponderModal");
  const responderPersonnelModalEl = document.getElementById("responderPersonnelModal");

  let editingUnitId = null;

    addResponderUnitForm.addEventListener("submit", async (e) => {
        e.preventDefault();

        const unitName = document.getElementById("unitName").value.trim();
        const responderId = document.getElementById("responderUser").value;
        const currentUser = firebase.auth().currentUser;
        
        let stationIdValue = null;
        let stationTypeValue = null;

        if (!currentUser) {
            alert("❌ User not signed in.");
            return;
        }

        const unitAssign = currentUser.uid;

        try {
            // 🔍 Get station_id from users collection
            const userSnap = await firebase.database().ref(`users/${unitAssign}`).once("value");
            if (!userSnap.exists()) throw new Error("Signed-in user not found in users collection.");
            const userData = userSnap.val();
            stationIdValue = userData.station_id;

            // 🔍 Get station_type from emergency_responder_station
            const stationSnap = await firebase.database().ref(`emergency_responder_station/${stationIdValue}`).once("value");
            if (!stationSnap.exists()) throw new Error("Station not found in emergency_responder_station.");
            const stationData = stationSnap.val();
            stationTypeValue = stationData.station_type;

        } catch (err) {
            console.error("❌ Error fetching station details:", err);
            alert("❌ Unable to retrieve station details.");
            return;
        }

        // ✅ Form validation
        if (!unitName || !responderId || !stationIdValue || !stationTypeValue) {
            alert("⚠️ Please complete all required fields.");
            return;
        }

        // ✅ Build unit data object
        const unitData = {
            unit_Name: unitName,
            unit_Status: "Active",
            ER_ID: responderId,
            station_ID: unitAssign,           // UID of current user
            unit_Assign: stationTypeValue,   // From emergency_responder_station
        };

        try {
            if (editingUnitId) {
                // 🔁 EDIT MODE
                await firebase.database().ref(`responder_unit/${editingUnitId}`).update(unitData);
                showSuccessModal("✅ Responder Unit updated!");
            } else {
                // ➕ ADD MODE
                await firebase.database().ref("responder_unit").push(unitData);
                showSuccessModal("✅ Responder Unit Added!");
            }

            // ✅ Reset state and close modal
            resetForm(addResponderUnitForm);
            closeModal(addResponderUnitModal);
        } catch (error) {
            console.error("❌ Failed to save unit:", error);
            alert("❌ Failed to save unit. Please try again.");
        }
    });

    // ✅ EDIT UNIT FORM SUBMISSION
    editResponderUnitForm.addEventListener("submit", async (e) => {
        e.preventDefault();
        const unitId = e.target.dataset.unitId;
        const unitName = document.getElementById("unitNameEdit").value.trim();
        const responderId = document.getElementById("responderUserEdit").value;

        const currentUser = firebase.auth().currentUser;
        if (!currentUser) {
            alert("❌ User not signed in.");
            return;
        }

        const unitAssign = currentUser.uid;
        let stationIdValue = null;
        let stationTypeValue = null;

        try {
            // 🔍 Get station_id from users collection
            const userSnap = await firebase.database().ref(`users/${unitAssign}`).once("value");
            if (!userSnap.exists()) throw new Error("Signed-in user not found in users collection.");
            const userData = userSnap.val();
            stationIdValue = userData.station_id;

            // 🔍 Get station_type from emergency_responder_station
            const stationSnap = await firebase.database().ref(`emergency_responder_station/${stationIdValue}`).once("value");
            if (!stationSnap.exists()) throw new Error("Station not found in emergency_responder_station.");
            const stationData = stationSnap.val();
            stationTypeValue = stationData.station_type;

        } catch (err) {
            console.error("❌ Error fetching station details:", err);
            alert("❌ Unable to retrieve station details.");
            return;
        }

        // ✅ Build updated unit object
        const updatedUnit = {
            unit_Name: unitName,
            unit_Assign: unitAssign,
            unit_Status: "Active",
            ER_ID: responderId,
            station_ID: unitAssign,
            station_Type: stationTypeValue,
        };

        try {
            await firebase.database().ref(`responder_unit/${unitId}`).update(updatedUnit);
            showSuccessModal("✅ Responder Unit updated!");
            closeModal(document.getElementById("editResponderUnitModal"));
        } catch (error) {
            console.error("❌ Error updating unit:", error);
            alert("❌ Failed to update unit. Please try again.");
        }
    });


  // ✅ Modal Event Listeners
  addResponderUnitModal.addEventListener("show.bs.modal", () => {
      console.log("📦 Opening Add Unit Modal");

      // Reset the form when opening the modal
      resetForm(addResponderUnitForm);

      // Hide other modals
      closeModal(assignResponderModalEl);
      closeModal(responderPersonnelModalEl);
  });

  addResponderUnitModal.addEventListener("hidden.bs.modal", () => {
      console.log("🔁 Re-opening Assign Modal");
      openModal(assignResponderModalEl);
  });

  assignPersonnelModalEl.addEventListener("show.bs.modal", () => {
      closeModal(assignResponderModalEl);
  });

  assignResponderModalEl.addEventListener("show.bs.modal", () => {
      closeModal(assignPersonnelModalEl);
  });

  assignPersonnelModalEl.addEventListener("hidden.bs.modal", () => {
      openModal(assignResponderModalEl);
  });

  // ✅ Utility Functions

  // 👉 Close Modal
  function closeModal(modalElement) {
      const modalInstance = bootstrap.Modal.getInstance(modalElement);
      if (modalInstance) {
          modalInstance.hide();
      }
  }

  // 👉 Open Modal
  function openModal(modalElement) {
      const modalInstance = new bootstrap.Modal(modalElement);
      modalInstance.show();
  }

  // 👉 Reset Form
  function resetForm(formElement) {
      formElement.reset();
      editingUnitId = null;

      // Reset button text
      document.querySelector(`#${formElement.id} button[type='submit']`).textContent = "Add Unit";
  }

  // 👉 Show Success Modal
  function showSuccessModal(message) {
      document.getElementById("successModalMessage").innerText = message;
      const modal = new bootstrap.Modal(document.getElementById("successModal"));
      modal.show();
      setTimeout(() => modal.hide(), 2000);
  }
});
