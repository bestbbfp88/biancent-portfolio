document.addEventListener("DOMContentLoaded", () => {
    const emergencyType = document.getElementById("emergencyType");
    const otherInput = document.getElementById("otherEmergencyType");
    const mvcSubOptions = document.getElementById("mvcSubOptions");

    emergencyType.addEventListener("change", () => {
      const selected = emergencyType.value;
      otherInput.style.display = selected === "Other" ? "block" : "none";
      mvcSubOptions.style.display = selected === "MVC" ? "block" : "none";
    });
  });