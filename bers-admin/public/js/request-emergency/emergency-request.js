document.addEventListener("DOMContentLoaded", () => {
    const db = firebase.database();
    const emergencyRef = db.ref("emergencies");
    const userRef = db.ref("users");
  
    const yearFilter = document.getElementById("yearFilter");
    const monthFilter = document.getElementById("monthFilter");
    const dayFilter = document.getElementById("dayFilter");
    const searchInput = document.getElementById("searchEmergencyRequests");
    const tableBody = document.getElementById("emergencyRequestTableBody");
  
    const allEmergencies = [];
  
    function getMonthName(monthIndex) {
      return new Date(2000, monthIndex).toLocaleString("default", { month: "long" });
    }
  
    function getUserMap() {
      return userRef.once("value").then((snapshot) => {
        const map = {};
        snapshot.forEach((child) => {
          const data = child.val();
          map[child.key] = `${data.f_name} ${data.l_name}`;
        });
        return map;
      });
    }
  
    function populateDropdowns(emergencies) {
      const yearSet = new Set();
      const monthSet = new Set();
      const daySet = new Set();
  
      emergencies.forEach((e) => {
        const d = new Date(e.date_time);
        yearSet.add(d.getFullYear());
        monthSet.add(d.getMonth());
        daySet.add(d.getDate());
      });
  
      yearFilter.innerHTML = '<option value="">Year</option>';
      [...yearSet].sort((a, b) => b - a).forEach((year) => {
        yearFilter.innerHTML += `<option value="${year}">${year}</option>`;
      });
  
      monthFilter.innerHTML = '<option value="">Month</option>';
      [...monthSet].sort((a, b) => a - b).forEach((m) => {
        monthFilter.innerHTML += `<option value="${m}">${getMonthName(m)}</option>`;
      });
  
      dayFilter.innerHTML = '<option value="">1–31</option>';
      [...daySet].sort((a, b) => a - b).forEach((d) => {
        dayFilter.innerHTML += `<option value="${d}">${d}</option>`;
      });
    }
  
    function renderTable(filtered) {
      tableBody.innerHTML = "";
  
      if (filtered.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="4">No emergency records found.</td></tr>';
        return;
      }
  
      filtered.forEach((e) => {
        const date = new Date(e.date_time);
        const formattedDate = date.toLocaleDateString("en-US", {
          month: "short",
          day: "numeric",
          year: "numeric"
        });
  
        const status = e.report_Status;
        let badgeClass = "bg-secondary";
        if (status === "Urgent") badgeClass = "bg-danger";
        else if (["Assigning", "In progress"].includes(status)) badgeClass = "bg-warning text-dark";
  
        const row = document.createElement("tr");
        row.innerHTML = `
          <td>${e.callerName}</td>
          <td>${formattedDate}</td>
          <td><span class="badge ${badgeClass}">${status}</span></td>
          <td>
            <button class="btn btn-outline-dark btn-sm view-btn-history" 
                    data-id="${e.report_ID}" 
                    data-dispatch="${e.dispatch_ID}">
                View
            </button>
        </td>

        `;
        tableBody.appendChild(row);
      });
    }
  
    function applyFilters() {
      const yearVal = yearFilter.value;
      const monthVal = monthFilter.value;
      const dayVal = dayFilter.value;
      const searchVal = searchInput.value.toLowerCase();
  
      const filtered = allEmergencies.filter((e) => {
        const date = new Date(e.date_time);
        const matchesYear = yearVal === "" || date.getFullYear() == yearVal;
        const matchesMonth = monthVal === "" || date.getMonth() == monthVal;
        const matchesDay = dayVal === "" || date.getDate() == dayVal;
        const matchesSearch = e.callerName.toLowerCase().includes(searchVal);
  
        return matchesYear && matchesMonth && matchesDay && matchesSearch;
      });
  
      renderTable(filtered);
    }
  
    // Add event listeners to filters
    [yearFilter, monthFilter, dayFilter, searchInput].forEach((el) => {
      el.addEventListener("input", applyFilters);
    });
  
    // Load data from Firebase
    Promise.all([getUserMap(), emergencyRef.once("value")]).then(async ([_, snapshot]) => {
      if (!snapshot.exists()) return;
    
      const emergencyList = [];
      const ticketFetches = [];
    
      snapshot.forEach((child) => {
        const emergencyData = child.val();
        const dispatchId = emergencyData.dispatch_ID;
        const dateTime = emergencyData.date_time;
    
        if (dispatchId && dateTime) {
          const ticketPromise = firebase.database()
            .ref(`tickets/${dispatchId}`)
            .once("value")
            .then((ticketSnap) => {
              const ticket = ticketSnap.val();
    
              // 🔍 Debugging
              console.log(`🧾 dispatch_ID: ${dispatchId}`);
              console.log(`📄 ticket:`, ticket);
    
              const reporterName = ticket?.reporter_name || "Unknown";
    
              emergencyList.push({
                ...emergencyData,
                callerName: reporterName
              });
            });
    
          ticketFetches.push(ticketPromise);
        } else {
          console.warn("⚠️ Missing dispatch_ID or date_time:", emergencyData);
        }
      });
    
      await Promise.all(ticketFetches);
    
      allEmergencies.push(...emergencyList);
      console.log("✅ Loaded emergencies with caller names:", allEmergencies);
    
      populateDropdowns(allEmergencies);
      renderTable(allEmergencies);
    });
    
    
  });


  document.addEventListener("click", function (e) {
    if (e.target.classList.contains("view-btn-history")) {
      const reportID = e.target.getAttribute("data-id");
      const dispatchID = e.target.getAttribute("data-dispatch");
  
      const responderContainer = document.getElementById("responderDispatchContainer");
      const prevBtn = document.getElementById("prevResponderBtn");
      const nextBtn = document.getElementById("nextResponderBtn");
      let emergencyData;
      let data;
      let ticketdata;
  
      let responderList = [];
      let currentResponderIndex = 0;
  
      // Reset UI
      responderContainer.innerHTML = "";
      prevBtn.disabled = true;
      nextBtn.disabled = true;
  
      // Fetch emergency data (for timestamp and status)
      firebase.database().ref(`emergencies/${reportID}`).once("value")
        .then(snapshot => {
          emergencyData = snapshot.val();
          document.getElementById("detailDate").textContent = new Date(emergencyData?.date_time).toLocaleString();
        //  document.getElementById("detailStatus").textContent = emergencyData?.report_Status || "N/A";
          document.getElementById("detailNotes").textContent = emergencyData?.report_Status || "N/A";
  
        
        });
  
      // Fetch ticket info
      firebase.database().ref(`tickets/${dispatchID}`).once("value")
        .then(snapshot => {
          data = snapshot.val();

          const name = data?.reporter_name || "N/A";
          const contact = data?.reporter_contact || "N/A";
          const email = data?.reporter_email || "N/A";
          document.getElementById("detailCaller").textContent = `${name} (${contact}) (${email})`;


          document.getElementById("detailLocation").textContent = data?.location || "N/A";
         // document.getElementById("detailIncident").textContent = data?.complaint_incident || "N/A";
         // document.getElementById("detailHazard").textContent = data?.hazard_site || "N/A";
  
          let type = data?.emergencyType || "N/A";
          const other = data?.otherEmergencyType?.trim();
          const mvc = data?.mvcType?.trim();
          if (type === "Other" && other) type += ` - ${other}`;
          if (type === "MVC" && mvc) type += ` - ${mvc}`;
          document.getElementById("detailType").textContent = type;
  
         
          document.getElementById("detailGender").textContent = data?.patient_gender || "N/A";
  
          document.getElementById("detailResponse").textContent = data?.responsiveness || "N/A";
          document.getElementById("detailBreathing").textContent = data?.breathing || "N/A";
          document.getElementById("detailAmbulatory").textContent = data?.ambulatory_status || "N/A";
          document.getElementById("detailBleeding").textContent = data?.bleeding_site || "N/A";
  
         
          // document.getElementById("detailResponse").textContent = data?.responsiveness || "N/A";
          // document.getElementById("detailNotes").textContent = data?.notes || "N/A";
          
          const createdByUID = data?.created_by;
          
          if (createdByUID) {
            
            firebase.database().ref(`users/${createdByUID}`).once("value").then(userSnap => {
              
              const userData = userSnap.val();
              const fullName = userData ? `${userData.f_name} ${userData.l_name}` : "Unknown";
    
              document.getElementById("detailCommunicator").textContent = fullName;
            }).catch(() => {
              document.getElementById("detailCommunicator").textContent = "Unknown";
            });
          } else {
            document.getElementById("detailCommunicator").textContent = "N/A";
          }

        });

        firebase.database().ref(`tickets/${dispatchID}`).once("value")
        .then(snapshot => {
          ticketdata = snapshot.val();

          const responders = ticketdata?.responder_data;
          responderList = [];
          currentResponderIndex = 0;
      
          if (responders) {
            responderList = Object.entries(responders); // [[responderId, responderData], ...]
            if (responderList.length > 0) {
              showResponder(0);
            }
          }
      
  
        function showResponder(index) {
          if (!responderList.length) {
            responderContainer.innerHTML = "<em>No responder dispatch records available.</em>";
            prevBtn.disabled = true;
            nextBtn.disabled = true;
            return;
          }
        
          const [responderId, responderData] = responderList[index];
          const dispatch = responderData?.dispatch || {};
          const ambulanceId = responderData?.ambulance_id || "N/A";
          console.log(`Ambulance id: ${ambulanceId}`);

        
          const {
            complaint_incident,
            responsiveness,
            breathing,
            bleeding_site,
            dob,
            phone,
            notes,
            number_of_patients,
            unit_Name,
            ambulatory_status,
            hazard_site,
            dispatch_time,
            patient_name,
            time_at_scene,
            time_at_destination,
            time_at_base,
            firstResponder,
            actionsTaken,
            preArrival
          } = dispatch;
        
          // ✅ Update specific fields in the table or span tags
          document.getElementById("detailResponseUpdate").textContent = responsiveness || "N/A";
          document.getElementById("detailBreathingUpdate").textContent = breathing || "N/A";
          document.getElementById("detailBleedingUpdate").textContent = bleeding_site || "N/A";
          document.getElementById("detailAmbulatoryUpdate").textContent = ambulatory_status || "N/A";
          document.getElementById("detailResponders").textContent = firstResponder || "N/A";
          document.getElementById("detailInstructions").textContent = preArrival || "N/A";
          document.getElementById("detailActions").textContent = actionsTaken || "N/A";

          function formatTimestamp(timestamp) {
            if (!timestamp) return "N/A";
            const date = new Date(timestamp);
            return date.toLocaleString('en-US', { 
              year: 'numeric', 
              month: 'short', 
              day: 'numeric', 
              hour: '2-digit', 
              minute: '2-digit',
              second: '2-digit',
              hour12: true 
            });
          }
          
          // Apply formatting and update DOM
          document.getElementById("detailDispatchTime").textContent = formatTimestamp(dispatch_time);
          document.getElementById("detailAtScene").textContent = formatTimestamp(time_at_scene);
          document.getElementById("detailAtDestination").textContent = formatTimestamp(time_at_destination);
          document.getElementById("detailAtBase").textContent = formatTimestamp(time_at_base);
          

          const birthdate = dob;
          let displayText = "N/A";
          if (birthdate) {
            const birth = new Date(birthdate);
            const today = new Date();
            let age = today.getFullYear() - birth.getFullYear();
            if (
              today.getMonth() < birth.getMonth() ||
              (today.getMonth() === birth.getMonth() && today.getDate() < birth.getDate())
            ) age--;
            displayText = `${birthdate} (${age} yrs old)`;
          }
          document.getElementById("detailBirth").textContent = displayText;

          const displayPatient = patient_name || "N/A";
          const displayPhone = phone && phone !== "N/A" ? ` (${phone})` : "";
          document.getElementById("detailPatient").textContent = `${displayPatient}${displayPhone}`;
          
        //  document.getElementById("detailResponderPatients").textContent = number_of_patients || "N/A";
          document.getElementById("detailHazard").textContent = hazard_site || "N/A";
        
          document.getElementById("detailIncident").textContent = complaint_incident || "N/A";
   
          document.getElementById("detailERU").textContent = unit_Name || "N/A";

         // document.getElementById("detailResponderIndex").textContent = `${index + 1} of ${responderList.length}`;
         const ambulanceContainer = document.getElementById("ambulanceContainer");
         ambulanceContainer.innerHTML = ""; // 🧹 Clear previous
         
         if (ambulanceId && ambulanceId !== "N/A") {
           const button = document.createElement("button");
           button.className = "btn btn-outline-danger";
           button.setAttribute("data-bs-toggle", "modal");
           button.setAttribute("data-bs-target", "#ambulanceReportModal");
           button.innerHTML = '<i class="fas fa-ambulance me-1"></i> View Ambulance Report Form';
         
           button.addEventListener("click", () => {
             console.log("🚑 Populating form...");
             setTimeout(() => {
              populateAmbulanceForm(ambulanceId, data, emergencyData, dispatch);
            }, 200); // slight delay after modal shows
            
           });
         
           ambulanceContainer.appendChild(button);
         }
         
         

          // ✅ Enable or disable nav buttons
          prevBtn.disabled = index === 0;
          nextBtn.disabled = index === responderList.length - 1;

         
        }
        
  
      prevBtn.onclick = () => {
        if (currentResponderIndex > 0) {
          currentResponderIndex--;
          showResponder(currentResponderIndex);
        }
      };
  
      nextBtn.onclick = () => {
        if (currentResponderIndex < responderList.length - 1) {
          currentResponderIndex++;
          showResponder(currentResponderIndex);
        }
      };
    });
      // Show modal
      const modal = new bootstrap.Modal(document.getElementById("viewEmergencyModal"));
      modal.show();
    }
  });
  

  document.addEventListener("DOMContentLoaded", () => {
    const historyModalEl = document.getElementById("emergencyRequestHistoryModal");
    const viewModalEl = document.getElementById("viewEmergencyModal");

    const historyModal = new bootstrap.Modal(historyModalEl);
    const viewModal = new bootstrap.Modal(viewModalEl);

    // Hide history modal when view modal opens
    viewModalEl.addEventListener("show.bs.modal", () => {
      const activeHistoryModal = bootstrap.Modal.getInstance(historyModalEl);
      if (activeHistoryModal) {
        activeHistoryModal.hide();
      }
    });

    // Show history modal again when view modal closes
    viewModalEl.addEventListener("hidden.bs.modal", () => {
      setTimeout(() => {
        historyModal.show();
      }, 200); // Delay to avoid backdrop flicker
    });

    const timestampEl = document.getElementById('printTimestamp');

  // Format timestamp: e.g. "March 24, 2025, 2:14 PM"
  function updateTimestamp() {
    const now = new Date();
    const options = {
      year: 'numeric', month: 'long', day: 'numeric',
      hour: 'numeric', minute: '2-digit', hour12: true,
    };
    timestampEl.textContent = now.toLocaleString('en-US', options);
  }

    document.getElementById('printDetailsBtn').addEventListener('click', () => {
        updateTimestamp();

        const content = document.querySelector('#viewEmergencyModal .modal-body').innerHTML;
        const printWindow = window.open('', '', 'height=700,width=900');
        printWindow.document.write('<html><head><title>Emergency Details</title>');
        printWindow.document.write('<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">');
        printWindow.document.write('</head><body>');
        printWindow.document.write('<div class="container mt-3">');
        printWindow.document.write(content);
        printWindow.document.write('</div></body></html>');
        printWindow.document.close();
        printWindow.print();
      });
    

  });

  

  
