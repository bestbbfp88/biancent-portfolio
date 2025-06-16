document.addEventListener("DOMContentLoaded", () => {
  let unitIdToArchive = null;

  // ✅ Step 1: Confirm archive with validation
  window.confirmArchiveUnit = async function (unitId) {
      unitIdToArchive = unitId;

      try {
          // 🛑 Check if the unit is still assigned to a responder
          const unitSnapshot = await firebase.database().ref(`responder_unit/${unitId}`).once("value");

          if (unitSnapshot.exists()) {
              const unitData = unitSnapshot.val();

              // 🚫 Prevent archiving if assigned to a responder
              if (unitData.ER_ID) {
                  alert("❌ Cannot archive unit. It is still assigned to a responder.");
                  unitIdToArchive = null;  // Reset the ID
                  return; 
              }
          }

          // ✅ Show confirmation modal
          const modalElement = document.getElementById("archiveConfirmModal");
          const modalInstance = new bootstrap.Modal(modalElement);
          modalInstance.show();

      } catch (error) {
          console.error("❌ Error checking assigned responder:", error);
          alert("❌ Failed to verify unit status. Please try again.");
          unitIdToArchive = null;  // Reset the ID
      }
  };

  // ✅ Step 2: Archive the unit when confirmed
  document.getElementById("confirmArchiveBtnUnit").addEventListener("click", async () => {
      if (!unitIdToArchive) return;

      try {
          // ✅ Archive the unit
          await firebase.database().ref(`responder_unit/${unitIdToArchive}`).update({
              unit_Status: "Archived"
          });

          // ✅ Hide the modal properly
          const modalElement = document.getElementById("archiveConfirmModal");
          const modalInstance = bootstrap.Modal.getInstance(modalElement);

          if (modalInstance) {
              modalInstance.hide();
          }

          showSuccessModal("✅ Unit Archived!");

          // 🔄 Refresh the list if fetchResponderUnits exists
          if (typeof fetchResponderUnits === "function") {
              fetchResponderUnits();
          }

      } catch (error) {
          console.error("❌ Failed to archive unit:", error);
          alert("❌ Failed to archive the unit. Please try again.");
      }

      unitIdToArchive = null;  // Reset the ID
  });
});
