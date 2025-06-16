function showSuccessModal(message) {
  const modalEl = document.getElementById("successModal");
  const modalMessage = document.getElementById("successModalMessage");

  // ✅ Set the success message
  modalMessage.innerText = message;

  // ✅ Ensure the modal appears on top
  modalEl.style.zIndex = "9999";  // Force the modal to be above all
  modalEl.style.position = "fixed"; 
  modalEl.style.top = "50%";      
  modalEl.style.left = "50%";
  modalEl.style.transform = "translate(-50%, -50%)";

  // ✅ Hide all backdrops temporarily
  document.querySelectorAll(".modal-backdrop").forEach((backdrop) => {
      backdrop.style.zIndex = "1";  // Push back the backdrop
  });

  // ✅ Show the success modal
  const modal = new bootstrap.Modal(modalEl);
  modal.show();

  // ✅ Auto-hide after 2 seconds
  setTimeout(() => {
      modal.hide();

      // Reset z-index and backdrop after closing
      modalEl.style.zIndex = "";
      document.querySelectorAll(".modal-backdrop").forEach((backdrop) => {
          backdrop.style.zIndex = "";
      });

  }, 2000);
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


 /** ✅ Show Success Modal */
 function showSuccessModalAdvisory() {
  successActivateModal.style.display = "flex";
  setTimeout(() => {
      successActivateModal.style.display = "none";
  }, 2000);
}

