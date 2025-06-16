function openNewTicketModal() {
    const modal = new bootstrap.Modal(document.getElementById('confirmNewEmergencyModal'));
    modal.show();
  }
  
  function proceedCreateEmergencyFromCall() {
    const userID = firebase.database().ref("users").push().key;
    const emergencyID = firebase.database().ref("emergencies").push().key;
  
    const timestamp = new Date().toISOString();
    const defaultLat = 9.6488;
    const defaultLng = 123.8552;
    const defaultAccuracy = 300;
  
    const placeholderUser = {
      f_name: "Unknown",
      l_name: "Caller",
      user_contact: "N/A",
      email: "N/A",
      user_role: "Caller",
      created_at: timestamp
    };
  
    const emergencyData = {
      report_ID: emergencyID,
      user_ID: userID,
      report_Status: "Pending",
      responder_Status: "Not Responded",
      is_User: "Call",
      date_time: timestamp,
      live_es_latitude: defaultLat,
      live_es_longitude: defaultLng,
      live_es_accuracy: defaultAccuracy,
      location: "Unknown Location"
    };
  
    // Step 1: Create user and emergency
    firebase.database().ref(`users/${userID}`).set(placeholderUser)
      .then(() => {
        return firebase.database().ref(`emergencies/${emergencyID}`).set(emergencyData);
      })
      .then(() => {
        // Step 2: Load the form using your existing logic
        fetchEmergencyDetails(emergencyID);
  
        // Step 3: Close confirmation modal
        bootstrap.Modal.getInstance(document.getElementById('confirmNewEmergencyModal')).hide();
      })
      .catch((err) => {
        console.error("❌ Failed to create emergency from call:", err);
        alert("Error creating emergency ticket.");
      });
  }
  