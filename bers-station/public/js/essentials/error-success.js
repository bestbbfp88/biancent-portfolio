document.addEventListener("DOMContentLoaded", function () {
    console.log("✅ error-success.modals.js loaded");
  
    // ✅ General Success Modal
    window.showSuccessModal = function (message) {
      const modalEl = document.getElementById("successModal");
      const modalMessage = document.getElementById("successModalMessage");
  
      if (!modalEl || !modalMessage) {
        console.warn("⚠️ successModal or successModalMessage element not found.");
        return;
      }
  
      modalMessage.innerText = message;
  
      document.querySelectorAll(".modal-backdrop").forEach((backdrop) => {
        backdrop.style.zIndex = "1";
      });
  
      const modal = new bootstrap.Modal(modalEl);
      modal.show();
  
      setTimeout(() => {
        modal.hide();
      }, 2000);
    };
  
    // ✅ Advisory Update Modal
    window.showSuccessAdvisoryUpdateModal = function () {
      const successModalElement = document.getElementById("successAdvisoryUpdateModal");
  
      if (!successModalElement) {
        console.warn("⚠️ successAdvisoryUpdateModal element not found.");
        return;
      }
  
      const successModal = new bootstrap.Modal(successModalElement);
      successModal.show();
  
      setTimeout(() => {
        successModal.hide();
      }, 2000);
    };
  
    // ✅ Advisory Archive Modal
    window.showSuccessAdvisoryArchiveModal = function () {
      const successArchiveModal = new bootstrap.Modal(document.getElementById("successAdvisoryArchiveModal"));
  
      if (!successArchiveModal) {
        console.warn("⚠️ successAdvisoryArchiveModal element not found.");
        return;
      }
  
      successArchiveModal.show();
  
      setTimeout(() => {
        successArchiveModal.hide();
      }, 3000);
    };
  
    // ✅ Advisory Activate Modal (styled display)
    window.showSuccessModalAdvisory = function () {
      const successActivateModal = document.getElementById("successActivateModal");
  
      if (!successActivateModal) {
        console.warn("⚠️ successActivateModal element not found.");
        return;
      }
  
      successActivateModal.style.display = "flex";
  
      setTimeout(() => {
        successActivateModal.style.display = "none";
      }, 2000);
    };
  });
  