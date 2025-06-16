let suppressAssignStation = false;

document.addEventListener("DOMContentLoaded", () => {
    loadEmergencyResponderStations();

    let patientInput = document.getElementById("numberPatients");
    if (patientInput) {
        patientInput.addEventListener("input", () => {
            if (emergencyLocation) assignNearestStation(emergencyLocation.lat, emergencyLocation.lng);
        });
    }
});

// ✅ Emergency Type Change Event
document.addEventListener("DOMContentLoaded", () => {
    let emergencyTypeDropdown = document.getElementById("emergencyType");
    if (!emergencyTypeDropdown) return;

    emergencyTypeDropdown.addEventListener("change", () => {
        if (suppressAssignStation) return; // ✅ Block duplicate call
        if (emergencyLocation) assignNearestStation(emergencyLocation.lat, emergencyLocation.lng);
    });
    
});


document.addEventListener("DOMContentLoaded", () => {
    loadEmergencyResponderStations();

    const emergencyTypeDropdown = document.getElementById("emergencyType");
    const otherEmergencyField = document.getElementById("otherEmergencyType");
    const tarsierSection = document.getElementById("tarsierResponderSection");
    const recommendFieldSection = document.getElementById("recommendField");
    const stationDropdown = document.getElementById("stationDropdownButton");
    const patientInput = document.getElementById("numberPatients");
    const mvcRadioButtons = document.querySelectorAll("input[name='mvcType']");

    if (!emergencyTypeDropdown) return;

    // ✅ Emergency Type Change Handler
    const handleEmergencyTypeChange = () => {
        const emergencyType = emergencyTypeDropdown.value;
        const patientCount = parseInt(document.getElementById("numberPatients").value) || 1;

        console.log("🚑 Emergency Type Changed:", emergencyType);

        // Show/Hide custom type input
        if (otherEmergencyField) {
            otherEmergencyField.style.display = emergencyType === "Other" ? "block" : "none";
        }

        // Show/Hide recommendation field
        if (recommendFieldSection) {
            recommendFieldSection.style.display = emergencyType === "Other" ? "none" : "block";
        }

        // Show/Hide TaRSIER responder section
        if (tarsierSection) {
            tarsierSection.style.display = (emergencyType === "Medical" || emergencyType === "Other" || emergencyType === "Trauma" || emergencyType === "MVC") ? "block" : "none";
        }

        if (emergencyLocation) {
          //  assignNearestStation(emergencyLocation.lat, emergencyLocation.lng);
            recommendNearestEmergencyUnit(emergencyLocation.lat, emergencyLocation.lng);
        }
    };

    // ✅ MVC Sub-option Change Handler
    const handleMVCSubtypeChange = () => {
        const emergencyType = emergencyTypeDropdown.value;
        if (emergencyType === "MVC" && emergencyLocation) {
            assignNearestStation(emergencyLocation.lat, emergencyLocation.lng);
            recommendNearestEmergencyUnit(emergencyLocation.lat, emergencyLocation.lng);
        }
    };

    // Event: Emergency Type Change
    emergencyTypeDropdown.addEventListener("change", handleEmergencyTypeChange);

    // // Event: Number of Patients (recalculate assignment if changed)
    // if (patientInput) {
    //     patientInput.addEventListener("input", () => {
    //         if (emergencyLocation) assignNearestStation(emergencyLocation.lat, emergencyLocation.lng);
    //     });
    // }

    // Event: MVC sub-option radio buttons
    mvcRadioButtons.forEach(radio => {
        radio.addEventListener("change", handleMVCSubtypeChange);
    });

    // Initial trigger (if form opens pre-filled)
    handleEmergencyTypeChange();
});



document.addEventListener("DOMContentLoaded", function() {

    document.getElementById("emergencyType").addEventListener("change", function() {
        document.getElementById("otherEmergencyType").style.display = this.value === "Other" ? "block" : "none";
        recommendNearestEmergencyUnit(emergencyLocation.lat, emergencyLocation.lng);
    });
});

