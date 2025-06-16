async function populateAmbulanceForm(ambulanceId, data, emergencyData, dispatch) {
    console.log("🚑 Populating form...");
  
    const snapshot = await firebase.database().ref(`ambulance/${ambulanceId}`).once("value");
    const ambulancedata = snapshot.val();
    if (!ambulancedata) return alert("❌ No ambulance data found.");
  
    function formatDateToPH(datetime) {
      const options = {
        timeZone: 'Asia/Manila',
        year: 'numeric',
        month: 'short',
        day: '2-digit',
        hour: 'numeric',
        minute: '2-digit',
        hour12: true,
      };
      return new Date(datetime).toLocaleString('en-PH', options);
    }
  
    // 📝 Basic Fields
    document.getElementById("amb_date_incident").textContent = emergencyData?.date_time ? formatDateToPH(emergencyData.date_time) : "";
    document.getElementById("amb_responding_unit").textContent = dispatch?.unit_Name || "";
    document.getElementById("amb_shift_time").textContent = ambulancedata?.shift_time || "";
    document.getElementById("amb_pcr_number").textContent = ambulancedata?.pcr_alarm || "";
  
    document.getElementById("amb_incident_location").textContent = data?.location || "";
    document.getElementById("amb_hospital_name").textContent = ambulancedata?.hospital || "";
  
    document.getElementById("amb_lights_scene").textContent = ambulancedata?.is_to_scene || "";
    document.getElementById("amb_location_type").textContent = ambulancedata?.location_type || "";
    document.getElementById("amb_response_type").textContent = ambulancedata?.response_type || "";
  
    // 🧍 Patient
    document.getElementById("amb_patient_name").textContent = dispatch?.patient_name || "";
    document.getElementById("amb_dob").textContent = dispatch?.dob || "";
    document.getElementById("amb_gender").textContent = dispatch?.gender || "";
    document.getElementById("amb_weight").textContent = dispatch?.weight || "";
  
    // ✅ Symptoms
    const symptoms = ambulancedata?.selected_symptoms || [];
    document.getElementById("amb_symptoms").textContent = symptoms.join(", ") || "None";
  
    // ✅ Medical History
    const medical = ambulancedata?.selected_medical_conditions || [];
    document.getElementById("amb_medical_conditions").textContent = medical.join(", ") || "None";
  
    const cardiac = ambulancedata?.selected_cardiac_conditions || [];
    document.getElementById("amb_cardiac_conditions").textContent = cardiac.join(", ") || "None";
  
    const others = ambulancedata?.selected_other_conditions || [];
    document.getElementById("amb_other_conditions").textContent = others.join(", ") || "None";
  
    // ✅ Allergies / Meds
    document.getElementById("amb_allergies").textContent = ambulancedata?.allergies || "N/A";
    document.getElementById("amb_current_medication").textContent = ambulancedata?.current_medication || "N/A";
  
    // ✅ Pain
    document.getElementById("amb_pain_provoke").textContent = ambulancedata?.pain_provoke || "";
    document.getElementById("amb_pain_quality").textContent = ambulancedata?.pain_quality || "";
    document.getElementById("amb_pain_radiate").textContent = ambulancedata?.pain_radiate || "";
    document.getElementById("amb_pain_severity").textContent = ambulancedata?.pain_severity || "";
    document.getElementById("amb_pain_onset_time_display").textContent = ambulancedata?.pain_onset_time_display || "";
  

    document.getElementById("amb_mental_status").textContent = ambulancedata?.mental_status || "";
    document.getElementById("amb_eye_status").textContent = ambulancedata?.eye_status || "";
    document.getElementById("amb_breath_sounds").textContent = ambulancedata?.breath_sounds || "";
    document.getElementById("amb_skin_color").textContent = ambulancedata?.skin_color || "";
    document.getElementById("amb_skin_temp").textContent = ambulancedata?.skin_temp || "";
    document.getElementById("amb_skin_moisture").textContent = ambulancedata?.skin_moisture || "";
    document.getElementById("amb_capillary_refill").textContent = ambulancedata?.capillary_refill || "";
  
    document.getElementById("amb_generated").textContent = formatDateToPH(new Date());
  
  // ✅ Vitals from linked vitals_id (multiple entries)
    const vitalsId = ambulancedata?.vitals_id;
    const vitalsTableBody = document.getElementById("amb_vitals_table_body");

    if (vitalsId && vitalsTableBody) {
    const vitalsSnap = await firebase.database().ref(`vitals/${vitalsId}/entries`).once("value");
    const vitalsEntries = vitalsSnap.val();

    vitalsTableBody.innerHTML = ""; // Clear previous rows

    if (vitalsEntries) {
        Object.values(vitalsEntries).forEach((vitals) => {
        const row = `
            <tr>
            <td>${vitals?.BP || ""}</td>
            <td>${vitals?.PR || ""}</td>
            <td>${vitals?.RR || ""}</td>
            <td>${vitals?.SpO2 || ""}</td>
            <td>${vitals?.Temp || ""}</td>
            <td>${vitals?.GCS || ""}</td>
            </tr>
        `;
        vitalsTableBody.insertAdjacentHTML("beforeend", row);
        });
    } else {
        vitalsTableBody.innerHTML = `<tr><td colspan="7" class="text-center">No vitals data</td></tr>`;
    }
    }

  }
  
  
  function generateAmbulancePDF() {
    const content = document.querySelector('#ambulanceReportModal .modal-body').innerHTML;
    const win = window.open('', '', 'height=800,width=1000');
    win.document.write(`
      <html>
        <head>
          <title>Ambulance Report</title>
          <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
          <style>
            body { font-family: 'Courier New', monospace; font-size: 12px; }
            .vertical-text { writing-mode: vertical-rl; transform: rotate(180deg); font-weight: bold; text-transform: uppercase; }
            table { page-break-inside: avoid; }
            td, th { padding: 4px !important; vertical-align: top !important; }
          </style>
        </head>
        <body>
          <div class="container mt-3">
            ${content}
          </div>
        </body>
      </html>
    `);
    win.document.close();
    win.print();
  }
  