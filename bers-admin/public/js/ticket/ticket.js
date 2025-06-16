function createTicket(emergencyData, userData, ticketData, ticketID) {
    document.getElementById("section1").style.display = "block";
    document.getElementById("section2").style.display = "none";
    document.getElementById("section3").style.display = "none";


    const modalTitle = document.getElementById("createTicketModalLabel");
    if (modalTitle) {
        modalTitle.textContent = ticketID ? "Edit Ticket" : "Create New Ticket";
    }

    const submitBtn = document.getElementById("submit-btn");
    if (submitBtn) {
        submitBtn.textContent = ticketID ? "Update" : "Submit";
    }

    setTimeout(() => {

        if (!ticketID) {
    
            const clearFields = [
                "ticketDescription", "ticketStatus", "ticketDateTime",
                "ticketUserName", "ticketUserContact", "ticketUserEmail",
                "ticketPatientName", "ticketBirthdate", "ticketEContactName",
                "ticketEContactNumber", "patientGender", "ticketAge",
                "ticketNotes", "numberPatients", "responsiveness",
                "complaintIncident", "hazardSite", "emergencyType",
                "assignedResponder", "recommendedTaRSIER", "nearestStation",
                "distanceToStation", "otherEmergencyType", "ambulatory_status"
            ];

           
    
            clearFields.forEach(id => {
                let el = document.getElementById(id);
                if (el) el.value = "";
            });
    
        }

    
        document.getElementById("ticketDescription").value = emergencyData.location || "Unknown";
        const accuracy = emergencyData.live_es_accuracy;
        const accuracyWarning = document.getElementById("locationAccuracyWarning");

        if (accuracyWarning) {
        if (accuracy && parseFloat(accuracy) > 100) {
            accuracyWarning.style.display = "block";
        } else {
            accuracyWarning.style.display = "none";
        }
        }

        document.getElementById("ticketStatus").value = emergencyData.report_Status || "Unknown";
        document.getElementById("ticketDateTime").value = formatDateTime(emergencyData.date_time) || "Unknown";
        document.getElementById("ticketUserName").value = userData.fullName || "Unknown";
        document.getElementById("ticketUserContact").value = userData.user_contact || "N/A";
        document.getElementById("ticketUserEmail").value = userData.email || "N/A";
        
    
        if (emergencyData.is_User === "Patient User") {
            document.getElementById("ticketPatientName").value = userData.fullName;
            document.getElementById("ticketPatientName").readOnly = true;
            document.getElementById("ticketBirthdate").value = userData.birthdate || "";
            document.getElementById("ticketBirthdate").readOnly = true;
            document.getElementById("emergencyContactSection").style.display = "block";
            document.getElementById("ticketEContactName").value = userData.e_contact_name || "Unknown";
            document.getElementById("ticketEContactNumber").value = userData.e_contact_number || "Unknown";
            document.getElementById("patientGender").value = userData.gender || "Other";
            document.getElementById("patientGender").disabled = true;
            calculateAge();
        } else {
            document.getElementById("ticketPatientName").value = "";
            document.getElementById("ticketPatientName").readOnly = false;
        
            document.getElementById("ticketBirthdate").value = "";
            document.getElementById("ticketBirthdate").readOnly = false;
        
            document.getElementById("ticketEContactName").value = "";
            document.getElementById("ticketEContactNumber").value = "";
            document.getElementById("emergencyContactSection").style.display = "none";
        
            document.getElementById("patientGender").value = "";
            document.getElementById("patientGender").disabled = false;
        
            document.getElementById("ticketAge").value = "";
        }
       
        if (ticketID && ticketData) {
            document.getElementById("ticketUserName").value = ticketData.reporter_name || "Unknown";
            document.getElementById("ticketUserContact").value = ticketData.reporter_contact || "N/A";
            document.getElementById("ticketUserEmail").value = ticketData.reporter_email || "N/A";
            document.getElementById("ticketNotes").value = ticketData.notes || "";
            document.getElementById("ambulatory_status").value = ticketData.ambulatory_status || "";
            document.getElementById("patientGender").value = ticketData.patient_gender || "";
            document.getElementById("numberPatients").value = ticketData.number_of_patients || "";
            document.getElementById("responsiveness").value = ticketData.responsiveness || "";
            document.getElementById("complaintIncident").value = ticketData.complaint_incident || "";
            document.getElementById("ticketPatientName").value = ticketData.patient_name || "";
            document.getElementById("hazardSite").value = ticketData.hazard_site || "";
            document.getElementById("emergencyType").value = ticketData.emergencyType || "";
            document.getElementById("assignedResponder").value = emergencyData.responder_ID || "";
            document.getElementById("recommendedTaRSIER").value = ticketData.recommended_tarsier || "";
            document.getElementById("nearestStation").value = emergencyData.assign_station || "";
            document.getElementById("distanceToStation").value = ticketData.station_distance || "";
            document.getElementById("breathing").value = ticketData.breathing || "";
            const bleedingOption = document.getElementById("bleeding_site_option");
            const bleedingInput = document.getElementById("bleeding_site_input");

            if (ticketData.bleeding_site && ticketData.bleeding_site !== "No") {
                bleedingOption.value = "Yes";
                bleedingInput.style.display = "block";
                bleedingInput.value = ticketData.bleeding_site;
            } else {
                bleedingOption.value = "No";
                bleedingInput.style.display = "none";
                bleedingInput.value = "No";
            }

            document.getElementById("otherEmergencyType").value = ticketData.otherEmergencyType || "";
    
            let emergencyTypeDropdown = document.getElementById("emergencyType");
            let otherEmergencyField = document.getElementById("otherEmergencyType");
    
            if (ticketData.emergencyType === "MVC") {
                document.getElementById("mvcSubOptions").style.display = "block";
                if (ticketData.mvcType === "For Extrication") {
                    document.getElementById("mvcExtrication").checked = true;
                } else if (ticketData.mvcType === "Not For Extrication") {
                    document.getElementById("mvcNonExtrication").checked = true;
                }
            } else {
                document.getElementById("mvcSubOptions").style.display = "none";
            }

            
            if (ticketData.emergencyType === "Other") {
                otherEmergencyField.style.display = "block";
                otherEmergencyField.value = ticketData.otherEmergencyType || "";
            }
             else {
                otherEmergencyField.style.display = "none";
                otherEmergencyField.value = "";
            }
    
            suppressAssignStation = true;
                emergencyTypeDropdown.dispatchEvent(new Event("change"));
                setTimeout(() => {
                    suppressAssignStation = false;
                }, 100); // ✅ Allow future changes again after a moment



            let stationIDs = (emergencyData.assign_station || "").split(",");
            let responderIDs = (emergencyData.responder_ID || "").split(",");

            stationDropdownInitialized = false;
            assignNearestStation(emergencyLocation.lat, emergencyLocation.lng, stationIDs);

            updateDropdownWithTarsier(emergencyLocation.lat, emergencyLocation.lng, responderIDs);

        }
    
        let modalElement = document.getElementById("createTicketModal");
        if (modalElement) {
            modalElement.setAttribute("data-emergency-id", emergencyData.emergencyID);
            if (ticketID) {
                modalElement.setAttribute("data-ticket-id", ticketID);
            } else {
                modalElement.removeAttribute("data-ticket-id");
            }
        }

         
        document.getElementById("ticketStatus").addEventListener("change", function () {
            const modalElement = document.getElementById("createTicketModal");
            const emergencyID = modalElement?.getAttribute("data-emergency-id");
            const newStatus = this.value;
        
            console.log("🟡 TicketStatus dropdown changed");
            console.log("➡️ New Status Selected:", newStatus);
            console.log("📦 Emergency ID:", emergencyID);
        
            if (!emergencyID) {
                console.warn("⚠️ No emergency ID found. Cannot update report_Status.");
                return;
            }
        
            firebase.database()
                .ref(`emergencies/${emergencyID}`)
                .update({ report_Status: newStatus })
                .then(() => {
                    console.log(`✅ [Firebase] Updated emergencies/${emergencyID}/report_Status to "${newStatus}"`);
                })
                .catch((error) => {
                    console.error("❌ [Firebase] Failed to update report_Status:", error);
                    showError("ticketStatusError", "⚠️ Failed to update emergency status. Please try again.");
                });
        });
        
    
        let ticketModal = new bootstrap.Modal(modalElement);
        ticketModal.show();
    
    }, 300);
    
}

