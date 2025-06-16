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

  // ✅ Add Unit Form Submission
  addResponderUnitForm.addEventListener("submit", async (e) => {
      e.preventDefault();
      
      // Gather form data
      const unitName = document.getElementById("unitName").value.trim();
      const unitAssign = document.getElementById("unitAssign").value;
      const responderId = document.getElementById("responderUser").value;
      const stationIdValue = document.getElementById("erStation").value;

      // ✅ Form validation
      if (!unitName || !unitAssign || !responderId) {
          alert("⚠️ Please fill in all required fields.");
          return;
      }

      // ✅ Build unit data object
      const unitData = {
          unit_Name: unitName,
          unit_Assign: unitAssign,
          unit_Status: "Active",
          ER_ID: responderId,
      };

      // Include station ID only if it exists
      if (stationIdValue) {
          unitData.station_ID = stationIdValue;
      }

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

  // ✅ Edit Unit Form Submission
  editResponderUnitForm.addEventListener("submit", async (e) => {
      e.preventDefault();
      const unitId = e.target.dataset.unitId;

      const updatedUnit = {
          unit_Name: document.getElementById("unitNameEdit").value.trim(),
          unit_Assign: document.getElementById("unitAssignEdit").value,
          unit_Status: "Active",
          ER_ID: document.getElementById("responderUserEdit").value,
      };

      const stationId = document.getElementById("erStationEdit").value;
      if (stationId) {
          updatedUnit.station_ID = stationId;
      }

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