function submitTicket(event) {
    if (event) event.preventDefault();
    let modalElement = document.getElementById("createTicketModal");
    let emergencyID = modalElement?.getAttribute("data-emergency-id") || window.currentEmergencyID;
    let existingTicketID = modalElement?.getAttribute("data-ticket-id");

    if (!emergencyID) {
        alert("⚠️ Cannot submit ticket: Missing emergency ID!");
        return;
    }

    let emergencyType = document.getElementById("emergencyType");
    let nearestStations = document.getElementById("nearestStation");
    let stationDropdownButton = document.getElementById("stationDropdownButton");
    let assigned_responder= document.getElementById("assignedResponder");
    let tarsierDropdownMenu= document.getElementById("tarsierDropdownButton");

    let isValid = true;

    const emailField = document.getElementById("ticketUserEmail");
    const contactField = document.getElementById("ticketUserContact");

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const phoneRegex = /^\+63\d{10}$/;

    // ✅ Email Validation (Allow "N/A" or valid format)
    if (emailField.value.trim().toUpperCase() !== "N/A" && !emailRegex.test(emailField.value)) {
        emailField.classList.add("is-invalid");
        showError("ticketUserEmailError", "Enter a valid email or type 'N/A'.");
        isValid = false;
    } else {
        emailField.classList.remove("is-invalid");
        clearError("ticketUserEmailError");
    }

    // ✅ Phone Validation (Allow "N/A" or valid +63 format)
    if (contactField.value.trim().toUpperCase() !== "N/A" && !phoneRegex.test(contactField.value)) {
        contactField.classList.add("is-invalid");
        showError("ticketUserContactError", "Contact must start with +63 or type 'N/A'.");
        isValid = false;
    } else {
        contactField.classList.remove("is-invalid");
        clearError("ticketUserContactError");
    }


    if (!emergencyType.value) {
        emergencyType.classList.add("is-invalid");
        isValid = false;
    } else {
        emergencyType.classList.remove("is-invalid");
    }

    const isNearestStationEmpty = nearestStations.value.trim() === "";
    const isResponderEmpty = assigned_responder.value.trim() === "";

    if (isNearestStationEmpty && isResponderEmpty) {
        nearestStations.classList.add("is-invalid");
        stationDropdownButton.classList.add("is-invalid-button");
        assigned_responder.classList.add("is-invalid");
        tarsierDropdownMenu.classList.add("is-invalid-button");
        isValid = false;
    } else {
        nearestStations.classList.remove("is-invalid");
        stationDropdownButton.classList.remove("is-invalid-button");
        assigned_responder.classList.remove("is-invalid");
        tarsierDropdownMenu.classList.remove("is-invalid-button");
    }


    if (!isValid) {
        return; 
    }

    firebase.database().ref(`emergencies/${emergencyID}`).once("value")
    .then(snapshot => {
        const emergencyData = snapshot.val();
        const reportStatus = emergencyData?.report_Status || "Unknown";

    const ticketData = {
        location: document.getElementById("ticketDescription")?.value || "",
        status: document.getElementById("ticketStatus")?.value || "",
        date_time: document.getElementById("ticketDateTime")?.value || "",
        reporter_name: document.getElementById("ticketUserName")?.value || "",
        reporter_contact: document.getElementById("ticketUserContact")?.value || "",
        reporter_email: document.getElementById("ticketUserEmail")?.value || "",
        patient_name: document.getElementById("ticketPatientName")?.value || "",
        patient_gender: document.getElementById("patientGender")?.value || "",
        patient_birth: document.getElementById("ticketBirthdate")?.value || "",
        number_of_patients: document.getElementById("numberPatients")?.value || "",
        responsiveness: document.getElementById("responsiveness")?.value || "",
        complaint_incident: document.getElementById("complaintIncident")?.value || "",
        hazard_site: document.getElementById("hazardSite")?.value || "",
        station_distance: document.getElementById("distanceToStation")?.value || "",
        breathing: document.getElementById("breathing")?.value || "",
        bleeding_site: document.getElementById("bleeding_site_option")?.value === "Yes"
        ? document.getElementById("bleeding_site_input").value || "Yes"
        : "No",

        notes: document.getElementById("ticketNotes")?.value || "",
        emergencyType: emergencyType.value,
        created_by: firebase.auth().currentUser?.uid || "unknown",
        otherEmergencyType: document.getElementById("otherEmergencyType").value || "",
        mvcType: document.querySelector('input[name="mvcType"]:checked')?.value || "",
        ambulatory_status: document.getElementById("ambulatory_status").value || "",

    };


    let ticketRef;
    let dispatch_ID;

    if (existingTicketID) {
        dispatch_ID = existingTicketID;
        ticketRef = firebase.database().ref(`tickets/${dispatch_ID}`);
    } else {
        ticketRef = firebase.database().ref("tickets").push();
        dispatch_ID = ticketRef.key;
    }

    ticketData.dispatch_ID = dispatch_ID;

    if (existingTicketID) {
        ticketData.last_updated = new Date().toISOString();
    }

    ticketRef.update(ticketData)
        .then(() => {

            const emergencyUpdate = {
                dispatch_ID: dispatch_ID,
                report_Status: reportStatus === "Responding" ? reportStatus : "Assigning",
            };

            if (reportStatus !== "Responding" ) {
                emergencyUpdate.assign_station = nearestStations.value;
                emergencyUpdate.responder_ID = assigned_responder.value;
            }

            return firebase.database().ref(`emergencies/${emergencyID}`).update(emergencyUpdate);
        });
    })
    .then(() => {
        // ✅ Support multiple responder IDs
        const responderIDsRaw = document.getElementById("assignedResponder").value;
        const responderIDs = responderIDsRaw.split(',').map(id => id.trim());
    
        const responderUnitRef = firebase.database().ref("responder_unit");
        responderUnitRef.once("value").then(snapshot => {
            snapshot.forEach(child => {
                const unit = child.val();
                const unitKey = child.key;
    
                // If unit.ER_ID matches any responderID
                if (responderIDs.includes(unit.ER_ID)) {
                    firebase.database()
                        .ref(`responder_unit/${unitKey}`)
                        .update({ emergency_ID: emergencyID });
                }
            });
        });
    
        // ✅ Proceed with hiding modal and showing success
        document.getElementById("section1").style.display = "none";
        document.getElementById("section2").style.display = "none";
        document.getElementById("createTicketModal").style.display = "none";
    
        const createTicketModal = document.getElementById("createTicketModal");
        const modalInstance = bootstrap.Modal.getInstance(createTicketModal);
        if (modalInstance) modalInstance.hide();
        document.querySelectorAll(".modal-backdrop").forEach(backdrop => backdrop.remove());
    
        showSuccessModal(existingTicketID ? "Ticket updated successfully!" : "Ticket submitted successfully!");
    })
    
    
        .catch(error => {
            console.error("❌ Error submitting ticket:", error);
            showError("generalError", "❌ Error submitting ticket. Please try again.");
        });
}

function showError(fieldId, message) {
    let errorElement = document.getElementById(fieldId);
    if (!errorElement) {

        let field = document.getElementById(fieldId.replace("Error", ""));
        errorElement = document.createElement("div");
        errorElement.id = fieldId;
        errorElement.classList.add("text-danger", "mt-1", "small");
        field.parentNode.appendChild(errorElement);
    }
    errorElement.innerHTML = message;
}

function clearError(fieldId) {
    let errorElement = document.getElementById(fieldId);
    if (errorElement) {
        errorElement.remove();
    }
}

function toggleBleedingInput(value) {
    const input = document.getElementById("bleeding_site_input");
    if (value === "Yes") {
      input.style.display = "block";
      input.required = true;
    } else {
      input.style.display = "none";
      input.value = "No"; // auto-set as "No" when not applicable
      input.required = false;
    }
  }